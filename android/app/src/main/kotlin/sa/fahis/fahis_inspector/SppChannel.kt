package sa.fahis.fahis_inspector.bluetooth

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.IOException
import java.io.InputStream
import java.util.UUID

/**
 * Bluetooth Classic SPP (Serial Port Profile) bridge for OBD-II / ELM327
 * adapters on Android. Exposes four Flutter channels:
 *
 *   spp/methods        (MethodChannel) — isEnabled / bondedDevices / connect /
 *                                        disconnect / write / openSettings
 *   spp/events         (EventChannel)  — incoming ASCII byte chunks (String)
 *   spp/scan_methods   (MethodChannel) — startDiscovery / cancelDiscovery /
 *                                        createBond
 *   spp/scan           (EventChannel)  — discovered devices ({id, name})
 *
 * Designed to be a drop-in replacement for `flutter_bluetooth_serial` with
 * none of the dead-package fragility. Required runtime permissions are
 * BLUETOOTH_SCAN + BLUETOOTH_CONNECT on Android 12+, ACCESS_FINE_LOCATION
 * on Android 11 and below.
 */
class SppPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private companion object {
        const val TAG = "SppPlugin"
        val SPP_UUID: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
        const val CONNECT_RETRY_DELAY_MS = 500L
        const val READ_BUFFER_SIZE = 1024
    }

    private lateinit var appContext: Context

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var scanMethodChannel: MethodChannel
    private lateinit var scanEventChannel: EventChannel

    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    private val adapter: BluetoothAdapter? by lazy {
        (appContext.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager)?.adapter
    }

    private var socket: BluetoothSocket? = null
    private var readerJob: Job? = null

    private var dataSink: EventChannel.EventSink? = null
    private var scanSink: EventChannel.EventSink? = null

    private var scanReceiver: BroadcastReceiver? = null
    private var receiverRegistered: Boolean = false

    // ── Plugin lifecycle ────────────────────────────────────────────────────

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        appContext = binding.applicationContext
        val messenger = binding.binaryMessenger

        methodChannel = MethodChannel(messenger, "spp/methods").apply {
            setMethodCallHandler(this@SppPlugin)
        }

        eventChannel = EventChannel(messenger, "spp/events").apply {
            setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    dataSink = events
                }
                override fun onCancel(arguments: Any?) {
                    dataSink = null
                }
            })
        }

        scanMethodChannel = MethodChannel(messenger, "spp/scan_methods").apply {
            setMethodCallHandler { call, result -> handleScanMethod(call, result) }
        }

        scanEventChannel = EventChannel(messenger, "spp/scan").apply {
            setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    scanSink = events
                }
                override fun onCancel(arguments: Any?) {
                    scanSink = null
                }
            })
        }
    }

    /**
     * Fire-and-forget cleanup. We can't `runBlocking` here because the
     * engine teardown happens on the main thread and waiting up to 2-3s
     * for the BT socket to close would freeze the UI. Closing the socket
     * unblocks the reader's `read()` so the coroutine exits naturally
     * shortly after — by which point the scope is cancelled and any
     * lingering work is dropped.
     */
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        scanMethodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        scanEventChannel.setStreamHandler(null)

        cancelDiscoveryInternal()
        try { socket?.close() } catch (_: Throwable) {}
        socket = null
        readerJob?.cancel()
        readerJob = null
        scope.cancel()
    }

    // ── Method channel routing ──────────────────────────────────────────────

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isEnabled" -> result.success(adapter?.isEnabled == true)
            "bondedDevices" -> handleBondedDevices(result)
            "connect" -> {
                val id = call.argument<String>("id")
                if (id.isNullOrBlank()) {
                    result.error("INVALID_ARGUMENT", "Missing 'id'", null); return
                }
                handleConnect(id, result)
            }
            "disconnect" -> handleDisconnect(result)
            "write" -> {
                val data = call.argument<String>("data")
                if (data == null) {
                    result.error("INVALID_ARGUMENT", "Missing 'data'", null); return
                }
                handleWrite(data, result)
            }
            "openSettings" -> {
                try {
                    val intent = Intent(Settings.ACTION_BLUETOOTH_SETTINGS)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    appContext.startActivity(intent)
                    result.success(true)
                } catch (t: Throwable) {
                    result.error("OPEN_SETTINGS_FAIL", t.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun handleScanMethod(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startDiscovery" -> handleStartDiscovery(result)
            "cancelDiscovery" -> {
                val ok = cancelDiscoveryInternal()
                result.success(ok)
            }
            "createBond" -> {
                val id = call.argument<String>("id")
                if (id.isNullOrBlank()) {
                    result.error("INVALID_ARGUMENT", "Missing 'id'", null); return
                }
                handleCreateBond(id, result)
            }
            else -> result.notImplemented()
        }
    }

    // ── Bonded devices ──────────────────────────────────────────────────────

    private fun handleBondedDevices(result: MethodChannel.Result) {
        if (!requirePermission(connectPermission(), result)) return
        val a = adapter ?: run {
            result.error("NO_ADAPTER", "Bluetooth not supported", null); return
        }
        try {
            val devices = a.bondedDevices.map {
                mapOf("id" to it.address, "name" to (it.name ?: it.address))
            }
            result.success(devices)
        } catch (t: Throwable) {
            result.error("BONDED_FAIL", t.message, null)
        }
    }

    // ── Connect / Disconnect / Write ────────────────────────────────────────

    private fun handleConnect(id: String, result: MethodChannel.Result) {
        if (!requirePermission(connectPermission(), result)) return
        val a = adapter ?: run {
            result.error("NO_ADAPTER", "Bluetooth not supported", null); return
        }

        scope.launch {
            try {
                val dev = a.getRemoteDevice(id)
                val sock = connectWithRetry(dev)
                socket = sock
                startReader(sock.inputStream)
                withContext(Dispatchers.Main) { result.success(true) }
            } catch (t: Throwable) {
                Log.e(TAG, "connect failed: ${t.message}", t)
                withContext(Dispatchers.Main) {
                    result.error("CONNECT_FAIL", t.message, null)
                }
            }
        }
    }

    private fun handleDisconnect(result: MethodChannel.Result) {
        scope.launch {
            try {
                closeSocket()
                withContext(Dispatchers.Main) { result.success(true) }
            } catch (t: Throwable) {
                withContext(Dispatchers.Main) {
                    result.error("DISCONNECT_FAIL", t.message, null)
                }
            }
        }
    }

    private fun handleWrite(data: String, result: MethodChannel.Result) {
        val sock = socket
        if (sock == null || !sock.isConnected) {
            result.error("NOT_CONNECTED", "Socket not connected", null); return
        }
        scope.launch {
            try {
                sock.outputStream.write(data.toByteArray(Charsets.US_ASCII))
                sock.outputStream.flush()
                withContext(Dispatchers.Main) { result.success(true) }
            } catch (t: Throwable) {
                Log.e(TAG, "write failed: ${t.message}", t)
                withContext(Dispatchers.Main) {
                    result.error("WRITE_FAIL", t.message, null)
                }
            }
        }
    }

    /**
     * Standard SPP path with one retry. Some ELM327 clones drop attempt #1
     * on cold start; a 500ms backoff is enough for the BT stack to settle.
     */
    private suspend fun connectWithRetry(dev: BluetoothDevice): BluetoothSocket {
        adapter?.cancelDiscovery() // discovery interferes with connect

        var lastError: Throwable? = null
        for (attempt in 1..2) {
            try {
                val sock = openSppSocket(dev)
                sock.connect()
                Log.d(TAG, "Socket connected on attempt $attempt")
                return sock
            } catch (t: Throwable) {
                Log.w(TAG, "Connect attempt $attempt failed: ${t.message}")
                lastError = t
                if (attempt < 2) delay(CONNECT_RETRY_DELAY_MS)
            }
        }
        throw lastError ?: IOException("Connect failed")
    }

    /**
     * Tries the standard SPP service-record path first; falls back to the
     * reflective `createRfcommSocket(channel=1)` for ELM327 clones that
     * don't expose the SDP record properly. Required for ~30% of cheap
     * adapters in the wild.
     */
    private fun openSppSocket(dev: BluetoothDevice): BluetoothSocket {
        return try {
            dev.createRfcommSocketToServiceRecord(SPP_UUID)
        } catch (e: IOException) {
            Log.w(TAG, "Standard RFCOMM creation failed; using reflective fallback", e)
            @Suppress("DiscouragedPrivateApi")
            val method = dev.javaClass.getMethod("createRfcommSocket", Int::class.javaPrimitiveType!!)
            method.invoke(dev, 1) as BluetoothSocket
        }
    }

    /**
     * Closes the SPP socket and waits for the reader coroutine to drain.
     *
     * Order is critical: closing the socket first causes the blocking
     * `input.read()` call inside the reader to throw `IOException`, which
     * exits the read loop. THEN we `join()` the coroutine — at this point
     * it's already finishing, so the join returns quickly. Reversing this
     * order would hang because `read()` is a blocking JVM call that does
     * not respect coroutine cancellation.
     */
    private suspend fun closeSocket() {
        val sock = socket
        socket = null
        try {
            sock?.close()
        } catch (t: Throwable) {
            Log.w(TAG, "Error closing socket: ${t.message}")
        }
        val job = readerJob
        readerJob = null
        job?.join()
    }

    // ── Reader ──────────────────────────────────────────────────────────────

    private fun startReader(input: InputStream) {
        readerJob?.cancel()
        readerJob = scope.launch {
            val buf = ByteArray(READ_BUFFER_SIZE)
            try {
                while (isActive) {
                    val n = try {
                        input.read(buf)
                    } catch (t: Throwable) {
                        if (isActive) Log.w(TAG, "Read error: ${t.message}")
                        -1
                    }
                    if (n <= 0) {
                        Log.d(TAG, "Reader ending, n=$n")
                        break
                    }
                    val chunk = String(buf, 0, n, Charsets.US_ASCII)
                    withContext(Dispatchers.Main) {
                        dataSink?.success(chunk)
                    }
                }
            } finally {
                // Tell the Dart side the byte stream ended — lets the wrapper
                // distinguish lost-link from idle.
                withContext(Dispatchers.Main) { dataSink?.endOfStream() }
            }
        }
    }

    // ── Discovery ───────────────────────────────────────────────────────────

    private fun handleStartDiscovery(result: MethodChannel.Result) {
        if (!requirePermission(scanPermission(), result)) return
        val a = adapter ?: run {
            result.error("NO_ADAPTER", "Bluetooth not supported", null); return
        }
        if (!a.isEnabled) {
            result.error("BT_DISABLED", "Bluetooth is disabled", null); return
        }

        try {
            unregisterScanReceiverSafely()

            val receiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    when (intent?.action) {
                        BluetoothDevice.ACTION_FOUND -> {
                            val dev: BluetoothDevice? =
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                    intent.getParcelableExtra(
                                        BluetoothDevice.EXTRA_DEVICE,
                                        BluetoothDevice::class.java,
                                    )
                                } else {
                                    @Suppress("DEPRECATION")
                                    intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                                }
                            val addr = dev?.address ?: return
                            // Reading `name` requires CONNECT permission on Android 12+;
                            // fall back to the address if the lookup throws.
                            val name = try { dev.name } catch (_: SecurityException) { null } ?: addr
                            Log.d(TAG, "FOUND: $name ($addr)")
                            scanSink?.success(mapOf("id" to addr, "name" to name))
                        }
                        BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                            Log.d(TAG, "Discovery finished")
                            // Leave the stream open — caller may restart discovery.
                        }
                    }
                }
            }

            val filter = IntentFilter().apply {
                addAction(BluetoothDevice.ACTION_FOUND)
                addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                appContext.registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
            } else {
                appContext.registerReceiver(receiver, filter)
            }

            scanReceiver = receiver
            receiverRegistered = true

            a.cancelDiscovery()
            val ok = a.startDiscovery()
            Log.d(TAG, "startDiscovery returned $ok")
            result.success(ok)
        } catch (t: Throwable) {
            Log.e(TAG, "startDiscovery failed: ${t.message}", t)
            unregisterScanReceiverSafely()
            result.error("DISCOVERY_FAIL", t.message, null)
        }
    }

    private fun cancelDiscoveryInternal(): Boolean {
        return try {
            adapter?.cancelDiscovery()
            unregisterScanReceiverSafely()
            true
        } catch (t: Throwable) {
            Log.w(TAG, "cancelDiscovery error: ${t.message}")
            false
        }
    }

    private fun unregisterScanReceiverSafely() {
        if (!receiverRegistered) return
        val r = scanReceiver
        if (r != null) {
            try {
                appContext.unregisterReceiver(r)
            } catch (e: IllegalArgumentException) {
                Log.w(TAG, "Receiver was not registered: ${e.message}")
            }
        }
        scanReceiver = null
        receiverRegistered = false
    }

    private fun handleCreateBond(id: String, result: MethodChannel.Result) {
        if (!requirePermission(connectPermission(), result)) return
        try {
            val dev = adapter?.getRemoteDevice(id) ?: run {
                result.error("NO_DEVICE", "Unknown device $id", null); return
            }
            result.success(dev.createBond())
        } catch (t: Throwable) {
            result.error("BOND_FAIL", t.message, null)
        }
    }

    // ── Permission helpers ──────────────────────────────────────────────────

    /**
     * Permission needed to open a socket / read paired devices.
     * Android 12+ uses BLUETOOTH_CONNECT; earlier versions auto-grant
     * BLUETOOTH at install time.
     */
    private fun connectPermission(): String? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            Manifest.permission.BLUETOOTH_CONNECT
        } else null

    /**
     * Permission needed for discovery. Android 12+ uses BLUETOOTH_SCAN
     * (with `neverForLocation` flag in the manifest); earlier versions
     * require ACCESS_FINE_LOCATION at runtime.
     */
    private fun scanPermission(): String? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            Manifest.permission.BLUETOOTH_SCAN
        } else {
            Manifest.permission.ACCESS_FINE_LOCATION
        }

    private fun requirePermission(perm: String?, result: MethodChannel.Result): Boolean {
        if (perm == null) return true
        val granted = ContextCompat.checkSelfPermission(appContext, perm) ==
            PackageManager.PERMISSION_GRANTED
        if (!granted) {
            result.error("PERMISSION_DENIED", "Missing permission: $perm", null)
        }
        return granted
    }
}
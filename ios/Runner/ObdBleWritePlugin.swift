import Flutter
import CoreBluetooth

/// Minimal native bridge that performs BLE Write Without Response on a
/// characteristic whose `writeWithoutResponse` property bit is **false**.
///
/// flutter_blue_plus's native iOS layer (`FlutterBluePlusPlugin.m` line 554)
/// validates the property and rejects the write before it reaches
/// CoreBluetooth.  The BT5050 chip inside the Veepeak OBDCheck BLE requires
/// ATT Write Command (opcode 0x52 — write-without-response) to route data to
/// the ELM327 UART, yet it advertises `writeNR = false`.  This plugin
/// bypasses that validation by calling CoreBluetooth directly.
///
/// **How it works**
/// 1. `prepare(remoteId, serviceUuid, characteristicUuid)`
///    – retrieves the already-connected peripheral via its own
///      `CBCentralManager`, connects (instant — system-level link already
///      exists), discovers services (cached — instant), and caches the
///      `CBCharacteristic` reference.
/// 2. `writeWithoutResponse(data)`
///    – calls `peripheral.writeValue(_:for:type:.withoutResponse)` directly.
///
/// Because this plugin uses its **own** `CBCentralManager` and therefore its
/// own `CBPeripheral` object, setting `.delegate = self` does NOT interfere
/// with flutter_blue_plus's notification delivery (it uses a separate
/// `CBPeripheral` instance for the same physical device).
class ObdBleWritePlugin: NSObject, FlutterPlugin, CBCentralManagerDelegate, CBPeripheralDelegate {

    // MARK: - State

    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic?

    // Pending prepare() callback — fulfilled once service discovery finishes.
    private var prepareResult: FlutterResult?
    private var targetServiceUuid: CBUUID?
    private var targetCharUuid: CBUUID?

    // MARK: - Plugin registration

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "obd_ble_write",
            binaryMessenger: registrar.messenger()
        )
        let instance = ObdBleWritePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        // Create the CBCentralManager eagerly so it's ready when prepare() is
        // called.  The queue is nil → main queue, matching flutter_blue_plus.
        instance.centralManager = CBCentralManager(delegate: instance, queue: nil)
    }

    // MARK: - Method channel

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {

        case "prepare":
            guard let args = call.arguments as? [String: Any],
                  let remoteId = args["remote_id"] as? String,
                  let serviceUuid = args["service_uuid"] as? String,
                  let characteristicUuid = args["characteristic_uuid"] as? String
            else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing prepare() arguments", details: nil))
                return
            }
            prepare(remoteId: remoteId, serviceUuid: serviceUuid, characteristicUuid: characteristicUuid, result: result)

        case "writeWithoutResponse":
            guard let args = call.arguments as? [String: Any],
                  let data = (args["data"] as? FlutterStandardTypedData)?.data
            else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing data", details: nil))
                return
            }
            writeWithoutResponse(data: data, result: result)

        case "dispose":
            cleanup()
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Prepare

    private func prepare(remoteId: String, serviceUuid: String, characteristicUuid: String, result: @escaping FlutterResult) {
        guard let uuid = UUID(uuidString: remoteId) else {
            result(FlutterError(code: "INVALID_UUID", message: "Bad remoteId: \(remoteId)", details: nil))
            return
        }

        targetServiceUuid = CBUUID(string: serviceUuid)
        targetCharUuid = CBUUID(string: characteristicUuid)

        // Retrieve the peripheral the system already knows about (connected by
        // flutter_blue_plus).  This returns our own CBPeripheral object that
        // shares the same underlying BLE link.
        let peripherals = centralManager.retrievePeripherals(withIdentifiers: [uuid])
        guard let p = peripherals.first else {
            result(FlutterError(code: "NOT_FOUND", message: "Peripheral \(remoteId) not known to system", details: nil))
            return
        }

        peripheral = p
        p.delegate = self
        prepareResult = result

        // If already connected at system level, `didConnect` fires immediately.
        centralManager.connect(p, options: nil)
    }

    // MARK: - Write

    private func writeWithoutResponse(data: Data, result: @escaping FlutterResult) {
        guard let p = peripheral, let chr = writeCharacteristic else {
            result(FlutterError(code: "NOT_PREPARED", message: "Call prepare() first", details: nil))
            return
        }

        // CoreBluetooth sends the ATT Write Command (opcode 0x52) regardless
        // of the characteristic's property bits.  No property validation here.
        p.writeValue(data, for: chr, type: .withoutResponse)
        result(nil)
    }

    // MARK: - Cleanup

    private func cleanup() {
        if let p = peripheral {
            centralManager.cancelPeripheralConnection(p)
        }
        peripheral = nil
        writeCharacteristic = nil
        prepareResult = nil
    }

    // MARK: - CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Required delegate method.  Nothing to do — we only use the manager
        // after flutter_blue_plus has already verified the adapter is on.
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Connected (instant since the link already exists).  Discover the
        // target service only — faster than discovering everything.
        if let svc = targetServiceUuid {
            peripheral.discoverServices([svc])
        } else {
            peripheral.discoverServices(nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let msg = error?.localizedDescription ?? "unknown error"
        prepareResult?(FlutterError(code: "CONNECT_FAIL", message: msg, details: nil))
        prepareResult = nil
    }

    // MARK: - CBPeripheralDelegate

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            prepareResult?(FlutterError(code: "DISCOVER_FAIL", message: error.localizedDescription, details: nil))
            prepareResult = nil
            return
        }

        // Find the target service and discover its characteristics.
        guard let svc = peripheral.services?.first(where: { $0.uuid == targetServiceUuid }) else {
            prepareResult?(FlutterError(code: "SERVICE_NOT_FOUND", message: "Service \(targetServiceUuid?.uuidString ?? "?") not found", details: nil))
            prepareResult = nil
            return
        }

        if let chr = targetCharUuid {
            peripheral.discoverCharacteristics([chr], for: svc)
        } else {
            peripheral.discoverCharacteristics(nil, for: svc)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            prepareResult?(FlutterError(code: "CHR_DISCOVER_FAIL", message: error.localizedDescription, details: nil))
            prepareResult = nil
            return
        }

        guard let chr = service.characteristics?.first(where: { $0.uuid == targetCharUuid }) else {
            prepareResult?(FlutterError(code: "CHR_NOT_FOUND", message: "Characteristic \(targetCharUuid?.uuidString ?? "?") not found", details: nil))
            prepareResult = nil
            return
        }

        writeCharacteristic = chr
        prepareResult?(nil)
        prepareResult = nil
    }
}

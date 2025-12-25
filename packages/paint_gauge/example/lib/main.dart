import 'package:flutter/material.dart';
import 'package:paint_gauge/paint_gauge.dart';
import 'package:paint_gauge/paint_gauge_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';

import 'device_detail_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paint Gauge Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DeviceScanPage(),
    );
  }
}

class DeviceScanPage extends StatefulWidget {
  const DeviceScanPage({super.key});

  @override
  State<DeviceScanPage> createState() => _DeviceScanPageState();
}

class _DeviceScanPageState extends State<DeviceScanPage> {
  final _paintGauge = PaintGauge();
  final List<PaintDevice> _devices = [];
  bool _isScanning = false;
  String? _connectionState;
  String? _connectedMac;

  @override
  void initState() {
    super.initState();
    // _paintGauge.useFlutterImpl();
    _listenToStreams();
  }

  void _listenToStreams() {
    // Listen to scan results
    _paintGauge.scanResults.listen((devices) {
      setState(() {
        // Update device list, avoiding duplicates
        for (var device in devices) {
          final index = _devices.indexWhere((d) => d.mac == device.mac);
          if (index >= 0) {
            _devices[index] = device; // Update existing
          } else {
            _devices.add(device); // Add new
          }
        }
        // Sort by RSSI (strongest signal first)
        _devices.sort((a, b) => b.rssi.compareTo(a.rssi));
      });
    });

    // Listen to connection state
    _paintGauge.connectionState.listen((state) {
      setState(() {
        _connectionState = state;
      });

      if (state == 'connected') {
        _showSnackBar('Device connected!', Colors.green);
      } else if (state == 'disconnected') {
        _showSnackBar('Device disconnected', Colors.orange);
        setState(() => _connectedMac = null);
      }
    });

    // Listen to errors
    _paintGauge.errors.listen((error) {
      _showSnackBar('Error: $error', Colors.red);
    });
  }

  Future<void> _requestPermissions() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      return;
    }

    // For Android < 12
    if (await Permission.location.request().isGranted) {
      return;
    }

    _showSnackBar('Bluetooth permissions required', Colors.red);
  }

  Future<void> _startScan() async {
    await _requestPermissions();

    final btEnabled = await _paintGauge.isBluetoothEnabled();
    if (!btEnabled) {
      _showSnackBar('Please enable Bluetooth', Colors.orange);
      await _paintGauge.enableBluetooth();
      return;
    }

    setState(() {
      _isScanning = true;
      _devices.clear();
    });

    try {
      await _paintGauge.startScan();

      // Auto-stop scan after 10 seconds
      Future.delayed(const Duration(seconds: 10), () {
        if (_isScanning) _stopScan();
      });
    } catch (e) {
      _showSnackBar('Failed to start scan: $e', Colors.red);
      setState(() => _isScanning = false);
    }
  }

  Future<void> _stopScan() async {
    await _paintGauge.stopScan();
    setState(() => _isScanning = false);
  }

  Future<void> _connectToDevice(PaintDevice device) async {
    if (_isScanning) await _stopScan();

    _showSnackBar('Connecting to ${device.name}...', Colors.blue);

    try {
      final success = await _paintGauge.connectDevice(device.mac);
      if (success) {
        setState(() => _connectedMac = device.mac);

        // Navigate to device detail page
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeviceDetailPage(deviceId:device.mac),
            ),
          );
        }
      } else {
        _showSnackBar('Failed to connect', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Connection error: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paint Gauge Devices'),
        actions: [
          if (_isScanning)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Connection status bar
          if (_connectionState != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: _connectionState == 'connected'
                  ? Colors.green.shade100
                  : Colors.orange.shade100,
              child: Text(
                'Status: $_connectionState',
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),

          // Device list
          Expanded(
            child: _devices.isEmpty && !_isScanning
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bluetooth_searching,
                      size: 64,
                      color: Colors.grey.shade400
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No devices found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the scan button to start',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                final device = _devices[index];
                final isConnected = device.mac == _connectedMac;

                return ListTile(
                  leading: Icon(
                    isConnected
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth,
                    color: isConnected ? Colors.green : Colors.blue,
                  ),
                  title: Text(
                    device.name.isEmpty ? 'Unknown Device' : device.name,
                    style: TextStyle(
                      fontWeight: isConnected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    '${device.mac}\nRSSI: ${device.rssi} dBm',
                  ),
                  trailing: isConnected
                      ? const Chip(
                    label: Text('Connected'),
                    backgroundColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.white),
                  )
                      : null,
                  onTap: isConnected
                      ? null
                      : () => _connectToDevice(device),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isScanning ? _stopScan : _startScan,
        icon: Icon(_isScanning ? Icons.stop : Icons.search),
        label: Text(_isScanning ? 'Stop Scan' : 'Scan Devices'),
      ),
    );
  }

  @override
  void dispose() {
    if (_isScanning) _stopScan();
    super.dispose();
  }
}
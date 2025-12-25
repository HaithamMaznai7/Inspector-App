import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';

// Vehicle body parts enumeration from protocol document
enum CarPart {
  frontHatch(0x8010, 'Hood'),
  flWing(0x0010, 'Left Front Fender'),
  lAColumn(0x0031, 'Left A-pillar'),
  flDoor(0x0020, 'Left Front Door'),
  lBColumn(0x0832, 'Left B-pillar'),
  blDoor(0x0F20, 'Left Rear Door'),
  lCColumn(0x0F33, 'Left C-pillar'),
  blWing(0x0F10, 'Left Rear Fender'),
  lDColumn(0x0F34, 'Left D-pillar'),
  trunkCover(0x8F10, 'Trunk Cover'),
  rDColumn(0xFF34, 'Right D-pillar'),
  brWing(0xFF10, 'Right Rear Fender'),
  rCColumn(0xFF33, 'Right C-pillar'),
  brDoor(0xFF20, 'Right Rear Door'),
  rBColumn(0xF832, 'Right B-pillar'),
  frDoor(0xF020, 'Right Front Door'),
  rAColumn(0xF031, 'Right A-pillar'),
  frWing(0xF010, 'Right Front Fender'),
  roof(0x8810, 'Roof');

  const CarPart(this.value, this.label);
  final int value;
  final String label;

  static CarPart? fromValue(int value) {
    try {
      return CarPart.values.firstWhere((part) => part.value == value);
    } catch (_) {
      return null;
    }
  }
}

class PartMeasurement {
  final CarPart part;
  double? thickness;
  String? substrate;
  DateTime? timestamp;
  int measurementCount;

  PartMeasurement({
    required this.part,
    this.thickness,
    this.substrate,
    this.timestamp,
    this.measurementCount = 0,
  });

  void update(double newThickness, String newSubstrate) {
    thickness = newThickness;
    substrate = newSubstrate;
    timestamp = DateTime.now();
    measurementCount++;
  }

  bool get hasMeasurement => thickness != null;
}

class DeviceDetailPage extends StatefulWidget {
  final String deviceId;
  const DeviceDetailPage({super.key, required this.deviceId});

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  BluetoothDevice? dev;
  List<StreamSubscription<List<int>>> subscriptions = [];
  String status = 'Connecting...';
  String lastHex = '';
  List<String> debugLog = [];

  // Map to store last measurement for each body part
  late Map<CarPart, PartMeasurement> partMeasurements;

  // Recently updated part (for highlighting)
  CarPart? recentlyUpdatedPart;
  Timer? highlightTimer;

  @override
  void initState() {
    super.initState();
    // Initialize measurements for all parts
    partMeasurements = {
      for (var part in CarPart.values)
        part: PartMeasurement(part: part)
    };
    run();
  }

  void addDebugLog(String message) {
    setState(() {
      debugLog.insert(0, '${DateTime.now().toString().substring(11, 19)} - $message');
      if (debugLog.length > 50) debugLog.removeLast();
    });
    
    print('DEBUG: $message');
  }

  Future<void> run() async {
    try {
      addDebugLog('Starting connection to ${widget.deviceId}');
      dev = BluetoothDevice.fromId(widget.deviceId);

      setState(() => status = 'Connecting...');
      await dev!.connect(
          timeout: const Duration(seconds: 15),
          license: License.free
      ).catchError((e) {
        addDebugLog('Connection error: $e');
        throw e;
      });

      addDebugLog('Connected successfully');
      setState(() => status = 'Requesting MTU...');

      try {
        await dev!.requestMtu(247);
        addDebugLog('MTU set to 247');
      } catch (e) {
        addDebugLog('MTU request failed (not critical): $e');
      }

      setState(() => status = 'Discovering services...');
      final services = await dev!.discoverServices();
      addDebugLog('Found ${services.length} services');

      // Log all services and characteristics
      for (final service in services) {
        addDebugLog('Service: ${service.uuid}');
        for (final char in service.characteristics) {
          final props = [];
          if (char.properties.read) props.add('READ');
          if (char.properties.write) props.add('WRITE');
          if (char.properties.notify) props.add('NOTIFY');
          if (char.properties.indicate) props.add('INDICATE');
          addDebugLog('  Char: ${char.uuid} [${props.join(', ')}]');
        }
      }

      // Collect ALL characteristics with notify or indicate
      final notifyChars = <BluetoothCharacteristic>[];
      for (final s in services) {
        for (final c in s.characteristics) {
          if (c.properties.notify || c.properties.indicate) {
            notifyChars.add(c);
            addDebugLog('Added notify characteristic: ${c.uuid}');
          }
        }
      }

      if (notifyChars.isEmpty) {
        setState(() => status = 'No NOTIFY characteristics found');
        addDebugLog('ERROR: No characteristics with NOTIFY/INDICATE property');
        return;
      }

      addDebugLog('Found ${notifyChars.length} notify characteristic(s)');
      setState(() => status = 'Subscribing to notifications...');

      // Subscribe to ALL notify characteristics (not just one)
      int subscribedCount = 0;
      for (final c in notifyChars) {
        try {
          addDebugLog('Attempting to subscribe to ${c.uuid}...');
          await c.setNotifyValue(true);

          final sub = c.lastValueStream.listen((bytes) {
            if (bytes.isEmpty) return;

            final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
            setState(() => lastHex = hex);
            addDebugLog('Received ${bytes.length} bytes: $hex');

            // Parse and update measurements
            _parseAndUpdateMeasurement(bytes);
          });

          subscriptions.add(sub);
          subscribedCount++;
          addDebugLog('Successfully subscribed to ${c.uuid}');

        } catch (e) {
          addDebugLog('Failed to subscribe to ${c.uuid}: $e');
        }
      }

      if (subscribedCount > 0) {
        setState(() => status = 'Connected - Listening on $subscribedCount characteristic(s)');
        addDebugLog('Ready to receive data from $subscribedCount characteristic(s)');
      } else {
        setState(() => status = 'Connected but no active subscriptions');
        addDebugLog('WARNING: Could not subscribe to any characteristics');
      }

    } catch (e) {
      setState(() => status = 'Error: $e');
      addDebugLog('ERROR in run(): $e');
    }
  }

  void _parseAndUpdateMeasurement(List<int> bytes) {
    addDebugLog('Parsing packet of ${bytes.length} bytes');

    // Log first few bytes for analysis
    if (bytes.length >= 3) {
      addDebugLog('First bytes: [0]=0x${bytes[0].toRadixString(16)} [1]=0x${bytes[1].toRadixString(16)} [2]=0x${bytes[2].toRadixString(16)}');
    }

    if (bytes.length < 4) {
      addDebugLog('Packet too short (${bytes.length} bytes)');
      return;
    }

    final textBytesCnt = bytes[0];
    final scriptCmd = bytes[1];

    // Check for measurement data upload (0xBD 0x52 according to Section 5)
    // Also try alternative patterns in case protocol varies
    bool isMeasurement = false;
    int dataOffset = 2; // Where the 0x52 byte should be

    if (bytes.length >= 10 && scriptCmd == 0xBD && bytes[2] == 0x52) {
      isMeasurement = true;
      dataOffset = 3; // Data starts at byte 3
      addDebugLog('Found standard measurement packet (0xBD 0x52)');
    } else if (bytes.length >= 9 && scriptCmd == 0x52) {
      // Maybe format is different - try alternate parsing
      isMeasurement = true;
      dataOffset = 2;
      addDebugLog('Trying alternate format (0x52 at position 1)');
    } else {
      addDebugLog('Not a measurement packet - cmd=0x${scriptCmd.toRadixString(16)}, byte[2]=${bytes.length > 2 ? "0x${bytes[2].toRadixString(16)}" : "N/A"}');

      // Log the full packet for manual inspection
      if (bytes.length <= 20) {
        addDebugLog('Full packet: ${bytes.map((b) => '0x${b.toRadixString(16)}').join(' ')}');
      }
    }

    if (isMeasurement && bytes.length >= dataOffset + 7) {
      // Extract partId (uint16_t, little-endian)
      final partIdLow = bytes[dataOffset];
      final partIdHigh = bytes[dataOffset + 1];
      final partId = (partIdHigh << 8) | partIdLow;

      addDebugLog('Part ID: 0x${partId.toRadixString(16)} ($partId)');

      // Extract dataStart and dataCnt
      final dataStart = bytes[dataOffset + 2];
      final dataCnt = bytes[dataOffset + 3];

      // Extract value (uint24_t, little-endian)
      final valueByte0 = bytes[dataOffset + 4];
      final valueByte1 = bytes[dataOffset + 5];
      final valueByte2 = bytes[dataOffset + 6];
      final rawValue = (valueByte2 << 16) | (valueByte1 << 8) | valueByte0;

      addDebugLog('Raw value: 0x${rawValue.toRadixString(16)} ($rawValue)');

      // Find the matching car part
      final carPart = CarPart.fromValue(partId);

      if (carPart != null) {
        // Parse measurement value
        final measurement = _parseMeasurementValue(rawValue);

        addDebugLog('✓ Parsed: ${carPart.label} = ${measurement.thickness} μm (${measurement.substrate})');

        // Update the measurement for this part
        setState(() {
          partMeasurements[carPart]!.update(measurement.thickness, measurement.substrate);

          // Highlight recently updated part
          recentlyUpdatedPart = carPart;
          highlightTimer?.cancel();
          highlightTimer = Timer(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                recentlyUpdatedPart = null;
              });
            }
          });
        });
      } else {
        addDebugLog('Unknown part ID: 0x${partId.toRadixString(16)} - not in CarPart enum');
      }
    }
  }

  ({double thickness, String substrate}) _parseMeasurementValue(int rawValue) {
    // Extract substrate from lowest 2 bits
    final substrate = rawValue & 0x03;
    String substrateType;
    switch (substrate) {
      case 0x01:
        substrateType = 'Fe';
        break;
      case 0x02:
        substrateType = 'NFe';
        break;
      case 0x03:
        substrateType = 'Metal Putty';
        break;
      default:
        substrateType = 'Unknown';
    }

    // Check if the highest bit is 1 (negative number)
    final isNegative = (rawValue & 0x800000) != 0;

    double thicknessValue;
    if (isNegative) {
      // Extend sign to 32 bits
      final signedValue = rawValue | 0xFF000000;
      // Convert to signed int32
      final int32Value = signedValue.toSigned(32);
      thicknessValue = int32Value / 256.0;
    } else {
      thicknessValue = rawValue / 256.0;
    }

    // Round according to protocol rules
    if (thicknessValue.abs() < 99.95) {
      thicknessValue = double.parse(thicknessValue.toStringAsFixed(1));
    } else {
      thicknessValue = thicknessValue.round().toDouble();
    }

    return (thickness: thicknessValue, substrate: substrateType);
  }

  @override
  void dispose() {
    for (var sub in subscriptions) {
      sub.cancel();
    }
    dev?.disconnect();
    highlightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final measuredParts = partMeasurements.values.where((m) => m.hasMeasurement).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paint Gauge Measurements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear all measurements',
            onPressed: () {
              setState(() {
                for (var part in CarPart.values) {
                  partMeasurements[part] = PartMeasurement(part: part);
                }
                debugLog.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Card
          Card(
            margin: const EdgeInsets.all(8),
            color: status.contains('Listening') ? Colors.green.shade50 :
            status.contains('Error') ? Colors.red.shade50 : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        status.contains('Listening') ? Icons.check_circle :
                        status.contains('Error') ? Icons.error : Icons.info,
                        color: status.contains('Listening') ? Colors.green :
                        status.contains('Error') ? Colors.red : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          status,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Measured: $measuredParts / ${CarPart.values.length} parts',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ),

          // Debug Info (expandable)
          ExpansionTile(
            title: const Text('Debug Info', style: TextStyle(fontSize: 14)),
            initiallyExpanded: true,
            children: [
              Container(
                height: 150,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: debugLog.length,
                  itemBuilder: (context, index) {
                    return Text(
                      debugLog[index],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: Colors.greenAccent,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Last Hex Payload:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(
                      lastHex.isEmpty ? 'No data received yet' : lastHex,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),

          const Divider(height: 1),

          // Parts List
          Expanded(
            child: ListView.builder(
              itemCount: CarPart.values.length,
              itemBuilder: (context, index) {
                final part = CarPart.values[index];
                final measurement = partMeasurements[part]!;
                final isHighlighted = recentlyUpdatedPart == part;

                return Container(
                  color: isHighlighted ? Colors.amber.shade100 : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: measurement.hasMeasurement
                          ? _getThicknessColor(measurement.thickness!)
                          : Colors.grey.shade300,
                      child: measurement.hasMeasurement
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : Text('${index + 1}', style: const TextStyle(fontSize: 12)),
                    ),
                    title: Text(
                      part.label,
                      style: TextStyle(
                        fontWeight: measurement.hasMeasurement ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: measurement.hasMeasurement
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${measurement.thickness!.toStringAsFixed(1)} μm',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Substrate: ${measurement.substrate} • ${_formatTime(measurement.timestamp!)}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    )
                        : const Text(
                      'No measurement yet',
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                    ),
                    trailing: measurement.hasMeasurement
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '×${measurement.measurementCount}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (isHighlighted)
                          const Icon(
                            Icons.fiber_manual_record,
                            color: Colors.red,
                            size: 12,
                          ),
                      ],
                    )
                        : Icon(Icons.circle_outlined, color: Colors.grey.shade400, size: 20),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  Color _getThicknessColor(double thickness) {
    final absThickness = thickness.abs();
    if (absThickness < 50) return Colors.red;
    if (absThickness < 100) return Colors.orange;
    if (absThickness < 150) return Colors.green;
    return Colors.blue;
  }
}
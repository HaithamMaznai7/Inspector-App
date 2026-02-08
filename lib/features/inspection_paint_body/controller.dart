// import 'dart:async';
// import 'package:fahis_inspector/common/widget/loaders/loaders.dart';
// import 'package:fahis_inspector/features/inspection/controllers/controller.dart';
// import 'package:fahis_inspector/features/inspection_paint_body/models/car_parts.dart';
// import 'package:fahis_inspector/features/inspection_paint_body/models/paint_body_part.dart';
// import 'package:fahis_inspector/features/inspection_paint_body/repository/repository.dart';
// import 'package:fahis_inspector/features/inspection_paint_body/screens/widgets/devices_connection_view.dart';
// import 'package:fahis_inspector/features/inspection_paint_body/screens/widgets/dialog.dart';
// import 'package:fahis_inspector/enums/inspection_stages.dart';
// import 'package:fahis_inspector/main.dart';
// import 'package:fahis_inspector/services/authentication/auth.dart';
// import 'package:fahis_inspector/util/constants/colors.dart';
// import 'package:get/get.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:paint_gauge/paint_gauge.dart';
// import 'package:paint_gauge/paint_gauge_platform_interface.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// class InspectionPaintBodyController extends GetxController {
//   static InspectionPaintBodyController get instance =>
//       Get.find(tag: 'inspection-paint-body');

//   final String slug;
//   late final Box box;

//   InspectionPaintBodyController(this.slug);

//   InspectionController get mainController => Get.find(tag: 'inspection');

//   late final InspectionPaintBodyRepository repository;
//   var paintGauge = PaintGauge();
//   late Box<List> cache;
//   var isScanning = false.obs;
//   var isManualEditing = false.obs;
//   var isLoading = false.obs;
//   RxList<PaintDevice> devices = RxList([]);
//   RxnString connectionState = RxnString(null);
//   RxnString connectedMac = RxnString(null);

//   RxList<PaintBodyPart> partMeasurements = RxList<PaintBodyPart>([]);

//   var measuredParts = 0.obs;
//   Rxn<CarPart> recentlyUpdatedPart = Rxn<CarPart>(
//     null,
//   ); // Example recently updated part
//   Rxn<BluetoothDevice> device = Rxn<BluetoothDevice>(
//     null,
//   ); // Example recently updated part
//   RxList<StreamSubscription<List<int>>> subscriptions = RxList.empty();
//   var status = 'Connecting...'.obs;
//   String lastHex = '';
//   RxList<String> debugLog = RxList.empty();
//   Timer? highlightTimer;

//   @override
//   void onInit() async {
//     super.onInit();
//     final userId = Auth.user?.id;
//     if (userId == null) {
//       Auth.logout();
//       return;
//     }

//     cache = await Hive.openBox<List>('cache');

//     repository = await PaintBodyPart.getRepository(slug);

//     repository.stream.listen((data) {
//       partMeasurements.assignAll(data);
//       // [parts].assignAll(data);
//       update();
//     });

//     mainController.updateInspection(bodyPoints: []);
//     dd('hello');
//     // parts.listen((data) {
//     // });

//     if (![
//       InspectionStage.pending,
//       InspectionStage.accepted,
//     ].contains(mainController.inspection.value?.stage)) {
//       fetchParts();
//     }

//     listenToStreams();
//   }

//   void listenToStreams() {
//     // Listen to scan results
//     paintGauge.scanResults.listen((data) {
//       for (var device in data) {
//         final index = devices.indexWhere((d) => d.mac == device.mac);
//         if (index >= 0) {
//           devices[index] = device; // Update existing
//         } else {
//           devices.add(device); // Add new
//         }
//       }
//       // Sort by RSSI (strongest signal first)
//       devices.sort((a, b) => b.rssi.compareTo(a.rssi));
//       for (final item
//           in cache.get('Saved_Guou_Devices', defaultValue: []) ?? []) {
//         final saved = devices.where((dev) => dev.mac == item).firstOrNull;
//         if (saved != null) {
//           connectToDevice(item);
//         }
//       }

//       update();
//     });

//     // Listen to connection state
//     paintGauge.connectionState.listen((state) {
//       if (connectionState.value != state) {
//         connectionState.value = state;

//         if (state == 'connected') {
//           FLoader.successSnackBar(title: 'Device connected!');
//         } else if (state == 'disconnected') {
//           FLoader.warningSnackBar(title: 'Device disconnected');
//           connectedMac.value = null;
//         }
//       }
//     });

//     // Listen to errors
//     paintGauge.errors.listen((error) {
//       dd("PaintGauge Errors: $error");
//       FLoader.errorSnackBar(title: 'Error Occurred', message: 'error: $error');
//     });
//   }

//   Future<void> requestPermissions() async {
//     if (await Permission.bluetoothScan.request().isGranted &&
//         await Permission.bluetoothConnect.request().isGranted) {
//       return;
//     }

//     // For Android < 12
//     if (await Permission.location.request().isGranted) {
//       return;
//     }

//     FLoader.errorSnackBar(title: 'Bluetooth permissions required');
//   }

//   Future<void> startScan() async {
//     await requestPermissions();

//     final btEnabled = await paintGauge.isBluetoothEnabled();
//     if (!btEnabled) {
//       FLoader.warningSnackBar(title: 'Please enable Bluetooth');
//       await paintGauge.enableBluetooth();
//       return;
//     }

//     if (!(Get.isBottomSheetOpen ?? false)) {
//       Get.bottomSheet(
//         DeviceConnectionView(),
//         isScrollControlled: false,
//         backgroundColor: FColors.white,
//         barrierColor: FColors.darkerGrey,
//       );
//     }

//     isScanning.value = true;
//     devices.clear();

//     update();

//     try {
//       await paintGauge.startScan();

//       // Auto-stop scan after 10 seconds
//       Future.delayed(const Duration(seconds: 10), () {
//         if (isScanning.value) stopScan();
//       });
//     } catch (e) {
//       FLoader.errorSnackBar(
//         title: 'Failed to start scan',
//         message: 'error: $e',
//       );

//       isScanning.value = false;
//       update();
//     }
//   }

//   Future<void> stopScan() async {
//     await paintGauge.stopScan();
//     isScanning.value = false;
//     update();
//   }

//   Future<void> connectToDevice(PaintDevice device) async {
//     if (isScanning.value) await stopScan();

//     FLoader.infoSnackBar(title: 'Connecting to ${device.name}...');

//     try {
//       final success = await paintGauge.connectDevice(device.mac);
//       if (success) {
//         connectedMac.value = device.mac;
//         List oldDevices =
//             cache.get('Saved_Guou_Devices', defaultValue: []) ?? [];

//         if (oldDevices.where((dev) => dev == device).isEmpty) {
//           oldDevices.add(device);
//           cache.put('Saved_Guou_Devices', oldDevices);
//         }

//         if (connectedMac.value != null) {
//           await run(connectedMac.value!);
//         }

//         // Navigate to device detail page
//         if (Get.isBottomSheetOpen ?? false) {
//           Get.back();
//         }
//       } else {
//         FLoader.errorSnackBar(
//           title: 'Failed to connect',
//           message: 'Could not connect to device.',
//         );
//       }
//     } catch (e) {
//       FLoader.errorSnackBar(title: 'Connection error', message: 'error: : $e');
//     }

//     update();
//   }

//   Future<void> fetchParts() async {
//     // 1. Show cached first
//     partMeasurements.assignAll(repository.fetchFromCache());

//     measuredParts.value = partMeasurements
//         .where((m) => m.hasMeasurement)
//         .length;
//     // 2. Then refresh from API
//     isLoading.value = partMeasurements.isEmpty;
//     update();

//     try {
//       partMeasurements.assignAll(await repository.fetchFromApi());
//     } finally {
//       isLoading.value = false;
//       update();
//     }
//   }

//   void addDebugLog(String message) {
//     debugLog.insert(
//       0,
//       '${DateTime.now().toString().substring(11, 19)} - $message',
//     );
//     if (debugLog.length > 50) debugLog.removeLast();

//     dd('DEBUG: $message');

//     update();
//   }

//   Future<void> run(String deviceId) async {
//     try {
//       addDebugLog('Starting connection to $deviceId');
//       device.value = BluetoothDevice.fromId(deviceId);

//       status.value = 'Connecting...';
//       await device.value!
//           .connect(timeout: const Duration(seconds: 15), license: License.free)
//           .catchError((e) {
//             addDebugLog('Connection error: $e');
//             throw e;
//           });

//       addDebugLog('Connected successfully');
//       status.value = 'Requesting MTU...';

//       try {
//         await device.value!.requestMtu(247);
//         addDebugLog('MTU set to 247');
//       } catch (e) {
//         addDebugLog('MTU request failed (not critical): $e');
//       }

//       status.value = 'Discovering services...';
//       final services = await device.value!.discoverServices();
//       addDebugLog('Found ${services.length} services');

//       // Log all services and characteristics
//       for (final service in services) {
//         addDebugLog('Service: ${service.uuid}');
//         for (final char in service.characteristics) {
//           final props = [];
//           if (char.properties.read) props.add('READ');
//           if (char.properties.write) props.add('WRITE');
//           if (char.properties.notify) props.add('NOTIFY');
//           if (char.properties.indicate) props.add('INDICATE');
//           addDebugLog('  Char: ${char.uuid} [${props.join(', ')}]');
//         }
//       }

//       // Collect ALL characteristics with notify or indicate
//       final notifyChars = <BluetoothCharacteristic>[];
//       for (final s in services) {
//         for (final c in s.characteristics) {
//           if (c.properties.notify || c.properties.indicate) {
//             notifyChars.add(c);
//             addDebugLog('Added notify characteristic: ${c.uuid}');
//           }
//         }
//       }

//       if (notifyChars.isEmpty) {
//         status.value = 'No NOTIFY characteristics found';
//         addDebugLog('ERROR: No characteristics with NOTIFY/INDICATE property');
//         return;
//       }

//       addDebugLog('Found ${notifyChars.length} notify characteristic(s)');
//       status.value = 'Subscribing to notifications...';

//       // Subscribe to ALL notify characteristics (not just one)
//       int subscribedCount = 0;
//       for (final c in notifyChars) {
//         try {
//           addDebugLog('Attempting to subscribe to ${c.uuid}...');
//           await c.setNotifyValue(true);

//           final sub = c.lastValueStream.listen((bytes) {
//             if (bytes.isEmpty) return;

//             final hex = bytes
//                 .map((b) => b.toRadixString(16).padLeft(2, '0'))
//                 .join(' ');
//             lastHex = hex;
//             addDebugLog('Received ${bytes.length} bytes: $hex');

//             // Parse and update measurements
//             parseAndUpdateMeasurement(bytes);
//           });

//           subscriptions.add(sub);
//           subscribedCount++;
//           addDebugLog('Successfully subscribed to ${c.uuid}');
//         } catch (e) {
//           addDebugLog('Failed to subscribe to ${c.uuid}: $e');
//         }
//       }

//       if (subscribedCount > 0) {
//         status.value =
//             'Connected - Listening on $subscribedCount characteristic(s)';
//         addDebugLog(
//           'Ready to receive data from $subscribedCount characteristic(s)',
//         );
//       } else {
//         status.value = 'Connected but no active subscriptions';
//         addDebugLog('WARNING: Could not subscribe to any characteristics');
//       }
//     } catch (e) {
//       status.value = 'Error: $e';
//       addDebugLog('ERROR in run(): $e');
//     }
//   }

//   void parseAndUpdateMeasurement(List<int> bytes) {
//     addDebugLog('Parsing packet of ${bytes.length} bytes');

//     // Log first few bytes for analysis
//     if (bytes.length >= 3) {
//       addDebugLog(
//         'First bytes: [0]=0x${bytes[0].toRadixString(16)} [1]=0x${bytes[1].toRadixString(16)} [2]=0x${bytes[2].toRadixString(16)}',
//       );
//     }

//     if (bytes.length < 4) {
//       addDebugLog('Packet too short (${bytes.length} bytes)');
//       return;
//     }

//     final textBytesCnt = bytes[0];
//     final scriptCmd = bytes[1];

//     // Check for measurement data upload (0xBD 0x52 according to Section 5)
//     // Also try alternative patterns in case protocol varies
//     bool isMeasurement = false;
//     int dataOffset = 2; // Where the 0x52 byte should be

//     if (bytes.length >= 10 && scriptCmd == 0xBD && bytes[2] == 0x52) {
//       isMeasurement = true;
//       dataOffset = 3; // Data starts at byte 3
//       addDebugLog('Found standard measurement packet (0xBD 0x52)');
//     } else if (bytes.length >= 9 && scriptCmd == 0x52) {
//       // Maybe format is different - try alternate parsing
//       isMeasurement = true;
//       dataOffset = 2;
//       addDebugLog('Trying alternate format (0x52 at position 1)');
//     } else {
//       addDebugLog(
//         'Not a measurement packet - cmd=0x${scriptCmd.toRadixString(16)}, byte[2]=${bytes.length > 2 ? "0x${bytes[2].toRadixString(16)}" : "N/A"}',
//       );

//       // Log the full packet for manual inspection
//       if (bytes.length <= 20) {
//         addDebugLog(
//           'Full packet: ${bytes.map((b) => '0x${b.toRadixString(16)}').join(' ')}',
//         );
//       }
//     }

//     if (isMeasurement && bytes.length >= dataOffset + 7) {
//       // Extract partId (uint16_t, little-endian)
//       final partIdLow = bytes[dataOffset];
//       final partIdHigh = bytes[dataOffset + 1];
//       final partId = (partIdHigh << 8) | partIdLow;

//       addDebugLog('Part ID: 0x${partId.toRadixString(16)} ($partId)');

//       // Extract dataStart and dataCnt
//       final dataStart = bytes[dataOffset + 2];
//       final dataCnt = bytes[dataOffset + 3];

//       // Extract value (uint24_t, little-endian)
//       final valueByte0 = bytes[dataOffset + 4];
//       final valueByte1 = bytes[dataOffset + 5];
//       final valueByte2 = bytes[dataOffset + 6];
//       final rawValue = (valueByte2 << 16) | (valueByte1 << 8) | valueByte0;

//       addDebugLog('Raw value: 0x${rawValue.toRadixString(16)} ($rawValue)');

//       // Find the matching car part
//       final carPart = partMeasurements
//           .where((i) => i.part?.value == partId)
//           .firstOrNull;

//       if (carPart != null) {
//         // Parse measurement value
//         final measurement = parseMeasurementValue(rawValue);

//         addDebugLog(
//           '✓ Parsed: ${carPart.part?.getLabel} = ${measurement.thickness} μm (${measurement.substrate})',
//         );

//         // Update the measurement for this part
//         carPart.update(measurement.thickness, measurement.substrate).then((data){
//           partMeasurements.value = data;
//         });

//         // Highlight recently updated part
//         recentlyUpdatedPart.value = carPart.part;
//         highlightTimer?.cancel();
//         highlightTimer = Timer(const Duration(seconds: 2), () {
//           recentlyUpdatedPart.value = null;
//         });
//       } else {
//         addDebugLog(
//           'Unknown part ID: 0x${partId.toRadixString(16)} - not in CarPart enum',
//         );
//       }
//     }

//     update();
//   }

//   ({double thickness, String substrate}) parseMeasurementValue(int rawValue) {
//     // Extract substrate from lowest 2 bits
//     final substrate = rawValue & 0x03;
//     String substrateType;
//     switch (substrate) {
//       case 0x01:
//         substrateType = 'Fe';
//         break;
//       case 0x02:
//         substrateType = 'NFe';
//         break;
//       case 0x03:
//         substrateType = 'Metal Putty';
//         break;
//       default:
//         substrateType = 'Unknown';
//     }

//     // Check if the highest bit is 1 (negative number)
//     final isNegative = (rawValue & 0x800000) != 0;

//     double thicknessValue;
//     if (isNegative) {
//       // Extend sign to 32 bits
//       final signedValue = rawValue | 0xFF000000;
//       // Convert to signed int32
//       final int32Value = signedValue.toSigned(32);
//       thicknessValue = int32Value / 256.0;
//     } else {
//       thicknessValue = rawValue / 256.0;
//     }

//     // Round according to protocol rules
//     if (thicknessValue.abs() < 99.95) {
//       thicknessValue = double.parse(thicknessValue.toStringAsFixed(1));
//     } else {
//       thicknessValue = thicknessValue.round().toDouble();
//     }

//     return (thickness: thicknessValue, substrate: substrateType);
//   }

//   onEdit(PaintBodyPart part) async {
//     isLoading.value = true;
//     update();

//     PaintBodyPart? result = await Get.dialog<PaintBodyPart>(Edit(part: part));
//     if (result != null) {
//       part = result;
//     }

//     try {
//       partMeasurements.value = await repository.update(part);
//     } finally {
//       isLoading.value = false;
//       update();
//     }
//   }

//   @override
//   void onClose() {
//     if (isScanning.value) stopScan();
//     for (var sub in subscriptions) {
//       sub.cancel();
//     }
//     device.value?.disconnect();
//     highlightTimer?.cancel();
//     super.onClose();
//   }
// }

import 'package:fahis_inspector/features/inspection_paint_body/controllers/controller.dart';
import 'package:fahis_inspector/features/inspection_paint_body/models/car_parts.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:fahis_inspector/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaintBodyView extends StatelessWidget {
  const PaintBodyView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = InspectionPaintBodyController.instance;

    return Scaffold(
      body: Obx(() {
        final isShown =
            controller.connectedMac.value != null ||
            controller.isManualEditing.value;

        final partMeasurements = controller.partMeasurements.value;
        final measuredParts = controller.measuredParts.value;
        final recentlyUpdatedPart = controller
            .recentlyUpdatedPart
            .value; // Example recently updated part

        return !isShown
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bluetooth_searching,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),

                    const SizedBox(height: FSizes.spaceBtwInputFields),

                    Text(
                      'No devices connected'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: FSizes.spaceBtwInputFields),

                    Text(
                      'Tap the bluetooth icon to connect or skip button to insert values manually'
                          .tr,
                      style: Theme.of(context).textTheme.labelMedium,
                      textAlign: TextAlign.center,
                    ),

                    TextButton(
                      child: Text('Skip'.tr),
                      onPressed: () {
                        controller.isManualEditing.toggle();
                        controller.update();
                      },
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // Status Card
                  Card(
                    margin: const EdgeInsets.all(8),
                    color: Colors.green.shade50,
                    // color: status.contains('Listening') ? Colors.green.shade50 :
                    // status.contains('Error') ? Colors.red.shade50 : null,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                // status.contains('Listening') ? Icons.check_circle :
                                // status.contains('Error') ? Icons.error : Icons.info,
                                color: Colors.green,
                                // color: status.contains('Listening') ? Colors.green :
                                // status.contains('Error') ? Colors.red : Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'status',
                                  // status,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Measured: $measuredParts parts',
                            // 'Measured: $measuredParts / ${CarPart.values.length} parts',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Debug Info (expandable)
                  // ExpansionTile(
                  //   title: const Text('Debug Info', style: TextStyle(fontSize: 14)),
                  //   initiallyExpanded: true,
                  //   children: [
                  //     Container(
                  //       height: 150,
                  //       margin: const EdgeInsets.symmetric(horizontal: 16),
                  //       padding: const EdgeInsets.all(8),
                  //       decoration: BoxDecoration(
                  //         color: Colors.black87,
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //       child: ListView.builder(
                  //         itemCount: debugLog.length,
                  //         itemBuilder: (context, index) {
                  //           return Text(
                  //             debugLog[index],
                  //             style: const TextStyle(
                  //               fontFamily: 'monospace',
                  //               fontSize: 10,
                  //               color: Colors.greenAccent,
                  //             ),
                  //           );
                  //         },
                  //       ),
                  //     ),
                  //     const SizedBox(height: 8),
                  //     Container(
                  //       margin: const EdgeInsets.symmetric(horizontal: 16),
                  //       padding: const EdgeInsets.all(12),
                  //       decoration: BoxDecoration(
                  //         color: Colors.blue.shade50,
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           const Text('Last Hex Payload:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  //           const SizedBox(height: 4),
                  //           Text(
                  //             lastHex.isEmpty ? 'No data received yet' : lastHex,
                  //             style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     const SizedBox(height: 12),
                  //   ],
                  // ),
                  const Divider(height: 1),

                  // Parts List
                  Expanded(
                    child: ListView.builder(
                      itemCount: partMeasurements.length,
                      itemBuilder: (context, index) {
                        final measurement = partMeasurements[index];
                        final isHighlighted = recentlyUpdatedPart == measurement.part;

                        return Container(
                          color: isHighlighted ? Colors.amber.shade100 : null,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: measurement.hasMeasurement
                                  ? _getThicknessColor(measurement.thickness!)
                                  : Colors.grey.shade300,
                              child: measurement.hasMeasurement
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                            ),
                            title: Text(
                              measurement.name,
                              style: TextStyle(
                                fontWeight: measurement.hasMeasurement
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: measurement.hasMeasurement
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'No measurement yet',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 12,
                                    ),
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
                                : Icon(
                                    Icons.circle_outlined,
                                    color: Colors.grey.shade400,
                                    size: 20,
                                  ),
                              onTap: () => controller.onEdit(measurement),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
      }),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: FColors.primaryColor,
        onPressed: controller.startScan,
        child: const Icon(Icons.bluetooth, color: Colors.white, size: 32),
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

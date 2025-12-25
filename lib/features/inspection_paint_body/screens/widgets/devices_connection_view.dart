import 'package:fahis_inspector/features/inspection_paint_body/controllers/controller.dart';
import 'package:fahis_inspector/util/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class DeviceConnectionView extends StatelessWidget {
  const DeviceConnectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = InspectionPaintBodyController.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices Connection'),
        actions: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Obx(
              () => controller.isScanning.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: FColors.primaryColor,
                      ),
                    )
                  : IconButton(
                      onPressed: () => controller.startScan(),
                      icon: Icon(Icons.refresh, color: FColors.primaryColor),
                    ),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Connection status bar
          // if (_connectionState != null)
          //   Container(
          //     width: double.infinity,
          //     padding: const EdgeInsets.all(12),
          //     color: _connectionState == 'connected'
          //         ? Colors.green.shade100
          //         : Colors.orange.shade100,
          //     child: Text(
          //       'Status: $_connectionState',
          //       style: const TextStyle(fontWeight: FontWeight.bold),
          //       textAlign: TextAlign.center,
          //     ),
          //   ),

          // Device list
          Obx(() {
            final devices = controller.devices.value;
            final connectedMac = controller.connectedMac.value;

            return Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  final isConnected = device.mac == connectedMac;

                  return ListTile(
                    leading: Icon(
                      isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
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
                    subtitle: Text('Mac Address: ${device.mac}'),
                    trailing: isConnected
                        ? const Chip(
                            label: Text('Connected'),
                            backgroundColor: Colors.green,
                            labelStyle: TextStyle(color: Colors.white),
                          )
                        : null,
                    onTap: isConnected
                        ? null
                        : () => controller.connectToDevice(device),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

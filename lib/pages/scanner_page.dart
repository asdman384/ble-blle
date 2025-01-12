import 'package:ble_blle/widgest/device.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ble_blle/my_app_state.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({
    super.key,
    required this.btOn,
  });

  final bool btOn;

  @override
  Widget build(BuildContext context) {
    // if (await FlutterBluePlus.isSupported == false) {
    //     print("Bluetooth not supported by this device");
    //     return;
    // }

    if (!btOn) {
      return Center(child: Text('Please turn on BT.'));
    }
    var theme = Theme.of(context);
    var style = theme.textTheme.bodyLarge!.copyWith(color: theme.colorScheme.onPrimaryContainer);
    var appState = context.watch<MyAppState>();
    var devices = appState.foundDevices;
    var isScanning = appState.isScanning;

    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: ElevatedButton(
                child: Text(isScanning ? 'Stop scan' : 'Start scan', style: style),
                onPressed: () {
                  appState.toggleScan();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text('Found ${appState.foundDevices.length} devices:', style: style),
            ),
          ],
        ),
        SingleChildScrollView(
          child: Column(
            children: devices
                .map((device) => Device(
                      name: device.advName,
                      mac: device.remoteId.str,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

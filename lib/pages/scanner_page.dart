import 'package:ble_blle/widgest/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);
    var style = theme.textTheme.bodyLarge!.copyWith(color: theme.colorScheme.onPrimaryContainer);
    // if (await FlutterBluePlus.isSupported == false) {
    //     print("Bluetooth not supported by this device");
    //     return;
    // }

    if (!btOn) {
      appState.scanResults.clear();
      return Center(child: Text('Please turn on BT.', style: style));
    }

    var scanResults = appState.scanResults;
    var isScanning = appState.isScanning;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                child: Text(isScanning ? 'Stop scan' : 'Start scan', style: style),
                onPressed: () {
                  appState.toggleScan();
                },
              ),
              ElevatedButton(
                child: Text('test'),
                onPressed: () {
                  print(0x01);
                },
              ),
              Text('Found ${appState.scanResults.length} devices:', style: style),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: scanResults
                    .map((result) => Device(
                          name: result.device.advName,
                          mac: result.device.remoteId.str,
                          rssi: result.rssi,
                          onTap: () {
                            _handleDeviceTap(appState, result);
                          },
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleDeviceTap(MyAppState appState, ScanResult result) {
    if (appState.isConnecting) {
      return;
    }
    appState.stopScan();
    appState.connect(result.device);
  }
}

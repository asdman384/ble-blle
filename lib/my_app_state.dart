import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MyAppState extends ChangeNotifier {
  late StreamSubscription<List<ScanResult>> _scanResultSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  BluetoothDevice? current;
  Set<BluetoothDevice> foundDevices = <BluetoothDevice>{};
  bool isScanning = false;

  MyAppState() {
    print('MyAppState constructor');
    _scanResultSubscription = FlutterBluePlus.onScanResults.listen(
      (results) {
        if (results.isNotEmpty) {
          ScanResult r = results.last; // the most recently found device
          if (r.advertisementData.connectable) {
            foundDevices.add(r.device);
          }
          notifyListeners();
        }
      },
      onError: (e) => print(e),
    );

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((isScan) {
      isScanning = isScan;
      print('isScanning: $isScanning');
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _scanResultSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  void toggleScan() {
    if (isScanning) {
      FlutterBluePlus.stopScan();
    } else {
      foundDevices.clear();
      FlutterBluePlus.startScan();
    }
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MyAppState extends ChangeNotifier {
  late StreamSubscription<List<ScanResult>> _scanResultSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  Map<String, BluetoothDevice> connectedDevices = <String, BluetoothDevice>{};
  Set<ScanResult> scanResults = <ScanResult>{};
  bool isScanning = false;
  bool isConnecting = false;

  MyAppState() {
    print('MyAppState constructor');
    _scanResultSubscription = FlutterBluePlus.onScanResults.listen(
      (results) {
        if (results.isNotEmpty) {
          ScanResult r = results.last; // the most recently found device
          if (r.advertisementData.connectable) {
            scanResults.add(r);
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
      scanResults.clear();
      FlutterBluePlus.startScan();
    }
  }

  void connect(BluetoothDevice device) async {
    if (connectedDevices.containsKey(device.remoteId.str)) {
      print('device ${device.remoteId.str} is connected already');
      return;
    }

    isConnecting = true;
    notifyListeners();

    var subscription = device.connectionState.listen((BluetoothConnectionState state) async {
      print(state);

      if (state == BluetoothConnectionState.connected) {
        // 1. you must always re-discover services after connection
        await device.discoverServices();
        connectedDevices[device.remoteId.str] = device;
        isConnecting = false;
        notifyListeners();
      }

      if (state == BluetoothConnectionState.disconnected) {
        connectedDevices.remove(device.remoteId.str);
        notifyListeners();
        // 1. typically, start a periodic timer that tries to
        //    reconnect, or just call connect() again right now
        // 2. you must always re-discover services after disconnection!
        print("disconnected ${device.disconnectReason?.code} ${device.disconnectReason?.description}");
      }
    });

    // cleanup: cancel subscription when disconnected
    //   - [delayed] This option is only meant for `connectionState` subscriptions.
    //     When `true`, we cancel after a small delay. This ensures the `connectionState`
    //     listener receives the `disconnected` event.
    //   - [next] if true, the the stream will be canceled only on the *next* disconnection,
    //     not the current disconnection. This is useful if you setup your subscriptions
    //     before you connect.
    device.cancelWhenDisconnected(subscription, delayed: true, next: true);

    // Connect to the device
    await device.connect();
  }

  void disconnect(BluetoothDevice device) async {
    // Disconnect from device
    await device.disconnect();
  }
}

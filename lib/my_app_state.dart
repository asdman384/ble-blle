import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MyAppState extends ChangeNotifier {
  late StreamSubscription<List<ScanResult>> _scanResultSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  Map<String, BluetoothDevice> connectedDevices = <String, BluetoothDevice>{};
  Map<String, Map<String, BluetoothCharacteristic>> characteristicsMap =
      <String, Map<String, BluetoothCharacteristic>>{};
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

  void stopScan() {
    FlutterBluePlus.stopScan();
  }

  Future<void> connect(BluetoothDevice device) async {
    if (connectedDevices.containsKey(device.remoteId.str)) {
      print('-----------------device ${device.remoteId.str} is connected already');
      return;
    }

    isConnecting = true;
    notifyListeners();

    var subscription = device.connectionState.listen((BluetoothConnectionState state) async {
      print('-----------------connection state: $state');

      if (state == BluetoothConnectionState.connected) {
        connectedDevices[device.remoteId.str] = device;
        characteristicsMap[device.remoteId.str] = await _discoverDevice(device);
        isConnecting = false;
        notifyListeners();
      }

      if (state == BluetoothConnectionState.disconnected) {
        connectedDevices.remove(device.remoteId.str);
        characteristicsMap.remove(device.remoteId.str);
        notifyListeners();
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

  /// Disconnect from device
  void disconnect(BluetoothDevice device) async {
    await device.disconnect();
    connectedDevices.remove(device.remoteId.str);
    characteristicsMap.remove(device.remoteId.str);
    notifyListeners();
  }

  Iterable<String> getCharacteristicsUuids(String remoteId) {
    return characteristicsMap.containsKey(remoteId) ? characteristicsMap[remoteId]!.keys : [];
  }

  /// Write to a characteristic
  /// - [remoteId]: the remoteId of the device
  /// - [characteristic]: the UUID of the characteristic
  /// - [value]: a list of bytes
  void write(String remoteId, String characteristic, List<int> value) {
    var c = characteristicsMap[remoteId]![characteristic]!;
    print(
        '-----------------write to $remoteId, $characteristic, $value, writeWithoutResponse: ${c.properties.writeWithoutResponse}');
    c.write(value, withoutResponse: c.properties.writeWithoutResponse);
  }

  _discoverDevice(BluetoothDevice device) async {
    await device.discoverServices();
    var characteristicsMap = <String, BluetoothCharacteristic>{};

    for (var service in device.servicesList) {
      for (BluetoothCharacteristic c in service.characteristics) {
        if (c.properties.write || c.properties.writeWithoutResponse) {
          characteristicsMap[c.uuid.str] = c;
        }
      }
    }

    return characteristicsMap;
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:ble_blle/my_app_state.dart';
import 'package:ble_blle/pages/favorites_page.dart';
import 'package:ble_blle/pages/scanner_page.dart';

void main() {
  runZonedGuarded(() {
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: false);
    runApp(MyApp());
  }, (error, stackTrace) {
    print('runzoneGuarded error: $error');
    print('runzoneGuarded stackTrace: $stackTrace');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'ble App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: AppContainer(),
      ),
    );
  }
}

class AppContainer extends StatefulWidget {
  @override
  State<AppContainer> createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();

    _adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('AppContainer build, _adapterState:$_adapterState');

    Widget page = selectedTabIndex == 0
        ? ScannerPage(btOn: _adapterState == BluetoothAdapterState.on)
        : selectedTabIndex == 1
            ? FavoritesPage()
            : Placeholder();

    Expanded pagesContainer = Expanded(
      child: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: SafeArea(child: page),
      ),
    );

    var btIcon = _adapterState == BluetoothAdapterState.on
        ? Icon(Icons.bluetooth_connected, color: Colors.blue)
        : Icon(Icons.bluetooth_disabled);

    var navigationContainer = BottomNavigationBar(
      items: [
        BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
        BottomNavigationBarItem(label: 'Favorites', icon: Icon(Icons.favorite)),
        BottomNavigationBarItem(label: '', icon: btIcon)
      ],
      currentIndex: selectedTabIndex,
      onTap: _onTabTapped,
    );

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(body: Column(children: [pagesContainer, navigationContainer]));
    });
  }

  void _onTabTapped(int tabIndex) {
    // Bluetooth tab
    if (tabIndex == 2) {
      turnOnBluetooth();
      return;
    }

    setState(() {
      selectedTabIndex = tabIndex;
    });
  }

  /// Turn on bluetooth and request permission if needed
  void turnOnBluetooth() async {
    var isGranted = await Permission.bluetooth.isGranted;
    print('Permission.bluetooth.isGranted: $isGranted');
    if (isGranted) {
      if (_adapterState == BluetoothAdapterState.off) {
        await FlutterBluePlus.turnOn();
      }
    } else {
      await Permission.bluetooth.onDeniedCallback(() {
        print('bluetooth.onDenied');
      }).onGrantedCallback(() async {
        print('bluetooth.onGranted');
        await FlutterBluePlus.turnOn();
      }).onPermanentlyDeniedCallback(() {
        print('bluetooth.onPermanentlyDenied');
      }).onRestrictedCallback(() {
        print('bluetooth.onRestricted');
      }).onLimitedCallback(() {
        print('bluetooth.onLimited');
      }).onProvisionalCallback(() {
        print('bluetooth.onProvisional');
      }).request();
    }
  }
}

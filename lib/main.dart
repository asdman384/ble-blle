import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:ble_blle/my_app_state.dart';
import 'package:ble_blle/pages/favorites_page.dart';
import 'package:ble_blle/pages/generator_page.dart';

void main() {
  runZonedGuarded(() {
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
        ? GeneratorPage()
        : selectedTabIndex == 1
            ? FavoritesPage()
            : Placeholder();

    Expanded pagesContainer = Expanded(
      child: Container(color: Theme.of(context).colorScheme.primaryContainer, child: page),
    );

    var btIcon = _adapterState == BluetoothAdapterState.on ? Icons.bluetooth_connected : Icons.bluetooth_disabled;
    var navigationContainer = BottomNavigationBar(
      items: [
        BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
        BottomNavigationBarItem(label: 'Favorites', icon: Icon(Icons.favorite)),
        BottomNavigationBarItem(label: '', icon: Icon(btIcon))
      ],
      currentIndex: selectedTabIndex,
      onTap: (value) async {
        // if (value == 2 && _adapterState == BluetoothAdapterState.off && await Permission.bluetooth.isGranted) {
        //   await FlutterBluePlus.turnOn();
        //   return;
        // }

        setState(() {
          selectedTabIndex = value;
        });
      },
    );

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(body: Column(children: [pagesContainer, navigationContainer]));
    });
  }
}

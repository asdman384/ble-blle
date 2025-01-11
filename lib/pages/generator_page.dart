import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:ble_blle/widgest/big_card.dart';
import 'package:ble_blle/my_app_state.dart';

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('GeneratorPage build');
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon = appState.hasPair(pair) ? Icons.favorite : Icons.favorite_border;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(
                  icon,
                  color: Colors.red,
                ),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Random'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  // if (!await Permission.bluetooth.isGranted) {
                  //   await Permission.bluetooth.onDeniedCallback(() {
                  //     print('bluetooth.onDenied');
                  //   }).onGrantedCallback(() {
                  //     print('bluetooth.onGranted');
                  //   }).onPermanentlyDeniedCallback(() {
                  //     print('bluetooth.onPermanentlyDenied');
                  //   }).onRestrictedCallback(() {
                  //     print('bluetooth.onRestricted');
                  //   }).onLimitedCallback(() {
                  //     print('bluetooth.onLimited');
                  //   }).onProvisionalCallback(() {
                  //     print('bluetooth.onProvisional');
                  //   }).request();
                  // }
                },
                child: Text('BT'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ble_blle/my_app_state.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var connectedDevices = appState.connectedDevices;

    if (appState.scanResults.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Connected to ${connectedDevices.length} device(s):'),
        ),
        for (var device in connectedDevices.values)
          ListTile(
            title: Text(device.advName),
            subtitle: Text(device.remoteId.str),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                appState.disconnect(device);
              },
            ),
          ),
      ],
    );
  }
}

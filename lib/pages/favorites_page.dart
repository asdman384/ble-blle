import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ble_blle/my_app_state.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ${appState.favorites.length} favorites:'),
        ),
        for (var pair in favorites)
          ListTile(
            title: Text(pair.asPascalCase),
            onTap: () {
              appState.current = pair;
            },
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import 'package:flex_color_picker/flex_color_picker.dart';

import 'package:ble_blle/my_app_state.dart';

class ControlllerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var connectedDevices = appState.connectedDevices;
    var theme = Theme.of(context);
    var style = theme.textTheme.bodyLarge!.copyWith(color: theme.colorScheme.onPrimaryContainer);

    if (appState.connectedDevices.isEmpty) {
      return Center(child: Text('No connected devices yet.', style: style));
    }

    String? currentCharacteristic;
    return ListView(
      children: [
        // title
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Connected to ${connectedDevices.length} device(s):'),
        ),

        // device list
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

        // characteristics dropdown
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownMenu<String>(
            controller: TextEditingController(),
            label: const Text('Characteristic'),
            onSelected: (String? characteristic) {
              currentCharacteristic = characteristic!;
              print('-----------------characteristic $characteristic');
            },
            dropdownMenuEntries: buildCharacteristicsItems(appState, connectedDevices),
          ),
        ),

        // color picker
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ColorPicker(
            width: 36,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            pickersEnabled: const <ColorPickerType, bool>{ColorPickerType.accent: false},
            showColorValue: true,
            showColorCode: true,
            colorCodeHasColor: true,
            crossAxisAlignment: CrossAxisAlignment.start,
            copyPasteBehavior: const ColorPickerCopyPasteBehavior(copyFormat: ColorPickerCopyFormat.hexRRGGBB),
            // // Use the screenPickerColor as start and active color.
            // color: screenPickerColor,
            heading: Text('Select color', style: Theme.of(context).textTheme.headlineSmall),
            subheading: Text('Select color shade', style: Theme.of(context).textTheme.titleSmall),
            // Update the screenPickerColor using the callback.
            onColorChanged: (color) {
              if (currentCharacteristic != null) {
                onColorChanged(appState, connectedDevices.values.first.remoteId.str, currentCharacteristic!, color);
              }
            },
          ),
        ),
      ],
    );
  }

  List<DropdownMenuEntry<String>> buildCharacteristicsItems(
      MyAppState appState, Map<String, BluetoothDevice> connectedDevices) {
    return connectedDevices.values.isEmpty
        ? []
        : appState
            .getCharacteristicsUuids(connectedDevices.values.first.remoteId.str)
            .map<DropdownMenuEntry<String>>((String characteristic) {
            return DropdownMenuEntry<String>(value: characteristic, label: characteristic);
          }).toList();
  }

  onColorChanged(MyAppState appState, String remoteId, String characteristic, Color color) {
    print('-----------------color ${color.hex} = ${color.red8bit}, ${color.green8bit}, ${color.blue8bit}');
    appState.write(remoteId, characteristic, [color.red8bit, color.green8bit, color.blue8bit]);
  }
}

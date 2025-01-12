import 'package:flutter/material.dart';

class Device extends StatelessWidget {
  const Device({
    super.key,
    required this.name,
    required this.mac,
    required this.rssi,
    required this.onTap, // Add this line
  });

  final String name;
  final String mac;
  final int rssi;
  final VoidCallback onTap; // Add this line

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onPrimary);

    return GestureDetector(
      onTap: onTap, // Add this line
      child: Container(
        width: double.infinity, // Make the container take full width
        child: Card(
          color: theme.colorScheme.primary,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : 'Unknown device',
                      style: style.copyWith(
                        fontWeight: FontWeight.bold,
                        color: name.isNotEmpty ? theme.colorScheme.onPrimary : Colors.grey,
                      ),
                    ),
                    Text(
                      mac,
                      style: style.copyWith(fontWeight: FontWeight.w200),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _getSignalIcon(rssi, theme.colorScheme.onPrimary),
                    SizedBox(width: 5),
                    Text('$rssi dBm', style: style),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Icon _getSignalIcon(int rssi, Color color) {
    if (rssi > -50) {
      return Icon(Icons.signal_cellular_alt, color: color);
    } else if (rssi > -80) {
      return Icon(Icons.signal_cellular_alt_2_bar, color: color);
    } else if (rssi > -100) {
      return Icon(Icons.signal_cellular_alt_1_bar, color: color);
    } else {
      return Icon(Icons.signal_cellular_null, color: color);
    }
  }
}

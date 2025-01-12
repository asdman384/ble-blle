import 'package:flutter/material.dart';

class Device extends StatelessWidget {
  const Device({
    super.key,
    required this.name,
    required this.mac,
  });

  final String name;
  final String mac;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onPrimary);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name.isNotEmpty ? name : 'Unknown device',
              style: style.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              mac,
              style: style.copyWith(fontWeight: FontWeight.w200),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../core/theme.dart';

class XbEmpty extends StatelessWidget {
  final String message;
  const XbEmpty({super.key, required this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 48, height: 1, color: kFg),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(width: 48, height: 1, color: kFg),
          ]),
        ),
      );
}

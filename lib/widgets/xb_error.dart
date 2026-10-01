import 'package:flutter/material.dart';
import '../core/theme.dart';

class XbError extends StatelessWidget {
  final String message;
  const XbError({super.key, required this.message});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration:
            BoxDecoration(border: Border.all(color: kWhite, width: 1)),
        child: Text(
          '⚠ $message',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      );
}

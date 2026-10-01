import 'package:flutter/material.dart';
import '../core/theme.dart';

class XbLabel extends StatelessWidget {
  final String text;
  const XbLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: kWhite),
      );
}

import 'package:flutter/material.dart';
import '../core/theme.dart';

class TrueDataBadge extends StatelessWidget {
  const TrueDataBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: kNeon),
        borderRadius: BorderRadius.circular(3),
      ),
      child: const Text(
        '✦ TRUE DATA',
        style: TextStyle(color: kNeon, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../core/theme.dart';

class TrueDataBadge extends StatelessWidget {
  const TrueDataBadge({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: kWhite, border: Border.all(color: kWhite, width: 1)),
        child: const Text(
          '✦ TRUE DATA',
          style: TextStyle(
              color: kBlack,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 2),
        ),
      );
}

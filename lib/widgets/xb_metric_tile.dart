import 'package:flutter/material.dart';
import '../core/theme.dart';

class XbMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final bool inverted;

  const XbMetricTile({
    super.key,
    required this.label,
    required this.value,
    this.inverted = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: inverted ? kWhite : kBlack,
          border: Border.all(color: kWhite, width: 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
              color: inverted ? kBlack : kWhite,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: inverted ? kBlack : kWhite,
            ),
          ),
        ]),
      );
}

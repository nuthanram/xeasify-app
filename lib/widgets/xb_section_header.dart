import 'package:flutter/material.dart';
import '../core/theme.dart';

class XbSectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const XbSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5),
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600),
              ),
            ),
        ]),
      );
}

import 'package:flutter/material.dart';
import '../core/theme.dart';

class XbLoader extends StatelessWidget {
  const XbLoader({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(color: kFg, strokeWidth: 1.5),
        ),
      );
}

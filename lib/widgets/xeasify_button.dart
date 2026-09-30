import 'package:flutter/material.dart';
import '../core/theme.dart';

class XeasifyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;

  const XeasifyButton({super.key, required this.label, this.onPressed, this.loading = false, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: kBlack))
        : Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1));

    if (outlined) {
      return OutlinedButton(onPressed: loading ? null : onPressed, child: child);
    }
    return ElevatedButton(onPressed: loading ? null : onPressed, child: child);
  }
}

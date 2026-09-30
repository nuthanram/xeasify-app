import 'package:flutter/material.dart';
import '../core/theme.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  static const _labels = {
    'draft': 'DRAFT',
    'escrow_pending': 'ESCROW PENDING',
    'active': 'ACTIVE',
    'in_review': 'IN REVIEW',
    'completed': 'COMPLETED',
    'disputed': 'DISPUTED',
    'submitted': 'SUBMITTED',
    'counter_offered': 'COUNTER OFFERED',
    'accepted': 'ACCEPTED',
    'rejected': 'REJECTED',
    'cooling': 'COOLING 48H',
    'settled': 'SETTLED',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: kGray600),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        _labels[status] ?? status.toUpperCase(),
        style: const TextStyle(color: kGray300, fontSize: 10, letterSpacing: 0.8),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../core/theme.dart';

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  static const _labels = {
    'draft': 'DRAFT',
    'escrow_pending': 'PENDING ESCROW',
    'active': 'ACTIVE',
    'in_review': 'IN REVIEW',
    'completed': 'COMPLETED',
    'disputed': 'DISPUTED',
    'submitted': 'SUBMITTED',
    'merchant_reviewing': 'REVIEWING',
    'counter_offered': 'COUNTERED',
    'accepted': 'ACCEPTED',
    'rejected': 'REJECTED',
    'withdrawn': 'WITHDRAWN',
    'funded': 'FUNDED',
    'cooling': 'COOLING 48H',
    'verification_pass': 'VERIFIED',
    'payout_queued': 'PAYOUT QUEUED',
    'settled': 'SETTLED',
    'flash': 'FLASH',
    'cancelled': 'CANCELLED',
  };

  static const _positive = {
    'active',
    'accepted',
    'settled',
    'completed',
    'verification_pass',
    'payout_queued',
  };

  @override
  Widget build(BuildContext context) {
    final key = status.toLowerCase();
    final label = _labels[key] ?? status.toUpperCase();
    final inverted = _positive.contains(key);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: inverted ? kFg : kBg,
        border: Border.all(color: kFg, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: inverted ? kBg : kFg,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

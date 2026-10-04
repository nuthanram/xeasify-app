import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import 'status_chip.dart';

class CampaignCard extends StatelessWidget {
  final Map<String, dynamic> campaign;
  final VoidCallback onTap;

  const CampaignCard({super.key, required this.campaign, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final budget =
        '₹${double.tryParse(campaign['budget_per_creator']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0'}';
    final deliverable = (campaign['deliverable_type'] as String? ?? '')
        .toUpperCase()
        .replaceAll('_', ' ');
    final isFlash = campaign['is_flash_campaign'] == true;
    final status = campaign['status'] as String? ?? '';

    return Material(
      color: kBg,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 1),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(border: Border.all(color: kFg, width: 1)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                    child: Text(
                  campaign['title'] ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      height: 1.2),
                )),
                if (isFlash) ...[
                  const SizedBox(width: 8),
                  const StatusChip(status: 'flash'),
                ],
              ]),
              const SizedBox(height: 12),
              Text(
                campaign['description'] ?? '',
                style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    height: 1.5),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('PER CREATOR',
                      style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w400)),
                  Text(budget,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1)),
                ]),
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Text('FORMAT',
                      style:
                          TextStyle(fontSize: 9, letterSpacing: 1.5)),
                  const SizedBox(height: 2),
                  Text(deliverable,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1)),
                  if (status.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    StatusChip(status: status),
                  ],
                ]),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

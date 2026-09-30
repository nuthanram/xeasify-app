import 'package:flutter/material.dart';
import '../core/theme.dart';

class CampaignCard extends StatelessWidget {
  final Map<String, dynamic> campaign;
  final VoidCallback onTap;

  const CampaignCard({super.key, required this.campaign, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kGray900,
          border: Border.all(color: kGray700),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(campaign['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ),
                if (campaign['is_flash_campaign'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(border: Border.all(color: kGray600), borderRadius: BorderRadius.circular(3)),
                    child: const Text('FLASH', style: TextStyle(fontSize: 9, color: kGray300, letterSpacing: 1)),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(campaign['description'] ?? '', style: TextStyle(color: kGray400, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Text('₹${campaign['budget_per_creator']}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

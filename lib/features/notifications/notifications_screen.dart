import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../data/notifications_repository.dart';
import '../../models/notification_item.dart';
import '../../widgets/xb_loader.dart';
import '../../widgets/xb_empty.dart';
import '../../widgets/xb_error.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _State();
}

class _State extends ConsumerState<NotificationsScreen> {
  List<NotificationItem> _notifs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data =
          await ref.read(notificationsRepoProvider).getHistory();
      if (mounted) setState(() { _notifs = data; _loading = false; });
    } catch (_) {
      if (mounted)
        setState(() { _error = 'Failed to load notifications.'; _loading = false; });
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'proposal_accepted':
        return Icons.check_circle_outline;
      case 'counter_offer':
        return Icons.swap_horiz_outlined;
      case 'proposal_rejected':
        return Icons.cancel_outlined;
      case 'payout':
        return Icons.account_balance_wallet_outlined;
      case 'flash_campaign':
        return Icons.bolt_outlined;
      case 'campaign_funded':
        return Icons.lock_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ALERTS')),
      body: _loading
          ? const XbLoader()
          : _error != null
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: XbError(message: _error!))
              : _notifs.isEmpty
                  ? const XbEmpty(message: 'No notifications yet.')
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: kWhite,
                      backgroundColor: kBlack,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                        itemCount: _notifs.length,
                        itemBuilder: (_, i) {
                          final n = _notifs[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 1),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: kWhite, width: 1)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(_iconFor(n.notificationType),
                                    color: kWhite, size: 18),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Expanded(
                                            child: Text(
                                              n.notificationType
                                                  .toUpperCase()
                                                  .replaceAll('_', ' '),
                                              style: const TextStyle(
                                                  fontSize: 9,
                                                  letterSpacing: 1.5,
                                                  fontWeight:
                                                      FontWeight.w700),
                                            ),
                                          ),
                                          Text(
                                            _formatTime(n.queuedAt),
                                            style: const TextStyle(
                                                fontSize: 9,
                                                letterSpacing: 0.5),
                                          ),
                                        ]),
                                        const SizedBox(height: 4),
                                        Text(
                                          n.title,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              height: 1.3),
                                        ),
                                        if (n.body.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            n.body,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                                height: 1.5),
                                          ),
                                        ],
                                      ]),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

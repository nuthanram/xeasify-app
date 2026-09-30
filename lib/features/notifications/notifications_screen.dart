import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/dio_client.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _State();
}

class _State extends ConsumerState<NotificationsScreen> {
  List<Map<String, dynamic>> _notifs = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final res = await ref.read(dioProvider).get('/notifications/history/');
    if (mounted) setState(() { _notifs = List<Map<String, dynamic>>.from(res.data); _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NOTIFICATIONS')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kWhite, strokeWidth: 2))
          : _notifs.isEmpty
              ? Center(child: Text('No notifications.', style: TextStyle(color: kGray400, fontSize: 13)))
              : ListView.builder(
                  itemCount: _notifs.length,
                  itemBuilder: (_, i) {
                    final n = _notifs[i];
                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: kGray900, border: Border.all(color: kGray800), borderRadius: BorderRadius.circular(4)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(n['body'] ?? '', style: TextStyle(color: kGray300, fontSize: 12)),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

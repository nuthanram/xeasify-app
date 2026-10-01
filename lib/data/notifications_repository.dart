import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/dio_client.dart';
import '../models/notification_item.dart';

class NotificationsRepository {
  final Dio _dio;
  NotificationsRepository(this._dio);

  Future<List<NotificationItem>> getHistory() async {
    final res = await _dio.get('/notifications/history/');
    return (res.data as List)
        .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final notificationsRepoProvider = Provider<NotificationsRepository>(
    (ref) => NotificationsRepository(ref.read(dioProvider)));

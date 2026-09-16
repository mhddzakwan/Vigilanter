import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type;
  final String reportId;
  final String tempat;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.reportId,
    required this.tempat,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  factory NotificationItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return NotificationItem(
      id: doc.id,
      title: data['title'],
      message: data['message'],
      type: data['type'],
      reportId: data['report_id'],
      tempat: data['tempat'],
      latitude: double.parse(data['latitude']),
      longitude: double.parse(data['longitude']),
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  String get formattedTime {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} '
        '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}

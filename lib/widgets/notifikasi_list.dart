import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vigilanter_flutter/models/notification_model.dart';
import 'package:vigilanter_flutter/services/firebase_service.dart';
import '../services/app_navigator.dart';

class NotifikasiList extends StatefulWidget {
  const NotifikasiList({Key? key}) : super(key: key);

  @override
  State<NotifikasiList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotifikasiList> {
  final FirebaseService _firebaseService = FirebaseService();

  /// Format waktu → “Sabtu, 30 Agustus 2025 (14:32:46 WIB)”  
  String getFormattedTime(DateTime dt) {
    final formatter = DateFormat("EEEE, d MMMM y (HH:mm:ss 'WIB')", "id_ID");
    return formatter.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).size.width * 0.04;
    final crossSize = MediaQuery.of(context).size.width * 0.04;
    final fontTitleSize = MediaQuery.of(context).size.width * 0.042;
    final fontMessageSize = MediaQuery.of(context).size.width * 0.034;

    return StreamBuilder<List<NotificationItem>>(
      stream: _firebaseService.getNotifications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada notifikasi',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final notifications = snapshot.data!;

        return ListView.builder(
          padding: EdgeInsets.all(padding),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];

            return GestureDetector(
              onTap: () {
                AppNavigator.toMap(
                  latLng: LatLng(
                    notification.latitude,
                    notification.longitude,
                  ),
                  reportId: notification.reportId,
                );
              },
              child: Container(
                margin: EdgeInsets.only(bottom: padding),
                padding: EdgeInsets.only(
                  bottom: padding,
                  top: padding,
                  left: padding * 1.7,
                  right: padding * 0.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1234),
                  borderRadius: BorderRadius.circular(padding * 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontTitleSize,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // _firebaseService
                            //     .deleteNotification(notification.id);
                          },
                          child: Icon(
                            Icons.close_rounded,
                            size: crossSize,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: padding * 0.45),

                    // Message
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: fontMessageSize,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: padding * 0.35),

                    // Time
                    Text(
                      getFormattedTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: fontMessageSize,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

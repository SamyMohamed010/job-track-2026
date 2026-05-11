import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../app_localization.dart';

class NotificationSheet extends StatelessWidget {
  const NotificationSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => const NotificationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = appLocalization.locale.languageCode == 'ar';
    final Color primaryBlue = const Color(0xFF1E3A5F);
    final Color primaryBlueLight = const Color(0xFF229BD8);
    final Color grayBg = const Color(0xFFEBEEF4);
    final Color grayText = const Color(0xFF7E848E);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        padding: const EdgeInsets.all(24),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr ? "الإشعارات" : "Notifications",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .where(
                      'targetId',
                      isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        isAr ? "لا توجد إشعارات" : "No notifications",
                        style: TextStyle(color: grayText),
                      ),
                    );
                  }

                  final notificationsList = snapshot.data!.docs.toList();
                  notificationsList.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aTime = aData['createdAt'] as Timestamp?;
                    final bTime = bData['createdAt'] as Timestamp?;
                    if (aTime == null || bTime == null) return 0;
                    return bTime.compareTo(aTime);
                  });

                  return ListView.builder(
                    itemCount: notificationsList.length,
                    itemBuilder: (context, index) {
                      var doc = notificationsList[index];
                      var data = doc.data() as Map<String, dynamic>;
                      
                      String timeStr = "";
                      if (data['createdAt'] != null) {
                        final date = (data['createdAt'] as Timestamp).toDate();
                        timeStr = "${date.day} ${[
                          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                        ][date.month - 1]}";
                      }

                      return _buildNotificationItem(
                        context,
                        title: data['title'] ?? 'Notification',
                        subtitle: data['message'] ?? '',
                        icon: data['type'] == 'application_status' ? Icons.work_outline : Icons.notifications_none,
                        logoUrl: data['companyLogoUrl'],
                        time: timeStr,
                        primaryBlue: primaryBlue,
                        primaryBlueLight: primaryBlueLight,
                        grayBg: grayBg,
                        grayText: grayText,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String time,
    String? logoUrl,
    required Color primaryBlue,
    required Color primaryBlueLight,
    required Color grayBg,
    required Color grayText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: grayBg,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: logoUrl != null && logoUrl.isNotEmpty
                  ? Image.network(
                      logoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(icon, color: primaryBlueLight, size: 20),
                    )
                  : Icon(icon, color: primaryBlueLight, size: 20),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                    ),
                    if (time.isNotEmpty)
                      Text(
                        time,
                        style: TextStyle(color: grayText, fontSize: 10),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: grayText, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

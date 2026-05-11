import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';

void showCompanyNotifications(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return const CompanyNotificationSheetContent();
    },
  );
}

class CompanyNotificationSheetContent extends StatelessWidget {
  const CompanyNotificationSheetContent({super.key});

  Stream<List<Map<String, dynamic>>> _getSmartNotificationsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    // 1. Applications Stream
    final appsStream = FirebaseFirestore.instance
        .collection('applications')
        .where('companyId', isEqualTo: user.uid)
        .snapshots();

    // 2. Jobs Stream (for approval status and deadlines)
    final jobsStream = FirebaseFirestore.instance
        .collection('jobs')
        .where('companyId', isEqualTo: user.uid)
        .snapshots();

    // 3. Direct Notifications Stream
    final directNotifsStream = FirebaseFirestore.instance
        .collection('notifications')
        .where('targetId', isEqualTo: user.uid)
        .snapshots();

    return Rx.combineLatest3(
      appsStream,
      jobsStream,
      directNotifsStream,
      (QuerySnapshot appSnap, QuerySnapshot jobSnap, QuerySnapshot directSnap) {
        List<Map<String, dynamic>> items = [];

        // Process Applications -> "New Application Received"
        for (var doc in appSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['status'] == 'Applied') {
            items.add({
              'id': doc.id,
              'type': 'new_application',
              'title': 'New Application Received',
              'message': 'A new student has applied for the ${data['jobTitle'] ?? 'position'}.',
              'createdAt': data['appliedAt'] ?? Timestamp.now(),
              'icon': Icons.person_add_alt_1_outlined,
              'color': const Color(0xFF229BD8),
            });
          }
        }

        // Process Jobs -> "Job Approved" and "Deadline Reminder"
        final now = DateTime.now();
        for (var doc in jobSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] as String?;
          final title = data['title'] ?? 'Job';
          
          if (status == 'approved') {
            items.add({
              'id': '${doc.id}_approved',
              'type': 'job_approved',
              'title': 'Job Approved',
              'message': 'Your job post "$title" has been reviewed and is now live.',
              'createdAt': data['createdAt'] ?? Timestamp.now(),
              'icon': Icons.verified_outlined,
              'color': Colors.green,
            });
          }

          // Deadline Reminder (within 3 days)
          final deadlineStr = data['deadline'] as String?;
          if (deadlineStr != null && deadlineStr.isNotEmpty) {
            try {
              final deadline = DateFormat('yyyy-MM-dd').parse(deadlineStr);
              final diff = deadline.difference(now).inDays;
              if (diff >= 0 && diff <= 3) {
                items.add({
                  'id': '${doc.id}_deadline',
                  'type': 'deadline_reminder',
                  'title': 'Deadline Reminder',
                  'message': 'Your job post "$title" will expire in $diff days.',
                  'createdAt': Timestamp.now(), // High priority, show now
                  'icon': Icons.timer_outlined,
                  'color': const Color(0xFFFDA00C),
                });
              }
            } catch (e) {
              // Ignore parse errors
            }
          }
        }

        // Process Direct Notifications
        for (var doc in directSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          items.add({
            'id': doc.id,
            'type': 'direct',
            'title': data['title'] ?? 'Notification',
            'message': data['message'] ?? '',
            'createdAt': data['createdAt'] ?? Timestamp.now(),
            'icon': _getIconForType(data['type']),
            'color': _getColorForType(data['type']),
          });
        }

        // Sort by createdAt
        items.sort((a, b) {
          final aTime = a['createdAt'] as Timestamp;
          final bTime = b['createdAt'] as Timestamp;
          return bTime.compareTo(aTime);
        });

        return items;
      },
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'shortlist': return Icons.star_border_rounded;
      case 'message': return Icons.chat_bubble_outline_rounded;
      case 'interview': return Icons.event_available_outlined;
      default: return Icons.notifications_none_rounded;
    }
  }

  Color _getColorForType(String? type) {
    switch (type) {
      case 'shortlist': return Colors.amber;
      case 'message': return Colors.purple;
      case 'interview': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            "Notifications",
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getSmartNotificationsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text(
                          "No notifications yet",
                          style: TextStyle(color: Color(0xFF7E848E), fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final data = items[index];
                    return _buildNotificationItem(
                      title: data['title'],
                      message: data['message'],
                      icon: data['icon'],
                      color: data['color'],
                      time: _formatTimestamp(data['createdAt']),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return DateFormat('dd MMM').format(date);
  }

  Widget _buildNotificationItem({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEEF4).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 8, spreadRadius: 1)
              ],
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E3A5F)),
                    ),
                    Text(
                      time,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(color: Color(0xFF7E848E), fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


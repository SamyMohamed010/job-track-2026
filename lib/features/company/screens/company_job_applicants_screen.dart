import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'company_notifications_sheet.dart';

class CompanyJobApplicantsScreen extends StatelessWidget {
  final String jobId;
  final String jobTitle;

  const CompanyJobApplicantsScreen({
    super.key, 
    required this.jobId, 
    required this.jobTitle
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEEF4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFDA00C), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          jobTitle,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFFFDA00C)),
            onPressed: () => showCompanyNotifications(context),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('jobId', isEqualTo: jobId)
            .orderBy('appliedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final apps = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final appData = apps[index].data() as Map<String, dynamic>;
              final appId = apps[index].id;
              return _buildApplicantCard(context, appId, appData);
            },
          );
        },
      ),
    );
  }

  Widget _buildApplicantCard(BuildContext context, String appId, Map<String, dynamic> data) {
    final String studentId = data['studentId'] ?? '';
    final String status = data['status'] ?? 'Pending';
    final String companyName = data['companyName'] ?? 'The Company';

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(studentId).get(),
      builder: (context, studentSnapshot) {
        String studentName = "Loading...";
        if (studentSnapshot.hasData && studentSnapshot.data!.exists) {
          final sData = studentSnapshot.data!.data() as Map<String, dynamic>;
          studentName = sData['name'] ?? "Unknown Student";
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFEBEEF4),
                    child: Icon(Icons.person, color: Color(0xFF229BD8)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(status, style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              if (status == 'Pending') ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _updateStatus(context, appId, studentId, companyName, 'Rejected'),
                      child: const Text("Reject", style: TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _updateStatus(context, appId, studentId, companyName, 'Accepted'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF229BD8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Accept", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepted': return Colors.green;
      case 'Rejected': return Colors.red;
      case 'Pending': return Colors.orange;
      default: return Colors.grey;
    }
  }

  Future<void> _updateStatus(BuildContext context, String appId, String studentId, String companyName, String newStatus) async {
    try {
      // 1. Update Application Status
      await FirebaseFirestore.instance.collection('applications').doc(appId).update({
        'status': newStatus,
      });

      // 2. Create Notification for Student
      await FirebaseFirestore.instance.collection('notifications').add({
        'targetId': studentId,
        'targetType': 'student',
        'title': newStatus == 'Accepted' ? 'Application Accepted' : 'Application Rejected',
        'message': 'Your application for $jobTitle has been $newStatus by $companyName.',
        'type': 'application_status',
        'status': newStatus,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Application $newStatus")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 15.0),
                child: Icon(Icons.people, size: 80, color: Color(0xFFB0B5BD)),
              ),
              const Positioned(
                top: -5,
                child: Icon(Icons.school, size: 40, color: Color(0xFFB0B5BD)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "No applicants yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7E848E),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'company_notifications_sheet.dart';
import 'company_student_profile_view.dart';


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
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final apps = snapshot.data!.docs.toList();
          apps.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = aData['appliedAt'] as Timestamp?;
            final bTime = bData['appliedAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

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
        String profileImageUrl = "";
        String faculty = "";

        if (studentSnapshot.hasData && studentSnapshot.data!.exists) {
          final sData = studentSnapshot.data!.data() as Map<String, dynamic>;
          studentName = sData['name'] ?? "Unknown Student";
          profileImageUrl = sData['profileImageUrl'] ?? sData['imageUrl'] ?? "";
          faculty = sData['faculty'] ?? sData['specialty'] ?? "";
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFEBEEF4),
                backgroundImage: profileImageUrl.isNotEmpty ? NetworkImage(profileImageUrl) : null,
                child: profileImageUrl.isEmpty ? const Icon(Icons.person, color: const Color(0xFF229BD8)) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (faculty.isNotEmpty)
                      Text(faculty, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CompanyStudentProfileView(studentId: studentId),
                          ),
                        );
                      },
                      child: const Icon(Icons.remove_red_eye, color: Color(0xFF229BD8), size: 22),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(status, style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 5),
                  PopupMenuButton<String>(
                    onSelected: (newStatus) {
                      if (newStatus == 'Interview Scheduled') {
                        _showInterviewDialog(context, appId, studentId, companyName);
                      } else {
                        _updateStatus(context, appId, studentId, companyName, newStatus);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'Under Review', child: Text('Under Review')),
                      const PopupMenuItem(value: 'Interview Scheduled', child: Text('Interview Scheduled')),
                      const PopupMenuItem(value: 'Accepted', child: Text('Accepted')),
                      const PopupMenuItem(value: 'Rejected', child: Text('Rejected')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF229BD8).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Update", style: TextStyle(color: Color(0xFF229BD8), fontSize: 12, fontWeight: FontWeight.bold)),
                          Icon(Icons.arrow_drop_down, color: Color(0xFF229BD8), size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
      case 'Applied':
      case 'Pending': return Colors.blue;
      case 'Under Review': return Colors.orange;
      case 'Interview Scheduled': return Colors.purple;
      default: return Colors.grey;
    }
  }

  Future<void> _updateStatus(BuildContext context, String appId, String studentId, String companyName, String newStatus, {String? interviewDate, String? interviewLocation}) async {
    try {
      Map<String, dynamic> updateData = {'status': newStatus};
      if (interviewDate != null) updateData['interviewDate'] = interviewDate;
      if (interviewLocation != null) updateData['interviewLocation'] = interviewLocation;

      await FirebaseFirestore.instance.collection('applications').doc(appId).update(updateData);

      String notifTitle = 'Application Update';
      String notifMessage = 'Your application status for $jobTitle has been updated to $newStatus by $companyName.';
      
      if (newStatus == 'Interview Scheduled') {
        notifTitle = 'Interview Scheduled';
        notifMessage = 'An interview for $jobTitle has been scheduled on $interviewDate. Location/Link: $interviewLocation.';
      } else if (newStatus == 'Accepted') {
        notifTitle = 'Application Accepted';
        notifMessage = 'Congratulations! Your application for $jobTitle has been accepted by $companyName.';
      } else if (newStatus == 'Rejected') {
        notifTitle = 'Application Rejected';
      }

      await FirebaseFirestore.instance.collection('notifications').add({
        'targetId': studentId,
        'targetType': 'student',
        'title': notifTitle,
        'message': notifMessage,
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

  void _showInterviewDialog(BuildContext context, String appId, String studentId, String companyName) {
    final dateController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Schedule Interview"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: "Date & Time (e.g. 15 Oct, 10:00 AM)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: "Location or Link"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (dateController.text.isNotEmpty && locationController.text.isNotEmpty) {
                Navigator.pop(ctx);
                _updateStatus(context, appId, studentId, companyName, 'Interview Scheduled', 
                  interviewDate: dateController.text, 
                  interviewLocation: locationController.text);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF229BD8)),
            child: const Text("Schedule", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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

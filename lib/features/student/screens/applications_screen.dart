import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'job_details_screen.dart';
import '../../../app_localization.dart';
import '../../localization.dart';
import '../../../widgets/student_app_bar.dart';
// import 'profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';


class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});
  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  String selectedFilter = "All";

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepted':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return AnimatedBuilder(
      animation: appLocalization,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFEBEEF4),
          appBar: StudentAppBar(
            showLogout: true,
            onNotificationPressed: () => _showNotificationsSheet(context),
          ),
          body: Column(
            children: [
              Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ["All", "Accepted", "Rejected", "Pending"].map((f) {
                    bool isS = selectedFilter == f;
                    return TextButton(
                      onPressed: () => setState(() => selectedFilter = f),
                      child: Column(
                        children: [
                          Text(
                            AppLocale.tr(context, f),
                            style: TextStyle(
                              color: isS
                                  ? const Color(0xFF229BD8)
                                  : const Color(0xFF7E848E),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isS)
                            Container(
                              height: 2,
                              width: 20,
                              color: const Color(0xFF229BD8),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('applications')
                      .where('studentId', isEqualTo: user?.uid)
                      .orderBy('appliedAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          AppLocale.tr(context, "No applications found"),
                        ),
                      );
                    }

                    var docs = snapshot.data!.docs;
                    if (selectedFilter != "All") {
                      docs = docs
                          .where((d) => d['status'] == selectedFilter)
                          .toList();
                    }

                    if (docs.isEmpty) {
                      return Center(
                        child: Text(
                          AppLocale.tr(context, "No applications found"),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        var data = docs[i].data() as Map<String, dynamic>;
                        return _buildCard(data);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(context),
        );
      },
    );
  }

  Widget _buildCard(Map<String, dynamic> app) {
    final status = app['status'] ?? 'Pending';
    final color = _getStatusColor(status);
    final date = app['appliedAt'] != null
        ? DateFormat(
            'MMMM dd, yyyy',
          ).format((app['appliedAt'] as Timestamp).toDate())
        : 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFEBEEF4),
                child: Icon(Icons.business, color: Color(0xFF229BD8)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocale.tr(context, app['jobTitle'] ?? 'Job'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      AppLocale.tr(context, app['companyName'] ?? 'Company'),
                      style: const TextStyle(
                        color: Color(0xFF7E848E),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppLocale.tr(context, status),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${AppLocale.tr(context, 'Applied on ')}${AppLocale.tr(context, date)}",
                style: const TextStyle(color: Color(0xFF7E848E), fontSize: 12),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Fetch job details to pass to screen
                  final jobDoc = await FirebaseFirestore.instance
                      .collection('jobs')
                      .doc(app['jobId'])
                      .get();
                  if (jobDoc.exists && mounted) {
                    final jobData = jobDoc.data()!;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => JobDetailsScreen(
                          jobId: app['jobId'],
                          companyId: app['companyId'],
                          title: jobData['title'] ?? '',
                          company: jobData['companyName'] ?? '',
                          logoUrl: jobData['companyLogoUrl'] ?? '',
                          location: jobData['location'] ?? '',
                          description: jobData['description'] ?? '',
                          requirements: jobData['requirements'] ?? '',
                          jobType: jobData['jobType'] ?? '',
                          salaryFrom: jobData['salaryFrom'] ?? '',
                          salaryTo: jobData['salaryTo'] ?? '',
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF229BD8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  AppLocale.tr(context, "View Job"),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocale.tr(context, "Notifications"),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A5F),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildNotificationItem(
                      context,
                      title: AppLocale.tr(context, "Application Accepted"),
                      subtitle: AppLocale.tr(
                        context,
                        "Your application for Google has been accepted.",
                      ),
                      icon: Icons.remove_red_eye,
                      time: "2h",
                    ),
                    _buildNotificationItem(
                      context,
                      title: AppLocale.tr(context, "New Job Alert"),
                      subtitle: AppLocale.tr(
                        context,
                        "A new 'Flutter Developer' job was posted.",
                      ),
                      icon: Icons.work_outline,
                      time: "5h",
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEEF4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications,
              color: Color(0xFF229BD8),
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF7E848E),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    bool isAr = appLocalization.locale.languageCode == 'ar';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Directionality(
          textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: BottomNavigationBar(
            currentIndex: 0,
            onTap: (index) {
              if (index == 1) {
                Navigator.pushReplacementNamed(context, '/student_home');
              } else if (index == 2) {
                Navigator.pushReplacementNamed(context, '/student_profile');
              }
            },
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF229BD8),
            unselectedItemColor: const Color(0xFF1E3A5F).withOpacity(0.5),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            items: [
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 5.0),
                  child: Icon(CupertinoIcons.doc_text),
                ),
                label: AppLocale.tr(context, isAr ? "الطلبات" : "Applications"),
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 5.0),
                  child: Icon(CupertinoIcons.home),
                ),
                label: AppLocale.tr(context, isAr ? "الرئيسية" : "Home"),
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 5.0),
                  child: Icon(CupertinoIcons.person),
                ),
                label: AppLocale.tr(context, isAr ? "الملف الشخصي" : "Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

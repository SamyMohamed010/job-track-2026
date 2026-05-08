import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../company_data.dart';
import 'company_edit_profile_screen.dart';
import 'company_job_applicants_screen.dart';
import 'company_edit_job_screen.dart';
import 'company_notifications_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  _CompanyProfileScreenState createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final data = CompanyData();
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: const Color(0xFFEBEEF4),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Logo Placeholder (Top Left)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, color: Color(0xFF229BD8), size: 20),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Confirm Logout / تأكيد الخروج", style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
                              content: const Text("Are you sure you want to log out?\nهل أنت متأكد من تسجيل الخروج؟"),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel / إلغاء", style: TextStyle(color: Color(0xFF7E848E))),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, elevation: 0),
                                  child: const Text("Logout / خروج", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Icon(Icons.logout, color: Color(0xFF7E848E), size: 22),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => showCompanyNotifications(context),
                        child: const Icon(Icons.notifications, color: Color(0xFFFDA00C)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Company Logo (Center)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1E3A8A), // Dark blue
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: data.logoImage != null
                          ? ClipOval(
                              child: kIsWeb
                                  ? Image.network(data.logoImage!.path, fit: BoxFit.cover, width: 80, height: 80)
                                  : Image.file(File(data.logoImage!.path), fit: BoxFit.cover, width: 80, height: 80),
                            )
                          : (data.logoUrl != null && data.logoUrl!.isNotEmpty)
                              ? ClipOval(
                                  child: Image.network(data.logoUrl!, fit: BoxFit.cover, width: 80, height: 80),
                                )
                              : Center(
                                  child: Text(
                                    data.name.isNotEmpty ? data.name[0].toUpperCase() : "S", 
                                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)
                                  ),
                                ),
                    ),
                    const SizedBox(height: 12),

                    // Company Name
                    Text(
                      data.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Industry
                    Text(
                      data.industry,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7E848E),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Location
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          data.location,
                          style: const TextStyle(color: Color(0xFF7E848E), fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Website
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.language, color: Color(0xFF7E848E), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          data.website,
                          style: const TextStyle(color: Color(0xFF7E848E), fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // About Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "About ${data.name}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data.overview,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7E848E),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Edit Profile Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CompanyEditProfileScreen()),
                          );
                          if (result == true) {
                            _refresh();
                          }
                        },
                        icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                        label: const Text(
                          "Edit Profile",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF229BD8),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Divider
                    const Divider(color: Colors.grey, thickness: 0.5),
                    const SizedBox(height: 20),

                    // Jobs List from Firestore
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('jobs')
                          .where('companyId', isEqualTo: user?.uid)
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Column(
                            children: const [
                              Icon(Icons.work_outline, size: 60, color: Color(0xFFB0B5BD)),
                              SizedBox(height: 12),
                              Text("No jobs yet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF7E848E))),
                            ],
                          );
                        }

                        final jobs = snapshot.data!.docs;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Posted Jobs",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            const SizedBox(height: 16),
                            ...jobs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final job = JobModel(
                                id: doc.id,
                                title: data['title'] ?? '',
                                description: data['description'] ?? '',
                                requirements: data['requirements'] ?? '',
                                location: data['location'] ?? '',
                                locationType: data['locationType'] ?? '',
                                jobType: data['jobType'] ?? '',
                                salaryFrom: data['salaryFrom'] ?? '',
                                salaryTo: data['salaryTo'] ?? '',
                                deadline: data['deadline'] ?? '',
                              );
                              return buildJobCard(job);
                            }),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildJobCard(JobModel job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                job.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF229BD8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  job.jobType,
                  style: const TextStyle(
                    color: Color(0xFF229BD8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
              const SizedBox(width: 4),
              Text(
                "${job.location} (${job.locationType})",
                style: const TextStyle(color: Color(0xFF7E848E), fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  job.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF7E848E), fontSize: 14),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final index = CompanyData().jobs.indexOf(job);
                  if (index != -1) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompanyEditJobScreen(job: job, jobIndex: index),
                      ),
                    );
                    if (result == true) {
                      _refresh();
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF229BD8)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.edit, color: Color(0xFF229BD8), size: 14),
                      SizedBox(width: 4),
                      Text("Edit", style: TextStyle(color: Color(0xFF229BD8), fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.black12, thickness: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Deadline: ${job.deadline}",
                style: const TextStyle(color: Color(0xFFFDA00C), fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                "\$${job.salaryFrom} - \$${job.salaryTo}",
                style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Delete Button
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Delete Job"),
                      content: const Text("Are you sure you want to delete this job?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            CompanyData().jobs.remove(job);
                            Navigator.pop(context);
                            _refresh();
                          },
                          child: const Text("Delete", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.delete_outline, color: Colors.red, size: 16),
                      SizedBox(width: 4),
                      Text("Delete", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // View Applicants Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompanyJobApplicantsScreen(jobId: job.id ?? '', jobTitle: job.title),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF229BD8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.people_outline, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text("View", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

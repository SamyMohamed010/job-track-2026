import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app_localization.dart';

class CompanyStudentProfileView extends StatelessWidget {
  final String studentId;

  const CompanyStudentProfileView({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appLocalization,
      builder: (context, child) {
        bool isAr = appLocalization.locale.languageCode == 'ar';
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
              isAr ? "الملف الشخصي للطالب" : "Student Profile", 
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)
            ),
          ),
          body: Directionality(
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(studentId).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text(isAr ? "خطأ في تحميل الملف الشخصي" : "Error loading profile"));
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final name = data['name'] ?? (isAr ? 'غير معروف' : 'Unknown');
                final profileImageUrl = data['profileImageUrl'] ?? data['imageUrl'] ?? '';
                final isVerified = data['isVerified'] ?? false;
                final faculty = data['faculty'] ?? '';
                final specialty = data['specialty'] ?? '';
                final program = data['program'] ?? '';
                final graduationYear = data['graduationYear'] ?? '';
                final email = data['email'] ?? '';
                final skills = List<String>.from(data['skills'] ?? []);
                final cvUrl = data['cvUrl'] ?? ''; // Might not be available yet if student didn't upload

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildProfileHeader(name, profileImageUrl, isVerified, faculty, specialty, program, graduationYear, email, isAr),
                      const SizedBox(height: 30),
                      const Divider(indent: 50, endIndent: 50, thickness: 1),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildSkillsSection(skills, isAr)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildCVSection(context, cvUrl, isAr)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    );
  }

  Widget _buildProfileHeader(String name, String profileImageUrl, bool isVerified, String faculty, String specialty, String program, String graduationYear, String email, bool isAr) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFFEBEEF4),
            backgroundImage: profileImageUrl.isNotEmpty ? NetworkImage(profileImageUrl) : null,
            child: profileImageUrl.isEmpty ? const Icon(Icons.person, size: 60, color: Color(0xFF229BD8)) : null,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            if (isVerified) ...[
              const SizedBox(width: 8),
              const Icon(Icons.verified, color: Colors.blue, size: 20),
            ],
          ],
        ),
        const SizedBox(height: 10),
        if (faculty.isNotEmpty) Text(faculty, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
        if (specialty.isNotEmpty) Text(specialty, style: const TextStyle(color: Colors.grey)),
        if (program.isNotEmpty) Text("${isAr ? 'البرنامج' : 'Program'}: $program", style: const TextStyle(color: Colors.grey, fontSize: 13)),
        if (graduationYear.isNotEmpty) Text("${isAr ? 'السنة' : 'Year'}: $graduationYear", style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 5),
        if (email.isNotEmpty) Text(email, style: const TextStyle(color: Colors.blueGrey, fontSize: 13)),
      ],
    );
  }

  Widget _buildSkillsSection(List<String> skills, bool isAr) {
    return Column(
      children: [
        Text(isAr ? "المهارات" : "Skills", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: skills.isEmpty 
              ? Text(isAr ? "لا توجد مهارات" : "No skills added", style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center)
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: skills.map((skill) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(skill, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                  )).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildCVSection(BuildContext context, String cvUrl, bool isAr) {
    return Column(
      children: [
        Text(isAr ? "السيرة الذاتية" : "CV", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          height: 100,
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.description, size: 40, color: Colors.grey.shade400),
              if (cvUrl.isNotEmpty)
                Positioned(
                  top: 0,
                  child: Text(isAr ? "ملف CV" : "CV File", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ),
              Positioned(
                bottom: 5,
                left: 10,
                child: GestureDetector(
                  onTap: () async {
                    if (cvUrl.isNotEmpty) {
                      final uri = Uri.parse(cvUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? "لا يمكن فتح الملف" : "Could not open CV")));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(isAr ? "لم يتم رفع سيرة ذاتية" : "No CV uploaded yet"), 
                        backgroundColor: Colors.orange
                      ));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF229BD8).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.visibility, color: Color(0xFF229BD8), size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

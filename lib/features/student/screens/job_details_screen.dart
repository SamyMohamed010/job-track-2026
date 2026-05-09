import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/student_service.dart';
import '../../../app_localization.dart';
import '../../localization.dart';
import '../../widgets/language_toggle.dart';
import 'company_profile_screen.dart';
import '../widgets/notification_sheet.dart';

class JobDetailsScreen extends StatefulWidget {
  final String jobId;
  final String companyId;
  final String title;
  final String company;
  final String logoUrl;
  final String location;
  final String description;
  final String requirements;
  final String jobType;
  final String salaryFrom;
  final String salaryTo;

  const JobDetailsScreen({
    super.key, 
    required this.jobId,
    required this.companyId,
    required this.title, 
    required this.company, 
    required this.logoUrl,
    required this.location,
    required this.description,
    required this.requirements,
    required this.jobType,
    required this.salaryFrom,
    required this.salaryTo,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool _isDescriptionExpanded = false;
  bool _isApplied = false;

  @override
  void initState() {
    super.initState();
    _checkIfApplied();
  }

  Future<void> _checkIfApplied() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('applications')
          .where('jobId', isEqualTo: widget.jobId)
          .where('studentId', isEqualTo: user.uid)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        if (mounted) {
          setState(() {
            _isApplied = true;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEEF4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFDA00C), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          const LanguageToggle(),
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined, color: Color(0xFFFDA00C), size: 24),
            onPressed: () => NotificationSheet.show(context),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // لوجو الشركة المظبوط (Google)
            Center(
              child: Container(
                height: 100, width: 100,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: widget.logoUrl.isNotEmpty
                  ? Image.network(
                      widget.logoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, size: 50, color: Color(0xFF1B4B82)),
                    )
                  : const Icon(Icons.business, size: 50, color: Color(0xFF1B4B82)),
              ),
            ),
            const SizedBox(height: 15),
            Text(widget.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(widget.company, style: const TextStyle(color: Color(0xFF7E848E), fontSize: 18)),
            const SizedBox(height: 20),
            
            // الموقع والراتب
            Wrap(
              spacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _buildInfoChip(Icons.location_on, widget.location, Colors.red),
                _buildInfoChip(Icons.monetization_on, "\${widget.salaryFrom} - \${widget.salaryTo}", Colors.green),
                _buildInfoChip(Icons.work, widget.jobType, Colors.blue),
              ],
            ),
            
            const SizedBox(height: 30),
            _buildSectionTitle(AppLocale.tr(context, "Job Description")),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.description.isNotEmpty ? widget.description : AppLocale.tr(context, "No description provided."),
                  maxLines: _isDescriptionExpanded ? 10 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, height: 1.5),
                ),
                InkWell(
                  onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                  child: Text(
                    AppLocale.tr(context, _isDescriptionExpanded ? "See less" : "See more >"),
                    style: const TextStyle(color: Color(0xFF229BD8), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            // قائمة المتطلبات المنسدلة (التي طلبتِها بالسهم)
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(AppLocale.tr(context, "Job Requirements"), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                tilePadding: EdgeInsets.zero,
                iconColor: const Color(0xFF1B4B82),
                children: [
                  ...widget.requirements.split('\\n').where((req) => req.trim().isNotEmpty).map((req) => _buildReqItem(AppLocale.tr(context, req))),
                ],
              ),
            ),

            const SizedBox(height: 40),
            // زر التقديم (يتغير عند الضغط)
            ElevatedButton(
              onPressed: _isApplied ? null : () async {
                if (studentService.isVerified) {
                  setState(() => _isApplied = true);
                  
                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await FirebaseFirestore.instance.collection('applications').add({
                        'jobId': widget.jobId,
                        'companyId': widget.companyId,
                        'studentId': user.uid,
                        'jobTitle': widget.title,
                        'companyName': widget.company,
                        'companyLogoUrl': widget.logoUrl,
                        'status': 'Applied',
                        'appliedAt': FieldValue.serverTimestamp(),
                      });
                      
                      await FirebaseFirestore.instance.collection('notifications').add({
                        'targetId': widget.companyId,
                        'targetType': 'company',
                        'title': 'New Application',
                        'message': 'A student has applied for \${widget.title}',
                        'type': 'application',
                        'createdAt': FieldValue.serverTimestamp(),
                        'isRead': false,
                      });
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocale.tr(context, "Applied Successfully!"))));
                  } catch (e) {
                    setState(() => _isApplied = false);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error applying: \$e")));
                  }
                } else {
                  _showVerificationDialog(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isApplied ? const Color(0xFF7E848E) : const Color(0xFF229BD8),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(AppLocale.tr(context, _isApplied ? "Applied" : "Apply Now"), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            
            const SizedBox(height: 15),
            // زر عرض الشركة
            TextButton(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => CompanyProfileScreen(companyId: widget.companyId)
                  )
                );
              },
              child: Text(
                AppLocale.tr(context, "View Company Profile"), 
                style: const TextStyle(
                  color: Color(0xFF229BD8), 
                  decoration: TextDecoration.underline, 
                  fontWeight: FontWeight.bold
                )
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
            
  void _showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.verified_user_outlined, color: Colors.orange),
            const SizedBox(width: 10),
            Text(AppLocale.tr(context, "Verification Required")),
          ],
        ),
        content: Text(AppLocale.tr(context, "You must verify your student account first to be able to apply for jobs.")),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocale.tr(context, "Maybe Later"), style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigation to profile or directly to verify
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocale.tr(context, "Go to Profile to verify"))));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF229BD8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(AppLocale.tr(context, "Verify Now"), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- دوال مساعدة لترتيب الكود ---
  Widget _buildSectionTitle(String title) => Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));

  Widget _buildReqItem(String text) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [const Icon(Icons.check_circle, size: 18, color: Color(0xFFFDA00C)), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(color: Colors.black54)))]));

  Widget _buildInfoChip(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), 
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), 
    child: Row(
      mainAxisSize: MainAxisSize.min, 
      children: [
        Icon(icon, size: 16, color: color), 
        const SizedBox(width: 6), 
        Flexible(child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis))
      ]
    )
  );
}
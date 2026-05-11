import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../app_localization.dart';
import '../../widgets/language_toggle.dart';
import '../widgets/notification_sheet.dart';
import 'job_details_screen.dart';

class CompanyProfileScreen extends StatefulWidget {
  final String companyId;
  const CompanyProfileScreen({super.key, required this.companyId});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  bool _isAboutExpanded = false;
  bool _isLocationExpanded = false;

  @override
  Widget build(BuildContext context) {
    bool isAr = appLocalization.locale.languageCode == 'ar';
    
    return Scaffold(
      backgroundColor: const Color(0xFFEBEEF4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFDA00C), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          const LanguageToggle(),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFFFDA00C), size: 24),
            onPressed: () => NotificationSheet.show(context),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(widget.companyId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Company not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'Unknown Company';
          final logoUrl = data['logoUrl'] ?? '';
          final overview = data['overview'] ?? (isAr ? "لا يوجد وصف متاح" : "No overview available.");
          final location = data['location'] ?? (isAr ? "غير محدد" : "Unknown");
          final website = data['website'] ?? "";

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Container(
                  height: 90,
                  width: 90,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)]
                  ),
                  child: logoUrl.isNotEmpty
                      ? Image.network(logoUrl, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.business, size: 40))
                      : const Icon(Icons.business, size: 40),
                ),
                const SizedBox(height: 10),
                Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isLocationExpanded = !_isLocationExpanded;
                      });
                    },
                    onLongPress: () async {
                      final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$location");
                      if (await canLaunchUrl(url)) await launchUrl(url);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            location,
                            textAlign: TextAlign.center,
                            maxLines: _isLocationExpanded ? 10 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey, 
                              decoration: TextDecoration.underline
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                _buildSectionCard(
                  title: isAr ? "عن الشركة" : "About Company",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        overview,
                        maxLines: _isAboutExpanded ? 20 : 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54, height: 1.5),
                      ),
                      if (overview.length > 100)
                        InkWell(
                          onTap: () => setState(() => _isAboutExpanded = !_isAboutExpanded),
                          child: Text(
                            isAr ? (_isAboutExpanded ? "عرض أقل" : "عرض المزيد >") : (_isAboutExpanded ? "See less" : "See more >"),
                            style: const TextStyle(color: Color(0xFF229BD8), fontWeight: FontWeight.bold)
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                Align(
                  alignment: isAr ? Alignment.centerRight : Alignment.centerLeft, 
                  child: Text(isAr ? "الوظائف المتاحة" : "Posted Jobs", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                ),
                const SizedBox(height: 15),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('jobs')
                      .where('companyId', isEqualTo: widget.companyId)
                      .snapshots(),
                  builder: (context, jobSnapshot) {
                    if (jobSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!jobSnapshot.hasData || jobSnapshot.data!.docs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(isAr ? "لا توجد وظائف متاحة حالياً" : "No jobs posted yet."),
                      );
                    }

                    return Column(
                      children: jobSnapshot.data!.docs.map((doc) {
                        final job = doc.data() as Map<String, dynamic>;
                        return _buildJobItem(context, doc.id, job, logoUrl, isAr);
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }

  Widget _buildJobItem(BuildContext context, String jobId, Map<String, dynamic> job, String logoUrl, bool isAr) {
    final title = job['title'] ?? 'No Title';
    final location = job['location'] ?? '';
    final type = job['jobType'] ?? 'Full-Time';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsScreen(
              jobId: jobId,
              companyId: job['companyId'] ?? '',
              title: title,
              company: job['companyName'] ?? '',
              logoUrl: logoUrl,
              location: location,
              description: job['description'] ?? '',
              requirements: job['requirements'] ?? '',
              jobType: type,
              salaryFrom: job['salaryFrom'] ?? '',
              salaryTo: job['salaryTo'] ?? '',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 40, width: 40,
                  decoration: const BoxDecoration(color: Color(0xFFEBEEF4), shape: BoxShape.circle),
                  child: logoUrl.isNotEmpty 
                      ? ClipOval(child: Image.network(logoUrl, fit: BoxFit.cover))
                      : const Icon(Icons.business, color: Color(0xFF229BD8)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(type, style: const TextStyle(color: Color(0xFF229BD8), fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
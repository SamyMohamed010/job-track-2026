import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/company.dart';

class CompanyDetailsScreen extends StatefulWidget {
  final Company company;

  const CompanyDetailsScreen({super.key, required this.company});

  @override
  State<CompanyDetailsScreen> createState() => _CompanyDetailsScreenState();
}

class _CompanyDetailsScreenState extends State<CompanyDetailsScreen> {
  bool _isExpanded = false;

  // 1. دالة عامة لفتح أي رابط (خريطة، رخصة، موقع)
  Future<void> _openUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Could not launch $urlString");
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }

  // 2. دالة مخصصة لفتح الموقع على الخريطة
  void _openMap() {
    // بيبحث في جوجل ماب باسم الشركة ومكانها
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.company.name + " " + widget.company.location)}";
    _openUrl(googleMapsUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEEF4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.orange,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // تم إزالة الـ const من هنا عشان الـ onPressed تشتغل صح
          IconButton(
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: Colors.orange,
              size: 28,
            ),
            onPressed: () {
              // هنا تقدر تفتح صفحة الإشعارات
              print("فتح تبويب الإشعارات");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Notifications tab opened")),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 30),

            // كارت الـ About (See More شغالة 100%)
            _buildSectionCard(
              title: "About ${widget.company.name}",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.company.description.isNotEmpty 
                        ? widget.company.description 
                        : "No description provided by the company.",
                    maxLines: _isExpanded ? 100 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[700], height: 1.5),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Text(
                      _isExpanded ? "See less <" : "See more >",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionCard(
              title: "Contact Info.",
              content: Column(
                children: [
                  _buildContactItem(Icons.language, widget.company.website.isNotEmpty ? widget.company.website : "www.linkedin.com"),
                  const Divider(),
                  _buildContactItem(Icons.email_outlined, widget.company.email),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // زرار عرض الرخصة (شغال الآن)
            _buildLicenseSection(),
            const SizedBox(height: 30),

            // أزرار التحكم (اعتماد / رفض)
            if (!widget.company.isApproved)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final TextEditingController reasonController =
                            TextEditingController();
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Rejection reason"),
                            content: TextField(
                              controller: reasonController,
                              minLines: 3,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                hintText: "Enter the rejection reason",
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final reason = reasonController.text.trim();
                                  if (reason.isEmpty) return;
                                  if (widget.company.id != null) {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(widget.company.id)
                                        .update({
                                          'isApproved': false,
                                          'status': 'rejected',
                                          'rejectionReason': reason,
                                        });
                                  }
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Company rejected successfully",
                                        ),
                                      ),
                                    );
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Confirm"),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Reject Registration",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                    Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (widget.company.id != null) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.company.id)
                              .update({
                                'isApproved': true,
                                'status': 'approved'
                              });
                          setState(() => widget.company.isApproved = true);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Company approved successfully"),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF229BD8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Approve Company",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Text(
                      "This company is approved",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: widget.company.logoUrl.isNotEmpty
                  ? Image.network(
                      widget.company.logoUrl,
                      errorBuilder: (c, e, s) => const Icon(Icons.business),
                    )
                  : const Icon(Icons.business),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            widget.company.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          // اللوكيشن بقى InkWell يعني قابل للضغط
          InkWell(
            onTap: _openMap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 16),
                Text(
                  " ${widget.company.location}",
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          const Text("Healthcare", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          content,
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return InkWell(
      onTap: () => _openUrl("https://$text"),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey, size: 20),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(color: Colors.blue, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (widget.company.licenseUrl.isNotEmpty) {
              _openUrl(widget.company.licenseUrl);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No license document available.")),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.remove_red_eye_outlined,
              color: Colors.grey,
              size: 30,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "View License",
          style: TextStyle(
            color: Colors.grey,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }
}

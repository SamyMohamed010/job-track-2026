import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company.dart';
import '../widgets/company_card.dart';
import '../widgets/notification_button.dart';
import 'jobs_screen.dart';
import 'analytics_screen.dart';

const Color kPrimaryBlue = Color(0xFF229BD8);
const Color kMainFrameColor = Color(0xFFEBEEF4);
const Color kGreyText = Color(0xFF7E848E);
const Color kOrangeAccent = Color(0xFFFDA00C);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool isArabic = false;

  final List<Widget> _pages = [
    const JobsScreen(),
    const AnalyticsScreen(),
    const CompanyListContent(),
  ];

  final List<Map<String, String>> _titles = [
    {"en": "Recent Jobs", "ar": "أحدث الوظائف"},
    {"en": "Analytics", "ar": "الإحصائيات"},
    {"en": "Companies", "ar": "الشركات"},
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: kMainFrameColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 70,
          title: Row(
            children: [
              // اللوجو
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
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
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.business, color: kPrimaryBlue),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isArabic
                    ? _titles[_selectedIndex]["ar"]!
                    : _titles[_selectedIndex]["en"]!,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            // القائمة المنسدلة للغات
            PopupMenuButton<String>(
              icon: const Icon(Icons.language, color: kPrimaryBlue),
              onSelected: (String value) {
                setState(() {
                  isArabic = (value == 'ar');
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'en',
                  child: Text("English (US)"),
                ),
                const PopupMenuItem<String>(
                  value: 'ar',
                  child: Text("العربية (مصر)"),
                ),
              ],
            ),
            CustomNotificationButton(onPressed: () {}),
            IconButton(
              icon: const Icon(Icons.logout, color: kPrimaryBlue),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      isArabic ? "تأكيد تسجيل الخروج" : "Confirm Logout",
                      style: const TextStyle(
                        color: kPrimaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      isArabic
                          ? "هل أنت متأكد أنك تريد تسجيل الخروج؟"
                          : "Are you sure you want to log out?",
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          isArabic ? "إلغاء" : "Cancel",
                          style: const TextStyle(color: kGreyText),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // close dialog
                          Navigator.pop(context); // close admin screen (logout)
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          elevation: 0,
                        ),
                        child: Text(
                          isArabic ? "خروج" : "Logout",
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: kPrimaryBlue,
          unselectedItemColor: kGreyText,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.work_outline),
              label: isArabic ? "الوظائف" : "Jobs",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.analytics_outlined),
              label: isArabic ? "التحليلات" : "Analytics",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.business),
              label: isArabic ? "الشركات" : "Company",
            ),
          ],
        ),
      ),
    );
  }
}

class CompanyListContent extends StatelessWidget {
  const CompanyListContent({super.key});

  @override
  Widget build(BuildContext context) {
    bool isArabic = Directionality.of(context) == TextDirection.rtl;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'company')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading companies'));
        }

        final List<Company> companies =
            snapshot.data?.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Company(
                id: doc.id,
                name: (data['name']?.toString().trim().isNotEmpty == true) ? data['name'] : 'Unknown',
                email: data['email'] ?? 'No email',
                brandColor: kPrimaryBlue,
                logoUrl: (data['logoUrl']?.toString().trim().isNotEmpty == true) 
                    ? data['logoUrl'] 
                    : "https://img.icons8.com/color/512/business.png",
                location: (data['location']?.toString().trim().isNotEmpty == true) ? data['location'] : 'Unknown location',
                status: data['status'] ?? 'pending',
                isApproved: data['isApproved'] ?? false,
                licenseUrl: data['licenseUrl'] ?? '',
                description: data['overview'] ?? data['description'] ?? '',
                website: data['website'] ?? 'www.linkedin.com',
              );
            }).toList() ??
            [];

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvailableJobsCard(isArabic),
                const SizedBox(height: 25),
                Text(
                  isArabic
                      ? "مراجعة واعتماد الشركات الجديدة"
                      : "Review and approve registrations",
                  style: const TextStyle(
                    color: kGreyText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 15),
                if (companies.isEmpty)
                  Center(
                    child: Text(
                      isArabic ? "لا توجد شركات بعد" : "No companies yet",
                    ),
                  )
                else
                  ...companies.map((comp) => CompanyCard(company: comp)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvailableJobsCard(bool isArabic) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
      builder: (context, snapshot) {
        final jobCount = snapshot.data?.docs.length ?? 0;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kPrimaryBlue,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? "الوظائف المتاحة" : "Available Jobs",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    jobCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.stacked_line_chart,
                color: Colors.white.withOpacity(0.5),
                size: 40,
              ),
            ],
          ),
        );
      },
    );
  }
}

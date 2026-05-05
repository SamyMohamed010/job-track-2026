import 'package:flutter/material.dart';
import '../../../core/student_service.dart';
import 'package:flutter/cupertino.dart';
import 'job_details_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'applications_screen.dart';
import '../../../app_localization.dart';
import '../../widgets/language_toggle.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class Job {
  final String title;
  final String company;
  final String location;
  final String type; // 'Internship', 'Part-time', 'Full-time'
  final String logoPath;

  Job({
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.logoPath,
  });
}

class _HomeScreenState extends State<HomeScreen> {
  final Color primaryBlue = const Color(0xFF1E3A5F);
  final Color primaryBlueLight = const Color(0xFF229BD8);
  final Color grayBg = const Color(0xFFEBEEF4);
  final Color grayText = const Color(0xFF7E848E);

  String selectedFilter =
      'All'; // 'All', 'Internship', 'Part-time', 'Full-time'
  String searchQuery = "";
  int _currentIndex = 1; // 1 = Home
  bool isArabic = false;

  final List<Job> allJobs = [
    Job(
      title: 'Flutter Developer Intern',
      company: 'Vodafone Egypt',
      location: 'Cairo, Egypt',
      type: 'Internship',
      logoPath: 'assets/images/logo image.jpg',
    ),
    Job(
      title: 'UI/UX Designer',
      company: 'Google Egypt',
      location: 'Cairo, Egypt',
      type: 'Full-time',
      logoPath: 'assets/images/logo image.jpg',
    ),
    Job(
      title: 'Data Analyst Intern',
      company: 'Amazon',
      location: 'Ajman, UAE',
      type: 'Part-time',
      logoPath: 'assets/images/logo image.jpg',
    ),
    Job(
      title: 'Backend Engineer',
      company: 'Microsoft',
      location: 'Remote',
      type: 'Full-time',
      logoPath: 'assets/images/logo image.jpg',
    ),
  ];

  Map<String, String> get texts {
    bool isAr = appLocalization.locale.languageCode == 'ar';
    return {

    'logout': isArabic ? "خروج" : "Logout",
    'hello': isArabic ? "مرحباً، " : "Hello, ",
    'findNext': isArabic
        ? "ابحث عن فرصتك القادمة"
        : "Find your next opportunity",
    'searchHint': isArabic
        ? "ابحث عن المسمى الوظيفي..."
        : "Search by job title...",
    'view': isArabic ? "عرض" : "View",
    'All': isArabic ? "الكل" : "All",
    'Internship': isArabic ? "تدريب" : "Internship",
    'Part-time': isArabic ? "دوام جزئي" : "Part-time",
    'Full-time': isArabic ? "دوام كامل" : "Full-time",
    'navApp': isArabic ? "الطلبات" : "Applications",
    'navHome': isArabic ? "الرئيسية" : "Home",
    'navProfile': isArabic ? "الملف الشخصي" : "Profile",
    'notifications': isArabic ? "الإشعارات" : "Notifications",
    'appUpdated': isArabic ? "تحديث الطلب" : "Application Updated",
    'appUpdatedDesc': isArabic
        ? "فودافون مصر شاهدت طلبك."
        : "Vodafone Egypt viewed your application.",
    'newJob': isArabic ? "فرصة جديدة" : "New Job Match",
    'newJobDesc': isArabic
        ? "جوجل مصر نشرت وظيفة جديدة."
        : "Google Egypt posted a new UI/UX role.",
    'profileTip': isArabic ? "تلميح" : "Profile Tip",
    'profileTipDesc': isArabic
        ? "أكمل مهاراتك لتتميز."
        : "Complete your skills to stand out.",
  };
  }

  @override
  Widget build(BuildContext context) {
    List<Job> filteredJobs = allJobs.where((job) {
      bool matchesFilter =
          selectedFilter == 'All' || job.type == selectedFilter;
      bool matchesSearch = job.title.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      return matchesFilter && matchesSearch;
    }).toList();

    return AnimatedBuilder(
      animation: appLocalization,
      builder: (context, child) {
        bool isAr = appLocalization.locale.languageCode == 'ar';
        return Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(

        backgroundColor: grayBg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopHeader(),
              if (!studentService.isVerified) _buildVerificationBar(),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 10.0,
                  ),
                  children: [
                    // Hello and Subtitle (Disappears on scroll)
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: texts['hello']!,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                          TextSpan(
                            text: widget.userName,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryBlueLight,
                            ),
                          ),
                          const TextSpan(
                            text: " 👋",
                            style: TextStyle(fontSize: 22),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      texts['findNext']!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: grayText,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildSearchBar(),
                    const SizedBox(height: 15),

                    _buildFilters(),
                    const SizedBox(height: 15),

                    ...filteredJobs.map((job) => _buildJobCard(job)),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
      },
    );

  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Logo
              Container(
                height: 50,
                width: 50,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo image.jpg',
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.person, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 8),
              // Logout button
              TextButton.icon(
                onPressed: () {
                  final bool isAr = appLocalization.locale.languageCode == 'ar';
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(isAr ? "تأكيد تسجيل الخروج" : "Confirm Logout", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
                      content: Text(isAr ? "هل أنت متأكد أنك تريد تسجيل الخروج؟" : "Are you sure you want to log out?", style: TextStyle(color: grayText)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(isAr ? "إلغاء" : "Cancel", style: TextStyle(color: primaryBlueLight)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, elevation: 0),
                          child: Text(isAr ? "خروج" : "Logout", style: const TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.logout, color: grayText, size: 18),
                label: Text(
                  texts['logout']!,
                  style: TextStyle(
                    color: grayText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          Row(
            children: [
              // Language Toggle
              const LanguageToggle(),
              // Bell (No circle background, just icon)
              GestureDetector(
                onTap: () => _showNotificationsSheet(context),
                child: const Icon(
                  Icons.notifications_none,
                  color: Colors.amber,
                  size: 26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: texts['searchHint'],
          hintStyle: TextStyle(color: grayText, fontSize: 14),
          prefixIcon: Icon(CupertinoIcons.search, color: grayText),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
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
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Container(
            padding: const EdgeInsets.all(24),
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  texts['notifications']!,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _buildNotificationItem(
                        title: texts['appUpdated']!,
                        subtitle: texts['appUpdatedDesc']!,
                        icon: Icons.remove_red_eye,
                        time: "2h",
                      ),
                      _buildNotificationItem(
                        title: texts['newJob']!,
                        subtitle: texts['newJobDesc']!,
                        icon: Icons.work_outline,
                        time: "5h",
                      ),
                      _buildNotificationItem(
                        title: texts['profileTip']!,
                        subtitle: texts['profileTipDesc']!,
                        icon: Icons.lightbulb_outline,
                        time: "1d",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: grayBg,
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
            child: Icon(icon, color: primaryBlueLight, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: grayText, fontSize: 12)),
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

  Widget _buildFilters() {
    final filters = ['All', 'Internship', 'Part-time', 'Full-time'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          bool isSelected = selectedFilter == filter;
          return Padding(
            padding: EdgeInsets.only(
              right: isArabic ? 0 : 10.0,
              left: isArabic ? 10.0 : 0,
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedFilter = filter;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? primaryBlue : Colors.black12,
                  ),
                ),
                child: Text(
                  texts[filter] ?? filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildJobCard(Job job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            width: 50,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: grayBg,
              border: Border.all(color: Colors.black12),
            ),
            child: Image.asset(
              job.logoPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.business, color: primaryBlue),
            ),
          ),
          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: primaryBlue,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: primaryBlueLight.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            texts[job.type] ?? job.type,
                            style: TextStyle(
                              color: primaryBlueLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JobDetailsScreen(
                                    title: job.title,
                                    company: job.company,
                                    location: job.location,
                                  ),
                                ),
                              );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primaryBlueLight, // 229BD8
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              texts['view']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  job.company,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: grayText),
                    const SizedBox(width: 4),
                    Text(
                      job.location,
                      style: TextStyle(
                        color: grayText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
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
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              if (index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ApplicationsScreen(),
                  ),
                ).then((_) {
                  setState(() {
                    _currentIndex = 1;
                  });
                });
              } else if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                ).then((_) {
                  setState(() {
                    _currentIndex = 1;
                  });
                });
              }
            },
            backgroundColor: Colors.white,
            selectedItemColor: primaryBlueLight,
            // ignore: deprecated_member_use
            unselectedItemColor: primaryBlue.withOpacity(0.5),
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
                label: texts['navApp'],
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 5.0),
                  child: Icon(CupertinoIcons.home),
                ),
                label: texts['navHome'],
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 5.0),
                  child: Icon(CupertinoIcons.person),
                ),
                label: texts['navProfile'],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4), // Light yellow
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? "حسابك غير موثق" : "Unverified Account",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                ),
                Text(
                  isArabic ? "وثق حسابك للتمكن من التقديم" : "Verify now to apply for jobs",
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
            style: TextButton.styleFrom(
              backgroundColor: primaryBlueLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(isArabic ? "وثق الآن" : "Verify", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

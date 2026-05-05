import 'package:flutter/material.dart';
import '../app_localization.dart';
import '../features/student/screens/login_screen.dart';
import '../features/widgets/language_toggle.dart';
import '../features/localization.dart';

class StudentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showLogout;
  final VoidCallback onNotificationPressed;
  final VoidCallback? onBackPressed;

  const StudentAppBar({
    super.key,
    this.showLogout = false,
    required this.onNotificationPressed,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAr = appLocalization.locale.languageCode == 'ar';
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 70,
      leadingWidth: showLogout ? 300 : 200,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Image.asset(
                'assets/images/logo image.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.grey),
              ),
            ),

            if (showLogout) ...[
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: () {
                  final bool isAr = appLocalization.locale.languageCode == 'ar';
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(isAr ? "تأكيد تسجيل الخروج" : "Confirm Logout", style: const TextStyle(color: Color(0xFF1E3A5F), fontWeight: FontWeight.bold)),
                      content: Text(isAr ? "هل أنت متأكد أنك تريد تسجيل الخروج؟" : "Are you sure you want to log out?"),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(isAr ? "إلغاء" : "Cancel", style: const TextStyle(color: Colors.grey)),
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
                icon: const Icon(Icons.logout, color: Colors.grey, size: 18),
                label: Text(
                  AppLocale.tr(context, "Logout"),
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        const LanguageToggle(),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.amber, size: 26),
          onPressed: onNotificationPressed,
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

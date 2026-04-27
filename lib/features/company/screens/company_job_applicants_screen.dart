import 'package:flutter/material.dart';
import 'company_notifications_sheet.dart';

class CompanyJobApplicantsScreen extends StatelessWidget {
  final String jobTitle;

  const CompanyJobApplicantsScreen({super.key, required this.jobTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEEF4),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFDA00C), size: 20),
                  ),
                  GestureDetector(
                    onTap: () => showCompanyNotifications(context),
                    child: const Icon(Icons.notifications, color: Color(0xFFFDA00C)),
                  ),
                ],
              ),
            ),
            
            // Body - Empty State
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Custom Icon: People with graduation cap
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

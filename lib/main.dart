import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_localization.dart';
import 'features/company/screens/company_register_screen.dart';
import 'features/company/screens/company_register_step2_screen.dart';
import 'features/company/screens/company_register_step3_screen.dart';
import 'features/company/screens/company_approval_screen.dart';
import 'features/company/screens/company_main_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appLocalization,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: appLocalization.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // البداية من الشاشة الأولى
          initialRoute: '/company_register_step1',
          
          // تعريف جميع الشاشات هنا (الربط في main)
          routes: {
            '/company_register_step1': (context) => CompanyRegisterScreen(),
            '/company_register_step2': (context) => CompanyRegisterStep2Screen(),
            '/company_register_step3': (context) => CompanyRegisterStep3Screen(),
            '/company_approval': (context) => CompanyApprovalScreen(),
            '/company_main': (context) => CompanyMainScreen(),
          },
        );
      }
    );
  }
}
import 'package:flutter/material.dart';

class AppLocalization extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void toggleLanguage() {
    _locale = _locale.languageCode == 'en' ? const Locale('ar') : const Locale('en');
    notifyListeners();
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'login': 'Sign In',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'welcome_back': 'Welcome Back!',
      'sign_in_continue': 'Sign in to continue to Jop Trace',
      'dont_have_account': "Don't have an account? ",
      'already_have_account': "Already have an account? ",
      'forgot_password': 'Forgot Password?',
      'step_1_of_3': 'Step 1 of 3',
      'step_2_of_3': 'Step 2 of 3',
      'step_3_of_3': 'Step 3 of 3',
      'company_registration': 'Company Registration',
      'create_account': 'Create Account',
      'fill_details': 'Please fill in the details below',
      'next': 'Next',
      'company_details': 'Company Details',
      'tell_us_more': 'Tell us more about your company',
      'company_name': 'Company Name',
      'industry': 'Industry',
      'location': 'Location',
      'website': 'Website',
      'company_size': 'Company Size',
      'upload_documents': 'Upload Documents',
      'upload_logo_license': 'Upload company logo and license',
      'company_logo': 'Company Logo',
      'upload_logo': 'Upload Logo',
      'commercial_license': 'Commercial License',
      'upload_license': 'Upload License',
    },
    'ar': {
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'confirm_password': 'تأكيد كلمة المرور',
      'welcome_back': 'مرحباً بعودتك!',
      'sign_in_continue': 'سجل الدخول للمتابعة في جوب تريس',
      'dont_have_account': "ليس لديك حساب؟ ",
      'already_have_account': "لديك حساب بالفعل؟ ",
      'forgot_password': 'هل نسيت كلمة المرور؟',
      'step_1_of_3': 'الخطوة 1 من 3',
      'step_2_of_3': 'الخطوة 2 من 3',
      'step_3_of_3': 'الخطوة 3 من 3',
      'company_registration': 'تسجيل الشركة',
      'create_account': 'إنشاء حساب',
      'fill_details': 'الرجاء ملء التفاصيل أدناه',
      'next': 'التالي',
      'company_details': 'تفاصيل الشركة',
      'tell_us_more': 'أخبرنا المزيد عن شركتك',
      'company_name': 'اسم الشركة',
      'industry': 'مجال العمل',
      'location': 'الموقع',
      'website': 'الموقع الإلكتروني',
      'company_size': 'حجم الشركة',
      'upload_documents': 'رفع المستندات',
      'upload_logo_license': 'يرجى رفع شعار الشركة والسجل التجاري',
      'company_logo': 'شعار الشركة',
      'upload_logo': 'رفع الشعار',
      'commercial_license': 'السجل التجاري',
      'upload_license': 'رفع السجل',
    }
  };

  String translate(String key, {String? defaultText}) {
    return _localizedValues[_locale.languageCode]?[key] ?? defaultText ?? key;
  }
}

// Global instance
final AppLocalization appLocalization = AppLocalization();

import 'package:flutter/material.dart';
import 'student_register.dart';
import '../../company/screens/company_register_screen.dart';
import 'forgot_password.dart';
import 'home_screen.dart';
import '../../company/screens/company_profile_screen.dart';
import '../../company/screens/company_main_screen.dart';
import '../../company/screens/company_approval_screen.dart';
import '../../admin/screens/home_screen.dart' as admin;
import '../../../core/services/auth_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/student_service.dart';
import '../../company/company_data.dart';

// لازم يكون مكتوب extends StatefulWidget أو StatelessWidget
// لازم يكون مكتوب extends StatefulWidget أو StatelessWidget
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isSubmitted = false;
  bool _isLoading = false;
  bool isArabic = false; // التحكم في اللغة

  final Color primaryBlue = const Color(0xFF229BD8);
  final Color grayTextColor = const Color(0xFF7E848E);

  // قاموس النصوص للترجمة
  Map<String, String> get texts => {
    'welcomeBack': isArabic ? "مرحباً بعودتك" : "Welcome Back",
    'studentPortal': isArabic ? "بوابة الطالب" : "Student Portal",
    'companyPortal': isArabic ? "بوابة الشركات" : "Company Portal",
    'email': isArabic ? "البريد الإلكتروني" : "Email",
    'pass': isArabic ? "كلمة المرور" : "Password",
    'forgot': isArabic ? "نسيت كلمة المرور؟" : "Forgot Password?",
    'login': isArabic ? "تسجيل الدخول" : "Login",
    'create': isArabic ? "إنشاء حساب جديد" : "Create Account",
    'signInAs': isArabic ? "تسجيل الدخول كـ" : "Sign in as",
    'student': isArabic ? "طالب" : "Student",
    'company': isArabic ? "شركة" : "Company",
    'req': isArabic ? "هذا الحقل مطلوب" : "Field is required",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEEF4),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => setState(() => isArabic = !isArabic),
            child: Text(
              isArabic ? "English" : "العربية",
              style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildHeader(),
                        Column(
                          crossAxisAlignment: isArabic
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            _buildLabel(texts['email']!, _emailController),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: _emailController,
                              textAlign: isArabic
                                  ? TextAlign.right
                                  : TextAlign.left,
                              decoration: _inputDecoration(
                                'name@example.com',
                                icon: Icons.email_outlined,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return isArabic ? "مطلوب" : "Required";
                                }
                                final email = value.toLowerCase().trim();
                                if (email == 'admin')
                                  return null; // Allow admin
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(email)) {
                                  return isArabic
                                      ? "إيميل غير صالح"
                                      : "Invalid Email";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            _buildLabel(texts['pass']!, _passwordController),
                            const SizedBox(height: 5),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              textAlign: isArabic
                                  ? TextAlign.right
                                  : TextAlign.left,
                              decoration: _passwordDecoration(),
                              validator: (value) =>
                                  (value == null || value.isEmpty)
                                  ? (isArabic ? "مطلوب" : "Required")
                                  : null,
                            ),
                            Align(
                              alignment: isArabic
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // هذا هو الكود من "الخطوة 1" الذي سألته عنه
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgotPasswordScreen(),
                                      ),
                                    );
                                  });
                                },
                                child: Text(
                                  texts['forgot']!,
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5, bottom: 5),
          height: 85,
          width: 85,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logo image.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.image_not_supported, size: 50);
            },
          ),
        ),
        const SizedBox(height: 10),
        Text(
          texts['welcomeBack']!,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 12),
      prefixIcon: isArabic ? null : Icon(icon, color: primaryBlue, size: 15),
      suffixIcon: isArabic ? Icon(icon, color: primaryBlue, size: 15) : null,
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  InputDecoration _passwordDecoration() {
    return InputDecoration(
      hintText: "••••••••",
      hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 12),
      prefixIcon: isArabic
          ? null
          : Icon(Icons.lock_outline, color: primaryBlue, size: 15),
      suffixIcon: IconButton(
        icon: Icon(
          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          color: primaryBlue,
          size: 15,
        ),
        onPressed: () =>
            setState(() => _isPasswordVisible = !_isPasswordVisible),
      ),
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildLabel(String text, TextEditingController controller) {
    bool hasError = _isSubmitted && controller.text.isEmpty;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            color: grayTextColor,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        if (hasError)
          const Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _isLoading
            ? const CircularProgressIndicator()
            : _buildButton(
                texts['login']!,
                primaryBlue,
                Colors.white,
                () async {
                  setState(() {
                    _isSubmitted = true;
                  });
                  if (_formKey.currentState!.validate()) {
                    String email = _emailController.text.trim();
                    String password = _passwordController.text.trim();

                    if (email == 'admin' && password == '123456') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const admin.HomeScreen(),
                        ),
                      );
                    } else {
                      setState(() {
                        _isLoading = true;
                      });
                      try {
                        final auth = AuthService();
                        final cred = await auth.signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        if (cred != null && cred.user != null) {
                          final doc = await DatabaseService(
                            uid: cred.user!.uid,
                          ).getUserData();
                          if (doc.exists) {
                            final data = doc.data() as Map<String, dynamic>;
                            if (data['role'] == 'student') {
                              studentService.name = data['name'] ?? 'Student';
                              studentService.email = data['email'] ?? email;
                              studentService.faculty = data['faculty'] ?? '';
                              studentService.specialty =
                                  data['specialty'] ?? '';
                              studentService.graduationYear =
                                  data['graduationYear'] ?? '';
                              studentService.program = data['program'];
                              studentService.profileImageUrl = data['profileImageUrl'];
                              studentService.cvUrl = data['cvUrl'];
                              studentService.cvFileName = data['cvFileName'];
                              studentService.verificationUrl = data['verificationUrl'];
                              studentService.verificationFileName = data['verificationFileName'];
                              studentService.isVerified = data['isVerified'] ?? false;

                              if (data['skills'] != null) {
                                studentService.skills = List<String>.from(
                                  data['skills'],
                                );
                              } else {
                                studentService.skills = [];
                              }

                              if (mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(
                                      userName: studentService.name,
                                    ),
                                  ),
                                );
                              }
                            } else if (data['role'] == 'company') {
                              CompanyData().name = data['name'] ?? '';
                              CompanyData().industry = data['industry'] ?? '';
                              CompanyData().overview = data['overview'] ?? '';
                              CompanyData().location = data['location'] ?? '';
                              CompanyData().website = data['website'] ?? '';
                              CompanyData().email = data['email'] ?? email;
                              CompanyData().logoUrl = data['logoUrl'];
                              CompanyData().licenseUrl = data['licenseUrl'];

                              if (data['isApproved'] == true ||
                                  data['status'] == 'approved') {
                                if (mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CompanyMainScreen(),
                                    ),
                                  );
                                }
                              } else {
                                if (mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CompanyApprovalScreen(
                                            status:
                                                data['status'] as String? ??
                                                'pending',
                                            rejectionReason:
                                                data['rejectionReason']
                                                    as String? ??
                                                '',
                                          ),
                                    ),
                                  );
                                }
                              }
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isArabic
                                          ? "دور المستخدم غير معروف"
                                          : "Unknown user role",
                                    ),
                                  ),
                                );
                              }
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isArabic
                                        ? "لم يتم العثور على بيانات الحساب"
                                        : "User data not found",
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    }
                  }
                },
              ),
        const SizedBox(height: 10),
        _buildButton(
          texts['create']!,
          Colors.white,
          primaryBlue,
          () {
            _showUserTypeDialog(context, isLogin: false);
          },
          borderColor: primaryBlue.withOpacity(0.3),
        ),
      ],
    );
  }

  void _showUserTypeDialog(BuildContext context, {required bool isLogin}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isLogin
                    ? (isArabic ? "تسجيل الدخول كـ" : "Login As")
                    : (isArabic ? "إنشاء حساب كـ" : "Create Account As"),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.school, color: primaryBlue),
                title: Text(
                  texts['student']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (!isLogin) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentRegisterScreen(),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.business, color: primaryBlue),
                title: Text(
                  texts['company']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (!isLogin) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CompanyRegisterScreen(),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton(
    String title,
    Color bg,
    Color text,
    VoidCallback onPress, {
    Color? borderColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: borderColor != null
                ? BorderSide(color: borderColor)
                : (bg == Colors.white
                      ? BorderSide(color: primaryBlue)
                      : BorderSide.none),
          ),
          elevation: bg == Colors.white ? 0 : 4,
          shadowColor: Colors.black26,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: text,
          ),
        ),
      ),
    );
  }
}

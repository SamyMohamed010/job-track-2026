import 'package:flutter/material.dart';
import 'complete_profile.dart';
import '../../../core/student_service.dart';
import '../../../app_localization.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSubmitted = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final Color primaryBlue = const Color(0xFF229BD8);
  final Color grayTextColor = const Color(0xFF7E848E);

  // خريطة النصوص للترجمة
  Map<String, String> get texts {
    bool isAr = appLocalization.locale.languageCode == 'ar';
    return {
      'nameLabel': isAr ? "الاسم الكامل" : "Full Name",
      'nameHint': isAr ? "أدخل اسمك" : "Enter your full name",
      'emailLabel': isAr ? "البريد الإلكتروني" : "Email",
      'passLabel': isAr ? "كلمة المرور" : "Password",
      'confirmPassLabel': isAr ? "تأكيد كلمة المرور" : "Confirm Password",
      'btnCreate': isAr ? "إنشاء الحساب" : "Create Account",
      'alreadyHave': isAr ? "لديك حساب بالفعل؟ " : "Already have an account? ",
      'login': isAr ? "سجل دخول" : "Login",
      'req': isAr ? "مطلوب" : "Required",
      'emailErr': isAr ? "خطأ في الإيميل" : "Invalid email",
      'matchErr': isAr ? "كلمتا السر غير متطابقتين" : "Passwords do not match",
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appLocalization,
      builder: (context, child) {
        bool isAr = appLocalization.locale.languageCode == 'ar';
        return Scaffold(
          backgroundColor: const Color(0xFFEBEEF4),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              TextButton(
                onPressed: () => appLocalization.toggleLanguage(),
                child: Text(
                  isAr ? "English" : "العربية",
                  style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          body: Directionality(
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 5.0),
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
                              const SizedBox(height: 10),
                              Column(
                                children: [
                                  _buildFieldSection(
                                    texts['nameLabel'] ?? 'Name',
                                    texts['nameHint'] ?? 'Enter name',
                                    Icons.person_outline,
                                    controller: _nameController,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildFieldSection(
                                    texts['emailLabel'] ?? 'Email',
                                    "name@example.com",
                                    Icons.email_outlined,
                                    controller: _emailController,
                                    isEmail: true,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildPasswordFieldSection(
                                    texts['passLabel'] ?? 'Password',
                                    "********",
                                    controller: _passwordController,
                                    isVisible: _isPasswordVisible,
                                    onToggle: () => setState(() =>
                                        _isPasswordVisible = !_isPasswordVisible),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildPasswordFieldSection(
                                    texts['confirmPassLabel'] ?? 'Confirm Password',
                                    "********",
                                    controller: _confirmPasswordController,
                                    isVisible: _isConfirmPasswordVisible,
                                    onToggle: () => setState(() =>
                                        _isConfirmPasswordVisible =
                                            !_isConfirmPasswordVisible),
                                    isConfirm: true,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildActionButton(),
                              const SizedBox(height: 15),
                              _buildLoginLink(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 120, width: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo image.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.business,
                size: 80,
                color: Color(0xFF1E3A5F),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          texts['btnCreate'] ?? 'Create Account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldSection(
    String label,
    String hint,
    IconData icon, {
    required TextEditingController controller,
    bool isEmail = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: grayTextColor,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return texts['req'];
            }
            if (isEmail && !value.contains('@')) {
              return texts['emailErr'];
            }
            return null;
          },
          autovalidateMode:
              _isSubmitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          decoration: _inputDecoration(hint, icon),
        ),
      ],
    );
  }

  Widget _buildPasswordFieldSection(
    String label,
    String hint, {
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
    bool isConfirm = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: grayTextColor,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return texts['req'];
            }
            if (isConfirm && value != _passwordController.text) {
              return texts['matchErr'];
            }
            return null;
          },
          autovalidateMode:
              _isSubmitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          decoration: _passwordInputDecoration(hint, isVisible, onToggle),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 12),
      prefixIcon: Icon(icon, color: primaryBlue, size: 15),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }

  InputDecoration _passwordInputDecoration(
    String hint,
    bool isVisible,
    VoidCallback onToggle,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 12),
      prefixIcon: Icon(Icons.lock_outline, color: primaryBlue, size: 15),
      suffixIcon: IconButton(
        icon: Icon(
          isVisible ? Icons.visibility_off : Icons.visibility,
          color: grayTextColor,
          size: 15,
        ),
        onPressed: onToggle,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _isSubmitted = true;
          });
          if (_formKey.currentState!.validate()) {
            studentService.name = _nameController.text;
            studentService.email = _emailController.text;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CompleteProfileScreen(userName: _nameController.text),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          shadowColor: Colors.black26,
        ),
        child: Text(
          texts['btnCreate'] ?? 'Create Account',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          texts['alreadyHave'] ?? 'Already have an account?',
          style: const TextStyle(fontSize: 13),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            texts['login'] ?? 'Login',
            style: TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

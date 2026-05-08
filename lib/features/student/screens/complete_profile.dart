import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/student_service.dart';
import '../../../app_localization.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/database_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class CompleteProfileScreen extends StatefulWidget {
  final String userName;
  const CompleteProfileScreen({super.key, this.userName = "Student"});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final int currentYear = 2026;
  final Color primaryBlue = const Color(0xFF229BD8);
  final Color grayTextColor = const Color(0xFF7E848E);
  final Color frameBg = const Color(0xFFEBEEF4);
  final Color orangeColor = const Color(0xFFFDA00C);

  String? selectedFaculty;
  String? selectedMajor;
  String? selectedYear;
  String? studyStatus;
  String? cvFileName;
  Uint8List? cvFileData;
  String? profileImageName;
  Uint8List? profileImageBytes;
  bool isLoading = false;

  List<String> skills = [];
  final TextEditingController _skillController = TextEditingController();

  Map<String, dynamic> get content {
    bool isAr = appLocalization.locale.languageCode == 'ar';
    return {
      'title': isAr ? "استكمال الملف الشخصي" : "Complete Your Profile",
      'statusLabel': isAr ? "الحالة الدراسية" : "Study Status",
      'statusStudent': isAr ? "طالب" : "Student",
      'statusGrad': isAr ? "خريج" : "Graduate",
      'facLabel': isAr ? "الكلية" : "Faculty",
      'majorLabel': isAr ? "التخصص" : "Specialty",
      'programLabel': isAr
          ? "البرنامج الدراسي (اختياري)"
          : "Academic Program (Optional)",
      'yearLabel': isAr ? "السنة الدراسية" : "Study Year",
      'gradYearLabel': isAr ? "سنة التخرج" : "Graduation Year",
      'skillsLabel': isAr ? "المهارات" : "Skills",
      'cvLabel': isAr ? "رفع السيرة الذاتية" : "Upload CV",
      'verificationLabel': isAr
          ? "إثبات قيد / شهادة تخرج"
          : "Univ. Verification",
      'imgLabel': isAr ? "صورة الملف" : "Profile Image",
      'saveBtn': isAr ? "حفظ واستمرار" : "Save & Continue",
      'studentYears': isAr
          ? [
              "السنة الأولى",
              "السنة الثانية",
              "السنة الثالثة",
              "السنة الرابعة",
              if (selectedFaculty == "كلية الهندسة" ||
                  selectedFaculty == "Engineering")
                "السنة الخامسة",
            ]
          : [
              "First Year",
              "Second Year",
              "Third Year",
              "Fourth Year",
              if (selectedFaculty == "Engineering" ||
                  selectedFaculty == "كلية الهندسة")
                "Fifth Year",
            ],
      'gradYears': List.generate(
        10,
        (index) => (currentYear - index).toString(),
      ),
      'faculties': isAr
          ? ["كلية الحاسبات", "كلية الهندسة", "كلية العلوم", "كلية التجارة"]
          : ["Computers & Info", "Engineering", "Science", "Commerce"],
    };
  }

  String? selectedProgram;
  String? verificationFileName;
  Uint8List? verificationFileData;

  Future<String?> _uploadToCloudinary(Uint8List? bytes, String fileName, String folder) async {
    if (bytes == null) return null;
    try {
      final cloudName = 'dfeptodqc';
      final uploadPreset = 'nszqbsrs';
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      
      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;
      
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final json = jsonDecode(responseData);
        return json['secure_url'];
      } else {
        debugPrint('Cloudinary upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint("Error uploading to Cloudinary: $e");
      return null;
    }
  }

  Future<void> _pickVerification() async {
    bool isAr = appLocalization.locale.languageCode == 'ar';
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
        withData: true,
      );

      if (result != null) {
        setState(() {
          verificationFileName = result.files.single.name;
          verificationFileData = result.files.single.bytes;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAr ? "تم اختيار ملف التوثيق" : "Verification file selected",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr ? "فشل اختيار الملف" : "Failed to pick file"),
        ),
      );
    }
  }

  Future<void> _pickCV() async {
    bool isAr = appLocalization.locale.languageCode == 'ar';
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        withData: true,
      );

      if (result != null) {
        setState(() {
          cvFileName = result.files.single.name;
          cvFileData = result.files.single.bytes;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAr
                  ? "تم اختيار الملف: $cvFileName"
                  : "File selected: $cvFileName",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr ? "فشل اختيار الملف" : "Failed to pick file"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickProfileImage() async {
    bool isAr = appLocalization.locale.languageCode == 'ar';
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null) {
        setState(() {
          profileImageName = result.files.single.name;
          profileImageBytes = result.files.single.bytes;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isAr ? "تم اختيار الصورة" : "Image selected")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr ? "فشل اختيار الصورة" : "Failed to pick image"),
        ),
      );
    }
  }

  void _handleLogout() {
    bool isAr = appLocalization.locale.languageCode == 'ar';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isAr ? "تأكيد تسجيل الخروج" : "Confirm Logout",
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
        ),
        content: Text(
          isAr
              ? "هل أنت متأكد؟ سيتم فقدان البيانات غير المحفوظة."
              : "Are you sure? Unsaved data will be lost.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isAr ? "استمرار" : "Stay",
              style: TextStyle(color: primaryBlue),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text(
              isAr ? "خروج" : "Logout",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appLocalization,
      builder: (context, child) {
        bool isAr = appLocalization.locale.languageCode == 'ar';
        return Scaffold(
          backgroundColor: frameBg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: orangeColor, size: 15),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              TextButton(
                onPressed: () => appLocalization.toggleLanguage(),
                child: Text(
                  isAr ? "English" : "العربية",
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.logout, color: grayTextColor),
                onPressed: _handleLogout,
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: Directionality(
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Center(child: _buildLogo()),
                const SizedBox(height: 15),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content['title'],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 25),

                        _buildLabel(content['statusLabel']),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSelectionCard(
                                title: content['statusStudent'],
                                isSelected: studyStatus == 'student',
                                onTap: () =>
                                    setState(() => studyStatus = 'student'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildSelectionCard(
                                title: content['statusGrad'],
                                isSelected: studyStatus == 'graduate',
                                onTap: () =>
                                    setState(() => studyStatus = 'graduate'),
                              ),
                            ),
                          ],
                        ),
                        if (studyStatus != null) ...[
                          const SizedBox(height: 20),
                          _buildLabel(content['facLabel']),
                          _buildDropdown(
                            selectedFaculty,
                            isAr ? "اختر الكلية" : "Select Faculty",
                            content['faculties'],
                            (val) => setState(() => selectedFaculty = val),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel(content['majorLabel']),
                                    Container(
                                      width: 350,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: Colors.grey.shade100,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: TextField(
                                        onChanged: (val) =>
                                            setState(() => selectedMajor = val),
                                        style: const TextStyle(fontSize: 12),
                                        decoration: InputDecoration(
                                          hintText: isAr
                                              ? "مثلاً: علوم حاسب"
                                              : "e.g. CS",
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade300,
                                            fontSize: 12,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 12,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel(
                                      studyStatus == 'student'
                                          ? content['yearLabel']
                                          : content['gradYearLabel'],
                                    ),
                                    _buildDropdown(
                                      selectedYear,
                                      isAr ? "السنة" : "Year",
                                      studyStatus == 'student'
                                          ? content['studentYears']
                                          : content['gradYears'],
                                      (val) =>
                                          setState(() => selectedYear = val),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _buildLabel(content['programLabel']),
                          Container(
                            width: 350,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              onChanged: (val) =>
                                  setState(() => selectedProgram = val),
                              style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                hintText: isAr
                                    ? "مثلاً: فيزياء حاسب"
                                    : "e.g. Computer Physics",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontSize: 12,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildSkillsSection(),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildUploadArea(
                                  title: cvFileName ?? content['cvLabel'],
                                  icon: Icons.picture_as_pdf_outlined,
                                  onTap: _pickCV,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildUploadArea(
                                  title:
                                      profileImageName ?? content['imgLabel'],
                                  icon: Icons.image_outlined,
                                  onTap: _pickProfileImage,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildUploadArea(
                            title:
                                verificationFileName ??
                                content['verificationLabel'],
                            icon: Icons.verified_user_outlined,
                            onTap: _pickVerification,
                          ),
                          const SizedBox(height: 30),
                          _buildSaveButton(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo image.jpg',
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => const Icon(Icons.business, size: 40),
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? primaryBlue : Colors.black12),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : grayTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 5, right: 5),
    child: Text(
      text,
      style: TextStyle(
        color: grayTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ),
  );

  Widget _buildDropdown(
    String? value,
    String hint,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      width: 350,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          isExpanded: true,
          dropdownColor: Colors.white,
          hint: Text(
            hint,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade300),
          ),
          items: items
              .map(
                (i) => DropdownMenuItem(
                  value: i,
                  child: Text(i, style: const TextStyle(fontSize: 12)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSkillsSection() {
    bool isAr = appLocalization.locale.languageCode == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(content['skillsLabel']),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: skills.isEmpty
                        ? [
                            Text(
                              isAr ? "لا توجد مهارات" : "No skills added",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                            ),
                          ]
                        : skills.map((s) => _buildModernSkillChip(s)).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showAddSkillDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernSkillChip(String skill) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryBlue.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill,
            style: TextStyle(
              color: primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => setState(() => skills.remove(skill)),
            child: Icon(
              Icons.close,
              size: 14,
              color: primaryBlue.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSkillDialog(BuildContext context) {
    bool isAr = appLocalization.locale.languageCode == 'ar';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isAr ? "إضافة مهارة" : "Add Skill"),
        content: TextField(
          controller: _skillController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: isAr ? "اسم المهارة..." : "Skill name...",
          ),
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              setState(() => skills.add(val.trim()));
              _skillController.clear();
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isAr ? "إلغاء" : "Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_skillController.text.trim().isNotEmpty) {
                setState(() => skills.add(_skillController.text.trim()));
                _skillController.clear();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              isAr ? "إضافة" : "Add",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primaryBlue, size: 15),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  color: primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    bool isAr = appLocalization.locale.languageCode == 'ar';
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
                if (selectedFaculty != null && selectedYear != null) {
                  setState(() => isLoading = true);
                  studentService.faculty = selectedFaculty!;
                  studentService.specialty = selectedMajor ?? "";
                  studentService.graduationYear = selectedYear!;
                  studentService.program = selectedProgram;
                  studentService.skills = skills;
                  studentService.cvFileName = cvFileName;
                  studentService.cvFileData = cvFileData;
                  if (profileImageBytes != null)
                    studentService.profileImageBytes = profileImageBytes;
                  if (verificationFileData != null) {
                    studentService.verificationFileName = verificationFileName;
                    studentService.verificationFileData = verificationFileData;
                  }
                  try {
                    final uid = AuthService().currentUid;
                    if (uid != null) {
                      String? profileImageUrl;
                      if (profileImageBytes != null && profileImageName != null) {
                        profileImageUrl = await _uploadToCloudinary(profileImageBytes, profileImageName!, 'student_profiles');
                        studentService.profileImageUrl = profileImageUrl;
                      }

                      await DatabaseService(uid: uid).updateUserData({
                        'faculty': selectedFaculty,
                        'specialty': selectedMajor ?? "",
                        'graduationYear': selectedYear,
                        'program': selectedProgram,
                        'skills': skills,
                        'studyStatus': studyStatus,
                        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
                      });
                    }
                    if (mounted)
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HomeScreen(userName: widget.userName),
                        ),
                      );
                  } catch (e) {
                    if (mounted)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                  } finally {
                    if (mounted) setState(() => isLoading = false);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isAr ? "يرجى إكمال البيانات" : "Please complete data",
                      ),
                      backgroundColor: Colors.redAccent,
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
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                content['saveBtn'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}

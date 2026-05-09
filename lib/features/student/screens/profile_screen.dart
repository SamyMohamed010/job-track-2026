import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/student_service.dart';
import '../../widgets/language_toggle.dart';
import 'package:http/http.dart' as http;
import '../../../app_localization.dart';
// import 'home_screen.dart';
import 'applications_screen.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditMode = false;
  final Color primaryBlue = const Color(0xFF229BD8);
  final Color grayBg = const Color(0xFFEBEEF4);

  // Controllers for text editing
  late TextEditingController _nameController;
  late TextEditingController _yearController;
  late TextEditingController _facultyController;
  late TextEditingController _specialtyController;
  late TextEditingController _programController;
  final TextEditingController _skillController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: studentService.name);
    _yearController = TextEditingController(
      text: studentService.graduationYear,
    );
    _facultyController = TextEditingController(text: studentService.faculty);
    _specialtyController = TextEditingController(
      text: studentService.specialty,
    );
    _programController = TextEditingController(
      text: studentService.program ?? "",
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    _facultyController.dispose();
    _specialtyController.dispose();
    _programController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  Future<void> _pickCV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        withData: true,
      );

      if (result != null) {
        setState(() {
          studentService.cvFileName = result.files.single.name;
          studentService.cvFileData = result.files.single.bytes;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("File selected: ${studentService.cvFileName}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to pick file"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _viewCV() async {
    bool isAr = appLocalization.locale.languageCode == 'ar';
    if (studentService.cvUrl != null && studentService.cvUrl!.isNotEmpty) {
      final uri = Uri.parse(studentService.cvUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return;
      }
    }

    if (studentService.cvFileData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr ? "لم يتم رفع سيرة ذاتية بعد" : "No CV uploaded yet",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      if (kIsWeb) {
        final String base64Content = base64Encode(studentService.cvFileData!);
        final String fileName = studentService.cvFileName ?? "cv.pdf";
        final String mimeType = fileName.endsWith(".pdf")
            ? "application/pdf"
            : "application/msword";
        final String dataUri = 'data:$mimeType;base64,$base64Content';

        final Uri uri = Uri.parse(dataUri);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          _showCVPreviewDialog();
        }
      } else {
        // Mobile/Desktop: Save to temp file and open
        final tempDir = await getTemporaryDirectory();
        final fileName = studentService.cvFileName ?? "cv.pdf";
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(studentService.cvFileData!);

        final result = await OpenFilex.open(file.path);
        if (result.type != ResultType.done) {
          _showCVPreviewDialog();
        }
      }
    } catch (e) {
      _showCVPreviewDialog();
    }
  }

  void _showCVPreviewDialog() {
    bool isAr = appLocalization.locale.languageCode == 'ar';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.description, color: primaryBlue),
            const SizedBox(width: 10),
            Text(isAr ? "معاينة الملف" : "File Preview"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.picture_as_pdf, size: 60, color: Colors.redAccent),
            const SizedBox(height: 15),
            Text(
              studentService.cvFileName ?? "CV",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              isAr
                  ? "تم العثور على ملف السيرة الذاتية. في النسخة التجريبية، يمكنك رؤية اسم الملف وتفاصيله."
                  : "CV file found. In this preview, you can see the file name and details.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isAr ? "إغلاق" : "Close",
              style: TextStyle(color: primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true, // Essential for Web to get bytes
      );

      if (result != null) {
        setState(() {
          studentService.profileImageBytes = result.files.single.bytes;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Profile image updated!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to pick image"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickVerification() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
        withData: true,
      );

      if (result != null) {
        setState(() {
          studentService.verificationFileName = result.files.single.name;
          studentService.verificationFileData = result.files.single.bytes;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verification document uploaded!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to pick file"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleEditMode() async {
    if (_isEditMode) {
      // Save data back to service
      setState(() {
        _isEditMode = false;
      });

      String? newProfileImageUrl;
      if (studentService.profileImageBytes != null) {
        newProfileImageUrl = await _uploadToCloudinary(
          studentService.profileImageBytes,
          'profile_update_${DateTime.now().millisecondsSinceEpoch}.jpg',
          'student_profiles',
        );
      }

      String? newCvUrl;
      if (studentService.cvFileData != null && !studentService.cvFileData!.isEmpty) {
        newCvUrl = await _uploadToCloudinary(
          studentService.cvFileData,
          studentService.cvFileName ?? 'cv_${DateTime.now().millisecondsSinceEpoch}.pdf',
          'student_cvs',
          resourceType: 'auto',
        );
      }

      String? newVerificationUrl;
      if (studentService.verificationFileData != null && !studentService.verificationFileData!.isEmpty) {
        newVerificationUrl = await _uploadToCloudinary(
          studentService.verificationFileData,
          studentService.verificationFileName ?? 'verification_${DateTime.now().millisecondsSinceEpoch}.pdf',
          'student_verifications',
          resourceType: 'auto',
        );
      }

      setState(() {
        studentService.name = _nameController.text;
        studentService.graduationYear = _yearController.text;
        studentService.faculty = _facultyController.text;
        studentService.specialty = _specialtyController.text;
        studentService.program = _programController.text;
        if (newProfileImageUrl != null) {
          studentService.profileImageUrl = newProfileImageUrl;
        }
      });

      final uid = AuthService().currentUid;
      if (uid != null) {
        await DatabaseService(uid: uid).updateUserData({
          'name': studentService.name,
          'graduationYear': studentService.graduationYear,
          'faculty': studentService.faculty,
          'specialty': studentService.specialty,
          'program': studentService.program,
          if (newProfileImageUrl != null) 'profileImageUrl': newProfileImageUrl,
          if (newCvUrl != null) 'cvUrl': newCvUrl,
          if (newCvUrl != null) 'cvFileName': studentService.cvFileName,
          if (newVerificationUrl != null) 'verificationUrl': newVerificationUrl,
          if (newVerificationUrl != null) 'verificationFileName': studentService.verificationFileName,
          if (newVerificationUrl != null) 'isVerified': true,
        });
        if (newVerificationUrl != null) {
          studentService.isVerified = true;
        }
      }
    } else {
      setState(() {
        _isEditMode = true;
      });
    }
  }

  Future<String?> _uploadToCloudinary(
    Uint8List? bytes,
    String fileName,
    String folder,
    {String resourceType = 'image'}
  ) async {
    if (bytes == null) return null;
    try {
      final cloudName = 'dfeptodqc';
      final uploadPreset = 'nszqbsrs';
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload',
      );

      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;

      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final json = jsonDecode(responseData);
        return json['secure_url'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appLocalization,
      builder: (context, child) {
        bool isAr = appLocalization.locale.languageCode == 'ar';
        return Scaffold(
          backgroundColor: grayBg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xFFFDA00C),
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
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
                      height: 35,
                      width: 35,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.business, color: Color(0xFF1E3A5F)),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              LanguageToggle(),
              IconButton(
                icon: const Icon(
                  Icons.notifications_active_outlined,
                  color: Color(0xFFFDA00C),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: Directionality(
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileHeader(),
                  const SizedBox(height: 30),
                  const Divider(indent: 50, endIndent: 50, thickness: 1),
                  const SizedBox(height: 20),

                  // Skills and CV Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Skills Section
                        Expanded(child: _buildSkillsSection()),
                        const SizedBox(width: 20),
                        // CV Section
                        Expanded(child: _buildCVSection()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNav(),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _toggleEditMode,
            backgroundColor: primaryBlue,
            icon: Icon(_isEditMode ? Icons.check : Icons.edit),
            label: Text(
              _isEditMode ? (isAr ? "حفظ" : "Save") : (isAr ? "تعديل" : "Edit"),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          currentIndex: 2, // Profile is index 2
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ApplicationsScreen(),
                ),
              );
            } else if (index == 1) {
              Navigator.pushReplacementNamed(context, '/student_home');
            }
          },
          backgroundColor: Colors.white,
          selectedItemColor: primaryBlue,
          unselectedItemColor: primaryBlue.withOpacity(0.5),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.doc_text),
              label: "Applications",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    bool isAr = appLocalization.locale.languageCode == 'ar';
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundImage: studentService.profileImageBytes != null
                    ? MemoryImage(studentService.profileImageBytes!)
                    : (studentService.profileImageUrl != null &&
                          studentService.profileImageUrl!.isNotEmpty)
                    ? NetworkImage(studentService.profileImageUrl!)
                    : AssetImage(studentService.profileImage) as ImageProvider,
              ),
            ),
            if (_isEditMode)
              GestureDetector(
                onTap: _pickProfileImage,
                child: Container(
                  margin: const EdgeInsets.only(right: 5, bottom: 5),
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 15),

        // Name
        if (_isEditMode)
          _buildEditField(
            _nameController,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                studentService.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (studentService.isVerified) ...[
                const SizedBox(width: 8),
                const Icon(Icons.verified, color: Colors.blue, size: 20),
              ],
            ],
          ),

        const SizedBox(height: 10),

        // Verification Status Bar
        if (!studentService.isVerified) ...[
          GestureDetector(
            onTap: (studentService.verificationFileData == null && studentService.verificationUrl == null)
                ? _pickVerification
                : _pickCV,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.upload_file, size: 14, color: Colors.orange),
                  const SizedBox(width: 5),
                  Text(
                    (studentService.verificationFileData == null && studentService.verificationUrl == null)
                        ? (isAr
                              ? "ارفع إثبات القيد للتوثيق"
                              : "Upload verification doc")
                        : (isAr
                              ? "ارفع السيرة الذاتية للتوثيق"
                              : "Upload CV for verification"),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Education Details
        if (_isEditMode) ...[
          _buildEditField(_facultyController, showPencil: true),
          _buildEditField(_specialtyController, showPencil: true),
          _buildEditField(
            _programController,
            showPencil: true,
            hint: isAr ? "البرنامج" : "Program",
          ),
          _buildEditField(
            _yearController,
            prefix: isAr ? "سنة التخرج: " : "Graduated in ",
            showPencil: true,
          ),
        ] else ...[
          Text(
            studentService.faculty,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            studentService.specialty,
            style: const TextStyle(color: Colors.grey),
          ),
          if (studentService.program != null &&
              studentService.program!.isNotEmpty)
            Text(
              "${isAr ? "برنامج" : "Program"}: ${studentService.program}",
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          Text(
            "${(studentService.graduationYear.contains("Year") || studentService.graduationYear.contains("السنة")) ? (isAr ? "السنة الدراسية" : "Study Year") : (isAr ? "سنة التخرج" : "Graduated in")} ${studentService.graduationYear}",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            studentService.email,
            style: const TextStyle(color: Colors.blueGrey, fontSize: 13),
          ),
        ],
      ],
    );
  }

  Widget _buildEditField(
    TextEditingController controller, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    String prefix = "",
    bool showPencil = false,
    String hint = "",
  }) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(bottom: 5),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(vertical: 5),
          prefixText: prefix,
          suffixIcon: showPencil
              ? const Icon(Icons.edit, size: 14, color: Colors.blueAccent)
              : null,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      children: [
        Text(
          appLocalization.translate('skills'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: studentService.skills
                    .map((skill) => _buildSkillChip(skill))
                    .toList(),
              ),
              if (_isEditMode) ...[
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _skillController,
                        decoration: const InputDecoration(
                          hintText: "Add skill...",
                          isDense: true,
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.blue),
                      onPressed: () {
                        if (_skillController.text.isNotEmpty) {
                          setState(() {
                            studentService.skills.add(_skillController.text);
                            _skillController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              skill,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_isEditMode) ...[
            const SizedBox(width: 5),
            GestureDetector(
              onTap: () => setState(() => studentService.skills.remove(skill)),
              child: const Icon(Icons.close, size: 14, color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCVSection() {
    return Column(
      children: [
        Text(
          appLocalization.translate('cv'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          height: 100,
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.description, size: 40, color: Colors.grey.shade400),
              if (studentService.cvFileName != null)
                Positioned(
                  top: 0,
                  child: Text(
                    studentService.cvFileName!,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Positioned(
                bottom: 5,
                left: 10,
                child: GestureDetector(
                  onTap: _viewCV,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.visibility, color: primaryBlue, size: 20),
                  ),
                ),
              ),
              if (_isEditMode)
                Positioned(
                  top: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: _pickCV,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

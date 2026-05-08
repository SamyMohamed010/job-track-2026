import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'company_notifications_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../company_data.dart';

class CompanyEditProfileScreen extends StatefulWidget {
  const CompanyEditProfileScreen({super.key});

  @override
  _CompanyEditProfileScreenState createState() => _CompanyEditProfileScreenState();
}

class _CompanyEditProfileScreenState extends State<CompanyEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _industryController;
  late TextEditingController _overviewController;
  late TextEditingController _locationController;
  late TextEditingController _websiteController;
  
  XFile? _logoImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final data = CompanyData();
    _nameController = TextEditingController(text: data.name);
    _industryController = TextEditingController(text: data.industry);
    _overviewController = TextEditingController(text: data.overview);
    _locationController = TextEditingController(text: data.location);
    _websiteController = TextEditingController(text: data.website);
    _logoImage = data.logoImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _industryController.dispose();
    _overviewController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> pickLogo() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logoImage = pickedFile;
      });
    }
  }

  Future<String?> _uploadToCloudinary(File file, String folder) async {
    try {
      final cloudName = 'dfeptodqc';
      final uploadPreset = 'nszqbsrs';
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      
      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;
      
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final json = jsonDecode(responseData);
        return json['secure_url'];
      }
    } catch (e) {
      debugPrint("Cloudinary Error: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEEF4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, color: Color(0xFF229BD8), size: 15),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text("Edit Profile", style: TextStyle(color: Colors.black, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFFFDA00C)),
            onPressed: () => showCompanyNotifications(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo Picker
              Center(
                child: GestureDetector(
                  onTap: pickLogo,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFF229BD8), width: 2),
                    ),
                    child: _logoImage != null
                        ? ClipOval(
                            child: kIsWeb
                                ? Image.network(_logoImage!.path, fit: BoxFit.cover, width: 100, height: 100)
                                : Image.file(File(_logoImage!.path), fit: BoxFit.cover, width: 100, height: 100),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, color: Color(0xFF7E848E)),
                              Text("Logo", style: TextStyle(fontSize: 12, color: Color(0xFF7E848E))),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              _buildTextField("Company Name", _nameController),
              const SizedBox(height: 16),
              _buildTextField("Industry", _industryController),
              const SizedBox(height: 16),
              _buildTextField("Overview", _overviewController, maxLines: 4),
              const SizedBox(height: 16),
              _buildTextField("Location", _locationController),
              const SizedBox(height: 16),
              _buildTextField("Website", _websiteController),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isLoading = true);
                      
                      final data = CompanyData();
                      String? newLogoUrl;
                      
                      if (_logoImage != null && _logoImage != data.logoImage) {
                        newLogoUrl = await _uploadToCloudinary(File(_logoImage!.path), 'company_logos');
                      }

                      data.name = _nameController.text;
                      data.industry = _industryController.text;
                      data.overview = _overviewController.text;
                      data.location = _locationController.text;
                      data.website = _websiteController.text;
                      data.logoImage = _logoImage;
                      if (newLogoUrl != null) data.logoUrl = newLogoUrl;

                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .update({
                          'name': data.name,
                          'industry': data.industry,
                          'overview': data.overview,
                          'location': data.location,
                          'website': data.website,
                          if (newLogoUrl != null) 'logoUrl': newLogoUrl,
                        });
                      }

                      setState(() => _isLoading = false);
                      Navigator.pop(context, true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    backgroundColor: const Color(0xFF229BD8),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) => value!.isEmpty ? 'Field required' : null,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

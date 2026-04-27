import 'package:flutter/material.dart';
import 'company_notifications_sheet.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final data = CompanyData();
                      data.name = _nameController.text;
                      data.industry = _industryController.text;
                      data.overview = _overviewController.text;
                      data.location = _locationController.text;
                      data.website = _websiteController.text;
                      data.logoImage = _logoImage;
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
                  child: const Text("Save Changes", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
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

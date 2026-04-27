import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../company_data.dart';
import '../../../app_localization.dart';

class CompanyRegisterStep3Screen extends StatefulWidget {
  const CompanyRegisterStep3Screen({super.key});

  @override
  _CompanyRegisterStep3ScreenState createState() =>
      _CompanyRegisterStep3ScreenState();
}

class _CompanyRegisterStep3ScreenState
    extends State<CompanyRegisterStep3Screen> {
  XFile? _logoImage;
  XFile? _licenseImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickLogo() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _logoImage = pickedFile;
      });
    }
  }

  Future<void> pickLicense() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _licenseImage = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appLocalization,
      builder: (context, child) {
        return Scaffold(
      backgroundColor: const Color(0xFFEBEEF4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Container(
          width: 40,
          height: 40,
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
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, color: Color(0xFF229BD8), size: 20),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressBar(3, appLocalization.translate('upload_documents')),
            const SizedBox(height: 30),

            Text(
              appLocalization.translate('company_logo'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildImagePicker(appLocalization.translate('upload_logo'), _logoImage, pickLogo),

            const SizedBox(height: 20),

            Text(
              appLocalization.translate('commercial_license'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildImagePicker(appLocalization.translate('upload_license'), _licenseImage, pickLicense),

            const SizedBox(height: 40),

            // Register Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_logoImage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please upload your company logo'),
                      ),
                    );
                    return;
                  }
                  if (_licenseImage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please upload your company license'),
                      ),
                    );
                    return;
                  }

                  CompanyData().logoImage = _logoImage;
                  CompanyData().licenseImage = _licenseImage;

                  // Navigate to Main screen
                  Navigator.pushNamedAndRemoveUntil(context, '/company_main', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: const Color(0xFF229BD8),
                  elevation: 5,
                  shadowColor: const Color(0xFF229BD8).withOpacity(0.5),
                ),
                child: Text(
                  appLocalization.translate('register'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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

  Widget _buildProgressBar(int currentStep, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF7E848E),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 1; i <= 3; i++) ...[
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "$i",
                        style: TextStyle(
                          color: currentStep >= i
                              ? Colors.black
                              : const Color(0xFF7E848E),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: currentStep >= i
                              ? Colors.black
                              : const Color(0xFF7E848E).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < 3) const SizedBox(width: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker(String hint, XFile? image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        width: double.infinity,
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
        child: image == null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.upload_file,
                    color: Color(0xFF7E848E),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(hint, style: const TextStyle(color: Color(0xFF7E848E))),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: kIsWeb
                    ? Image.network(
                        image.path,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Image.file(
                        File(image.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
              ),
      ),
    );
  }
}

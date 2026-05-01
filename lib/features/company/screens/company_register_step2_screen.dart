import 'package:flutter/material.dart';
import 'company_register_step3_screen.dart';
import '../company_data.dart';
import '../../../app_localization.dart';
import '../../../shared/services/location_service.dart';

class CompanyRegisterStep2Screen extends StatefulWidget {
  const CompanyRegisterStep2Screen({super.key});

  @override
  _CompanyRegisterStep2ScreenState createState() => _CompanyRegisterStep2ScreenState();
}

class _CompanyRegisterStep2ScreenState extends State<CompanyRegisterStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _overviewController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  String? selectedIndustry;
  final List<String> industries = ["Software", "Medical", "Engineering", "Education"];

  @override
  void dispose() {
    _nameController.dispose();
    _overviewController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    super.dispose();
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
        title: null,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, color: Color(0xFF229BD8), size: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            _buildProgressBar(2, appLocalization.translate('company_details')),
            const SizedBox(height: 30),
            
            // Company Name
            _buildTextField(
              appLocalization.translate('company_name'), 
              _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter company name';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Industry Dropdown
            _buildDropdown(),
            const SizedBox(height: 16),
            
            // Company Overview
            _buildTextField(
              appLocalization.translate('tell_us_more'), 
              _overviewController,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter company overview';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Location
            _buildTextField(
              appLocalization.translate('location'), 
              _locationController,
              suffixIcon: IconButton(
                icon: const Icon(Icons.my_location, color: Color(0xFF229BD8)),
                onPressed: () async {
                  try {
                    final location = await LocationService.getCurrentLocation();
                    if (location != null) {
                      setState(() {
                        _locationController.text = location;
                      });
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter company location';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Website
            _buildTextField(
              appLocalization.translate('website'), 
              _websiteController,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter company website';
                return null;
              },
            ),
            const SizedBox(height: 30),
            
            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      side: const BorderSide(color: Color(0xFF229BD8)),
                    ),
                    child: Text(appLocalization.translate('back', defaultText: 'Back'), style: const TextStyle(fontSize: 16, color: Color(0xFF229BD8), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (selectedIndustry == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select an industry')),
                          );
                          return;
                        }
                        CompanyData().name = _nameController.text;
                        CompanyData().overview = _overviewController.text;
                        CompanyData().location = _locationController.text;
                        CompanyData().website = _websiteController.text;
                        CompanyData().industry = selectedIndustry!;
                        
                        Navigator.pushNamed(context, '/company_register_step3');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      backgroundColor: const Color(0xFF229BD8),
                      elevation: 5,
                      shadowColor: const Color(0xFF229BD8).withOpacity(0.5),
                    ),
                    child: Text(appLocalization.translate('next'), style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
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
                          color: currentStep >= i ? Colors.black : const Color(0xFF7E848E),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: currentStep >= i ? Colors.black : const Color(0xFF7E848E).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < 3) const SizedBox(width: 12),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {int maxLines = 1, String? Function(String?)? validator, Widget? suffixIcon}) {
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
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF7E848E)),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedIndustry,
          hint: const Text("Select Industry", style: TextStyle(color: Color(0xFF7E848E))),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFDA00C)),
          items: industries.map((item) => DropdownMenuItem(
            value: item, 
            child: Text(item),
          )).toList(),
          onChanged: (value) {
            setState(() {
              selectedIndustry = value;
            });
          },
        ),
      ),
    );
  }
}

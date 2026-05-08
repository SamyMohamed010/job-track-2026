import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../company_data.dart';
import 'company_notifications_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/services/location_service.dart';

class CompanyPostJobScreen extends StatefulWidget {
  const CompanyPostJobScreen({super.key});

  @override
  _CompanyPostJobScreenState createState() => _CompanyPostJobScreenState();
}

class _CompanyPostJobScreenState extends State<CompanyPostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _salaryFromController = TextEditingController();
  final TextEditingController _salaryToController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();

  String? selectedLocationType;
  final List<String> locationTypes = ["On-site", "Remote", "Hybrid"];

  String? selectedJobType;
  final List<String> jobTypes = ["Full-time", "Part-time", "Contract", "Internship"];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _locationController.dispose();
    _salaryFromController.dispose();
    _salaryToController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEEF4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header: Notification only
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => showCompanyNotifications(context),
                      child: const Icon(Icons.notifications, color: Color(0xFFFDA00C)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Job Title
                _buildTextField("Job Title", _titleController),
                const SizedBox(height: 16),

                // Job Description
                _buildTextField(
                  "Job Description\nDesigns, develops, and tests software for Google's products and services, working on innovative projects and collaborating with teams.",
                  _descriptionController,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                
                const Divider(color: Colors.black12, thickness: 1),
                const SizedBox(height: 16),

                // Job Requirements
                _buildTextField(
                  "Job Requirements\n✔ C++\n✔ Java\n✔ Node js",
                  _requirementsController,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                
                const Divider(color: Colors.black12, thickness: 1),
                const SizedBox(height: 16),

                // Location Row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        "Location", 
                        _locationController,
                        prefixIcon: const Icon(Icons.location_on, color: Colors.red, size: 20),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.my_location, color: Color(0xFF229BD8), size: 20),
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
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                        hint: "Location Type",
                        value: selectedLocationType,
                        items: locationTypes,
                        onChanged: (val) => setState(() => selectedLocationType = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Job Type
                _buildDropdown(
                  hint: "Job type",
                  value: selectedJobType,
                  items: jobTypes,
                  onChanged: (val) => setState(() => selectedJobType = val),
                ),
                const SizedBox(height: 16),

                // Salary
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        "Salary From", 
                        _salaryFromController, 
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        "To", 
                        _salaryToController, 
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Application Deadline
                _buildTextField(
                  "Application Deadline", 
                  _deadlineController,
                  prefixIcon: const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _deadlineController.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                      });
                    }
                  },
                ),
                const SizedBox(height: 30),

                // Post Job Button
                Center(
                  child: SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (selectedLocationType == null || selectedJobType == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select location type and job type')),
                            );
                            return;
                          }

                          // Save to Firebase
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            FirebaseFirestore.instance.collection('users').doc(user.uid).get().then((doc) {
                              String companyName = 'Unknown Company';
                              String logoUrl = '';
                              if (doc.exists) {
                                companyName = doc.data()?['name'] ?? 'Unknown Company';
                                logoUrl = doc.data()?['logoUrl'] ?? '';
                              }

                              FirebaseFirestore.instance.collection('jobs').add({
                                'companyId': user.uid,
                                'companyName': companyName,
                                'companyLogoUrl': logoUrl,
                                'title': _titleController.text,
                                'description': _descriptionController.text,
                                'requirements': _requirementsController.text,
                                'location': _locationController.text,
                                'locationType': selectedLocationType,
                                'jobType': selectedJobType,
                                'salaryFrom': _salaryFromController.text,
                                'salaryTo': _salaryToController.text,
                                'deadline': _deadlineController.text,
                                'createdAt': FieldValue.serverTimestamp(),
                              });
                            });
                          }

                          // Add the job to CompanyData (local cache)
                          final newJob = JobModel(
                            title: _titleController.text,
                            description: _descriptionController.text,
                            requirements: _requirementsController.text,
                            location: _locationController.text,
                            locationType: selectedLocationType!,
                            jobType: selectedJobType!,
                            salaryFrom: _salaryFromController.text,
                            salaryTo: _salaryToController.text,
                            deadline: _deadlineController.text,
                          );

                          CompanyData().jobs.add(newJob);

                          // Clear fields
                          _titleController.clear();
                          _descriptionController.clear();
                          _requirementsController.clear();
                          _locationController.clear();
                          _salaryFromController.clear();
                          _salaryToController.clear();
                          _deadlineController.clear();
                          setState(() {
                            selectedLocationType = null;
                            selectedJobType = null;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Job Posted Successfully!')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        backgroundColor: const Color(0xFF229BD8),
                        elevation: 0,
                      ),
                      child: const Text("Post Job", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {int maxLines = 1, Widget? prefixIcon, Widget? suffixIcon, TextInputType? keyboardType, bool readOnly = false, VoidCallback? onTap, List<TextInputFormatter>? inputFormatters, String? Function(String?)? validator}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: prefixIcon != null ? 8 : 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        inputFormatters: inputFormatters,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF7E848E)),
          border: InputBorder.none,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildDropdown({required String hint, required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
          value: value,
          hint: Text(hint, style: const TextStyle(color: Color(0xFF7E848E))),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFDA00C)),
          items: items.map((item) => DropdownMenuItem(
            value: item, 
            child: Text(item),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

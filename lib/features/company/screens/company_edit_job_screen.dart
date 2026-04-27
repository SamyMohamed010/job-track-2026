import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../company_data.dart';
import 'company_notifications_sheet.dart';

class CompanyEditJobScreen extends StatefulWidget {
  final JobModel job;
  final int jobIndex;

  const CompanyEditJobScreen({super.key, required this.job, required this.jobIndex});

  @override
  _CompanyEditJobScreenState createState() => _CompanyEditJobScreenState();
}

class _CompanyEditJobScreenState extends State<CompanyEditJobScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _requirementsController;
  late TextEditingController _locationController;
  late TextEditingController _salaryFromController;
  late TextEditingController _salaryToController;
  late TextEditingController _deadlineController;

  String? selectedLocationType;
  final List<String> locationTypes = ["On-site", "Remote", "Hybrid"];

  String? selectedJobType;
  final List<String> jobTypes = ["Full-time", "Part-time", "Contract", "Internship"];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.job.title);
    _descriptionController = TextEditingController(text: widget.job.description);
    _requirementsController = TextEditingController(text: widget.job.requirements);
    _locationController = TextEditingController(text: widget.job.location);
    _salaryFromController = TextEditingController(text: widget.job.salaryFrom);
    _salaryToController = TextEditingController(text: widget.job.salaryTo);
    _deadlineController = TextEditingController(text: widget.job.deadline);
    selectedLocationType = widget.job.locationType;
    selectedJobType = widget.job.jobType;
  }

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
                // Top Header: Back button and Notification
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFDA00C), size: 20),
                    ),
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
                  "Job Description",
                  _descriptionController,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                
                const Divider(color: Colors.black12, thickness: 1),
                const SizedBox(height: 16),

                // Job Requirements
                _buildTextField(
                  "Job Requirements",
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

                // Save Changes Button
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

                          // Update the job in CompanyData
                          final updatedJob = JobModel(
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

                          CompanyData().jobs[widget.jobIndex] = updatedJob;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Job Updated Successfully!')),
                          );
                          
                          Navigator.pop(context, true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        backgroundColor: const Color(0xFF229BD8),
                        elevation: 0,
                      ),
                      child: const Text("Save Changes", style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildTextField(String hint, TextEditingController controller, {int maxLines = 1, Widget? prefixIcon, TextInputType? keyboardType, bool readOnly = false, VoidCallback? onTap, List<TextInputFormatter>? inputFormatters, String? Function(String?)? validator}) {
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

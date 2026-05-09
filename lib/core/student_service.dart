import 'dart:typed_data';

class StudentService {
  static final StudentService _instance = StudentService._internal();
  factory StudentService() => _instance;
  StudentService._internal();

  String name = "Ahmed Khalid";
  String email = "student@example.com";
  String faculty = "Engineering";
  String specialty = "Computer Science";
  String? program = "General";
  String graduationYear = "2026";
  List<String> skills = [
    "Teamwork",
    "Java",
    "Data analysis",
    "Critical thinking",
    "Time management",
    "Excel",
    "soft skills",
    "Laboratory techniques",
  ];
  String? cvFileName;
  Uint8List? cvFileData;
  String? cvUrl;
  
  String profileImage = "assets/images/pro.jpg";
  Uint8List? profileImageBytes;
  String? profileImageUrl;
  String about =
      "Passionate Computer Science student with a focus on Flutter development. Eager to learn and contribute to innovative projects.";

  // Verification Document
  String? verificationFileName;
  Uint8List? verificationFileData;
  String? verificationUrl;
  
  bool isVerified = false; // Will be set from database
}

final studentService = StudentService();

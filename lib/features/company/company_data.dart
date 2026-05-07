import 'package:image_picker/image_picker.dart';

class JobModel {
  final String title;
  final String description;
  final String requirements;
  final String location;
  final String locationType;
  final String jobType;
  final String salaryFrom;
  final String salaryTo;
  final String deadline;

  JobModel({
    required this.title,
    required this.description,
    required this.requirements,
    required this.location,
    required this.locationType,
    required this.jobType,
    required this.salaryFrom,
    required this.salaryTo,
    required this.deadline,
  });
}

class CompanyData {
  static final CompanyData _instance = CompanyData._internal();
  factory CompanyData() => _instance;
  CompanyData._internal();

  String name = "Organic";
  String industry = "Healthcare";
  String overview = "A leading manufacturer and distributor of high-quality pharmaceutical products, dedicated to improving public health through innovative healthcare solutions";
  String location = "Cairo,Egypt";
  String website = "www.organic.com";
  String email = "";
  String password = "";
  
  XFile? logoImage;
  XFile? licenseImage;
  String? logoUrl;
  String? licenseUrl;
  
  List<JobModel> jobs = [];
}

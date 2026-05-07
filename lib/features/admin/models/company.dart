import 'package:flutter/material.dart';

class Company {
  final String name;
  final String email;
  final Color brandColor;
  final String logoUrl;
  final String location;
  final String status;
  final String licenseUrl;
  final String description;
  final String website;
  bool isApproved;
  String? id;

  Company({
    required this.name,
    required this.email,
    required this.brandColor,
    required this.logoUrl,
    required this.location,
    this.status = 'pending',
    this.isApproved = false,
    this.licenseUrl = '',
    this.description = '',
    this.website = '',
    this.id,
  });
}

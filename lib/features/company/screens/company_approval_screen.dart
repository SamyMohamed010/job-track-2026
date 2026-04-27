import 'package:flutter/material.dart';

class CompanyApprovalScreen extends StatelessWidget {
  const CompanyApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEEF4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Illustration placeholder or actual image
              Image.asset(
                'assets/images/waiting_approval.png',
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                   return const Icon(Icons.hourglass_empty, size: 100, color: Color(0xFFFDA00C));
                },
              ),
              const SizedBox(height: 40),
              
              // First text block
              const Text(
                "Your request has been submitted and\nis waiting for approval.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7E848E),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              
              // Divider
              const Divider(
                color: Color(0xFF7E848E),
                thickness: 0.5,
                indent: 40,
                endIndent: 40,
              ),
              const SizedBox(height: 24),
              
              // Second text block
              const Text(
                "We will notify you once its been reviewed.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7E848E),
                ),
              ),
              const SizedBox(height: 40),
              
              // Three dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(const Color(0xFFD3D3D3)),
                  const SizedBox(width: 8),
                  _buildDot(const Color(0xFF7E848E)),
                  const SizedBox(width: 8),
                  _buildDot(const Color(0xFF7E848E)),
                ],
              ),
              const Spacer(),
              
              // Cancel Request Button
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/company_register_step1', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: const Color(0xFF229BD8),
                  ),
                  child: const Text(
                    "Cancel Request", 
                    style: TextStyle(
                      fontSize: 16, 
                      color: Colors.white, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

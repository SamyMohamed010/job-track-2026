import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'company').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        final total = docs.length;
        final approved = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['isApproved'] == true || data['status'] == 'approved';
        }).length;
        final rejected = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['status'] == 'rejected';
        }).length;

        final percent = total > 0 ? (approved / total * 100).toInt() : 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. الكروت العلوية (Total, Approved, Rejected)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTopStatCard("Total Companies", total.toString()),
                  _buildTopStatCard("Approved", approved.toString()),
                  _buildTopStatCard("Rejected", rejected.toString()),
                ],
              ),
          const SizedBox(height: 30),

          // 2. قسم Application Status
          const Text(
            "Application Status",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              height: 120,
              width: 200,
              child: Stack(
                children: [
                  // الدائرة الخضراء (تنسيق أنظف)
                  Positioned(
                    left: 0,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50), // درجة أخضر مريحة
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          "\$percent%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // الدائرة الحمراء (إضافة شفافية خفيفة)
                  Positioned(
                    right: 20,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE57373).withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),

          // 3. قسم Applications by Role
          const Text(
            "Applications by Role",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // استخدمنا درجات ألوان متناسقة مع الهوية الجديدة
              Expanded(child: _buildBarChartItem("Pharmacist", 120, const Color(0xFF1A11A3))),
              Expanded(child: _buildBarChartItem("Assistant", 80, const Color(0xFF2C116B))),
              Expanded(child: _buildBarChartItem("Intern", 50, const Color(0xFFB01E7E))),
              Expanded(child: _buildBarChartItem("Manager", 70, const Color(0xFFFDA00C))),
            ],
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildTopStatCard(String title, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartItem(String label, double height, Color color) {
    return Column(
      children: [
        Container(
          width: 30, // عرضنا العمود شوية عشان يبقى أوضح
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(5),
            ), // دوران من فوق بس
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

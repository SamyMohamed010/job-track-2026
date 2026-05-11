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
                      child: Center(
                        child: Text(
                          "$percent%",
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
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('applications').snapshots(),
            builder: (context, appSnapshot) {
              if (appSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final appDocs = appSnapshot.data?.docs ?? [];
              final Map<String, int> roleCounts = {};
              
              // Group by job title from applications
              for (var doc in appDocs) {
                final data = doc.data() as Map<String, dynamic>;
                String title = data['jobTitle']?.toString() ?? 'Other';
                
                // Cleanup and normalize title
                title = title.trim();
                if (title.toLowerCase() == 'it') {
                  title = 'IT';
                } else if (title.isNotEmpty) {
                  // Capitalize each word for professional look
                  title = title.split(' ').map((word) => word.isNotEmpty 
                    ? word[0].toUpperCase() + word.substring(1).toLowerCase() 
                    : '').join(' ');
                }

                // If title is too long, take the first two words for the chart label
                final words = title.split(' ');
                final displayTitle = words.length > 1 ? "${words[0]} ${words[1]}" : words[0];
                
                roleCounts[displayTitle] = (roleCounts[displayTitle] ?? 0) + 1;
              }
              
              // Sort by count descending
              final sortedRoles = roleCounts.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              
              // Get top 4
              final topRoles = sortedRoles.take(4).toList();
              
              // Colors for the bars
              final colors = [
                const Color(0xFF1A11A3),
                const Color(0xFF2C116B),
                const Color(0xFFB01E7E),
                const Color(0xFFFDA00C),
              ];
              
              // Calculate max count for scaling (min 1 to avoid division by zero)
              final maxCount = topRoles.isNotEmpty ? topRoles.first.value : 1;
              final maxHeight = 120.0;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: topRoles.isEmpty 
                  ? [const Text("No applications available")]
                  : List.generate(topRoles.length, (index) {
                      final role = topRoles[index];
                      // Scale height proportional to max count (min height 30)
                      final height = (role.value / maxCount) * maxHeight;
                      return Expanded(
                        child: _buildBarChartItem(
                          role.key,
                          height < 30 ? 30 : height, 
                          colors[index % colors.length]
                        ),
                      );
                    }),
              );
            },
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
          width: 30,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(5),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 35, // Fixed height for labels to keep them aligned
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

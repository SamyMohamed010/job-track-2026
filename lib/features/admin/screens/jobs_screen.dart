import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job.dart';
import '../widgets/job_card.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          debugPrint("Firestore Error: ${snapshot.error}");
          return const Center(child: Text('Error loading jobs'));
        }

        final docs = snapshot.data?.docs ?? [];
        
        // Manual sort to avoid needing a composite index in Firestore
        final sortedDocs = docs.toList()
          ..sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = aData['createdAt'] as Timestamp?;
            final bTime = bData['createdAt'] as Timestamp?;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime); // Descending
          });

        final jobs =
            sortedDocs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final String salary =
                  data['salary'] ??
                  ((data['salaryFrom'] ?? '').toString().isNotEmpty &&
                          (data['salaryTo'] ?? '').toString().isNotEmpty
                      ? '${data['salaryFrom']} - ${data['salaryTo']}'
                      : 'Not specified');
              return Job(
                id: doc.id,
                companyId: data['companyId'] ?? '',
                position: (data['title']?.toString().trim().isNotEmpty == true) ? data['title'] : 'No title',
                companyName: (data['companyName']?.toString().trim().isNotEmpty == true) ? data['companyName'] : 'Unknown Company',
                location: (data['location']?.toString().trim().isNotEmpty == true) ? data['location'] : 'Unknown location',
                salary: salary,
                logoUrl: (data['companyLogoUrl']?.toString().trim().isNotEmpty == true)
                    ? data['companyLogoUrl']
                    : (data['logoUrl']?.toString().trim().isNotEmpty == true) 
                        ? data['logoUrl']
                        : 'https://img.icons8.com/color/512/business.png',
                status: data['status'] ?? 'pending',
              );
            }).toList();

        if (jobs.isEmpty) {
          return const Center(child: Text('No jobs found'));
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: jobs.map((job) => JobCard(job: job)).toList(),
            ),
          ),
        );
      },
    );
  }
}

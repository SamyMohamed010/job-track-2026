import 'package:flutter/material.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // لون الخلفية الرمادي الفاتح
      appBar: AppBar(
        title: Text('Student', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF333333),
        leading: Icon(Icons.menu, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // الجزء العلوي: لوجو الشركة والبيانات
            _buildCompanyHeader(),
            SizedBox(height: 20),
            
            // قسم About
            _buildSectionCard(
              title: "About Organic",
              content: "A leading manufacturer and distributor of high-quality pharmaceutical products...",
            ),
            SizedBox(height: 20),

            // قسم الوظائف (Jobs)
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Posted Jobs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 10),
            _buildJobCard("Pharmaceutical Control", "Full-Time", "Cairo, Egypt"),
            _buildJobCard("Quality Analyst", "Internship", "Alexandria, Egypt"),
            
            SizedBox(height: 20),
            // زرار الـ Edit
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.edit),
              label: Text("Edit"),
              style: ElevatedButton.styleFrom(shape: StadiumBorder()),
            )
          ],
        ),
      ),
    );
  }

  // Widget خاص بالهيدر
  Widget _buildCompanyHeader() {
    return Column(
      children: [
        CircleAvatar(radius: 40, backgroundColor: Colors.indigo), // حط هنا اللوجو
        SizedBox(height: 10),
        Text("Organic", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text("Cairo, Egypt", style: TextStyle(color: Colors.grey)),
        SizedBox(height: 10),
        ElevatedButton(onPressed: () {}, child: Text("Follow")),
      ],
    );
  }

  // Widget للكروت البيضاء (About & Jobs)
  Widget _buildSectionCard({required String title, required String content}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          Text(content, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildJobCard(String title, String type, String location) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(Icons.business, color: Colors.orange),
        title: Text(title),
        subtitle: Text(location),
        trailing: Chip(label: Text(type)),
      ),
    );
  }
}

// lib/teacher/presum.dart
import 'package:flutter/material.dart';
import 'teacher_class_list.dart';
import 'pre_test_completion.dart';
import 'pre_test_pass_rate.dart';

class PresumScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // 🔹 ปุ่มย้อนกลับ
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // กลับไปหน้าก่อนหน้า (Home)
          },
          tooltip: 'กลับสู่หน้าหลัก',
        ),
        title: Text('สรุปก่อนการเรียน'),
        backgroundColor: Color(0xFF6A11CB),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔹 เมนู "ผลการเรียนนักเรียน"
            _buildMenuCard(
              context: context,
              title: 'กราฟจำนวนการสอบก่อนเรียน',
              icon: Icons.bar_chart_outlined,
              iconColor: Color(0xFF3498DB),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PreTestCompletionScreen()),
                );
              },
            ),
            SizedBox(height: 16),

            // 🔹 เมนู "สรุปการอ่านเนื้อหา"
            _buildMenuCard(
              context: context,
              title: 'เปอร์เซ็นต์การสอบก่อนเรียน',
              icon: Icons.book_outlined,
              iconColor: Color(0xFF2ECC71),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PreTestAverageScoreScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
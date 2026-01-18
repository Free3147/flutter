// lib/teacher/teacher_student_detail.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeacherStudentDetailScreen extends StatelessWidget {
  final String studentUid;
  final String studentName;

  const TeacherStudentDetailScreen({
    Key? key,
    required this.studentUid,
    required this.studentName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ข้อมูลนักเรียน'),
        backgroundColor: Color(0xFF6A11CB),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              studentName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('ข้อมูลความคืบหน้า', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),

            _buildProgressSection(context, studentUid),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, String uid) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('progress').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

        // 🔹 ดึงคะแนนจาก progress (ถูกบันทึกเมื่อทำแบบทดสอบ)
        final preTestScore = data['preTestScore'] as int?;
        final preTestTotal = data['preTestTotal'] as int? ?? 20;
        final postTestScore = data['postTestScore'] as int?;
        final postTestTotal = data['postTestTotal'] as int? ?? 20;

        // 🔹 ดึงข้อมูลการใช้คำสั่งในเกม
        final gameCommandUsage = data['gameCommandUsage'] as Map<String, dynamic>?;
        int totalCommands = 0;
        if (gameCommandUsage != null) {
          for (var levelData in gameCommandUsage.values) {
            if (levelData is Map<String, dynamic>) {
              totalCommands += levelData['_total'] as int? ?? 0;
            }
          }
        }

        return Column(
          children: [
            // 🔹 แบบทดสอบก่อนเรียน
            _buildProgressItem(
              title: 'แบบทดสอบก่อนเรียน',
              status: preTestScore != null ? '$preTestScore/$preTestTotal' : 'ยังไม่ได้ทำ',
            ),

            // 🔹 อ่านเนื้อหา
            _buildProgressItem(
              title: 'อ่านเนื้อหา',
              status: data['bookViewed'] == true
                  ? '${data['bookProgress'] ?? 0}%'
                  : 'ยังไม่ได้อ่าน',
            ),

            // 🔹 เล่นเกม → แสดงจำนวนคำสั่งทั้งหมด
            _buildProgressItem(
              title: 'เล่นเกม',
              status: totalCommands > 0 
                  ? 'ใช้ทั้งหมด $totalCommands คำสั่ง' 
                  : 'ยังไม่เล่น',
            ),

            // 🔹 แบบทดสอบหลังเรียน
            _buildProgressItem(
              title: 'แบบทดสอบหลังเรียน',
              status: postTestScore != null ? '$postTestScore/$postTestTotal' : 'ยังไม่ได้ทำ',
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressItem({
    required String title,
    required String status,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(title, style: TextStyle(fontSize: 16)),
            ),
            Text(status, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
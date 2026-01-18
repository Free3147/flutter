// lib/teacher/teacher_dashboard.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeacherDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายงานความคืบหน้านักเรียน'),
        backgroundColor: Color(0xFF6A11CB),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'student')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data!.docs;

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final studentId = student.id;
              final username = student['username'] ?? 'ไม่ระบุ';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('progress')
                    .doc(studentId)
                    .get(),
                builder: (context, progressSnap) {
                  if (!progressSnap.hasData) {
                    return _buildStudentCard(username: username, loading: true);
                  }

                  final data = progressSnap.data!.data() as Map<String, dynamic>? ?? {};
                  final preTest = data['preTestCompleted'] == true ? '✅ ทำแล้ว' : '❌ ยังไม่ทำ';
                  final postTest = data['postTestCompleted'] == true ? '✅ ทำแล้ว' : '❌ ยังไม่ทำ';
                  final book = data['bookViewed'] == true ? '✅ อ่านแล้ว' : '❌ ยังไม่อ่าน';
                  final game = data['gamePlayed'] == true ? '✅ เล่นแล้ว' : '❌ ยังไม่เล่น';

                  return _buildStudentCard(
                    username: username,
                    preTest: preTest,
                    postTest: postTest,
                    book: book,
                    game: game,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStudentCard({
    required String username,
    bool loading = false,
    String? preTest,
    String? postTest,
    String? book,
    String? game,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: loading
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('นักเรียน: $username', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 8),
                  Text('กำลังโหลดข้อมูล...', style: TextStyle(color: Colors.grey)),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('นักเรียน: $username', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 8),
                  _buildProgressRow('แบบทดสอบก่อนเรียน:', preTest!),
                  _buildProgressRow('เนื้อหา:', book!),
                  _buildProgressRow('เกม:', game!),
                  _buildProgressRow('แบบทดสอบหลังเรียน:', postTest!),
                ],
              ),
      ),
    );
  }

  Widget _buildProgressRow(String label, String status) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(width: 8),
        Text(status, style: TextStyle(color: status.contains('✅') ? Colors.green : Colors.red)),
      ],
    );
  }
}
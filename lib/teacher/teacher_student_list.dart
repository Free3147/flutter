// lib/teacher/teacher_student_list.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'teacher_student_detail.dart'; // 🔹 หน้ารายละเอียดใหม่

class TeacherStudentListScreen extends StatelessWidget {
  final String grade;
  final String room;

  const TeacherStudentListScreen({
    Key? key,
    required this.grade,
    required this.room,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ชั้น $grade ห้อง $room'),
        backgroundColor: Color(0xFF6A11CB),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'student')
            .where('grade', isEqualTo: grade)
            .where('classRoom', isEqualTo: room)
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
              final uid = student.id;
              final fullName = student['fullName'] ?? 'ไม่ระบุชื่อ';
              final username = student['username'] ?? '';

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(fullName.substring(0, 1).toUpperCase()),
                    backgroundColor: Color(0xFF2ECC71),
                  ),
                  title: Text(fullName, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('ชื่อผู้ใช้: $username'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // 🔹 ไปหน้ารายละเอียด
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeacherStudentDetailScreen(
                          studentUid: uid,
                          studentName: fullName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
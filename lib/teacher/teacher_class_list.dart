// lib/teacher/teacher_class_list.dart
import 'package:flutter/material.dart';
import 'teacher_room_list.dart';
import 'teacher_main.dart'; // 🔹

class TeacherClassListScreen extends StatelessWidget {
  final List<String> grades = ['ป.1', 'ป.2', 'ป.3', 'ป.4', 'ป.5', 'ป.6'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 🔹 ปิดปุ่ม back อัตโนมัติ
        automaticallyImplyLeading: false,
        // 🔹 สร้างปุ่มกลับเอง
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // กลับไปหน้า Home และล้าง stack
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => TeacherMainScreen()),
              (route) => false,
            );
          },
          tooltip: 'กลับสู่เมนู',
        ),
        title: Text('เลือกชั้นเรียน'),
        backgroundColor: Color(0xFF6A11CB),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: grades.length,
        itemBuilder: (context, index) {
          final grade = grades[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.school, color: Color(0xFF6A11CB)),
              title: Text(
                grade,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeacherRoomListScreen(grade: grade),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
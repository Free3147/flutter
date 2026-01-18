// lib/teacher/teacher_room_list.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'teacher_student_list.dart';

class TeacherRoomListScreen extends StatelessWidget {
  final String grade;

  const TeacherRoomListScreen({Key? key, required this.grade}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ชั้น $grade - เลือกห้อง'),
        backgroundColor: Color(0xFF6A11CB),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'student')
            .where('grade', isEqualTo: grade)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // ดึงรายการ "ห้อง" ที่ไม่ซ้ำกัน
          final rooms = <String>{};
          for (var doc in snapshot.data!.docs) {
            final room = doc['classRoom'] as String?;
            if (room != null) rooms.add(room);
          }

          final roomList = rooms.toList()..sort();

          return ListView.builder(
            itemCount: roomList.length,
            itemBuilder: (context, index) {
              final room = roomList[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.house, color: Color(0xFF3498DB)),
                  title: Text(
                    'ห้อง $room',
                    style: TextStyle(fontSize: 18),
                  ),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeacherStudentListScreen(
                          grade: grade,
                          room: room,
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
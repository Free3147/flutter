// lib/student/student_progress.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentProgressScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('ความคืบหน้า')),
        body: Center(child: Text('ไม่พบผู้ใช้')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('ความคืบหน้าการเรียน'),
        backgroundColor: Color(0xFF6A11CB),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('progress').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final preTestCompleted = data['preTestCompleted'] == true;
          final bookViewed = data['bookViewed'] == true;
          final gamePlayed = data['gamePlayed'] == true;
          final postTestCompleted = data['postTestCompleted'] == true;

          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressItem(
                  title: 'แบบทดสอบก่อนเรียน',
                  completed: preTestCompleted,
                ),
                _buildProgressItem(
                  title: 'อ่านเนื้อหา',
                  completed: bookViewed,
                ),
                _buildProgressItem(
                  title: 'เล่นเกม',
                  completed: gamePlayed,
                ),
                _buildProgressItem(
                  title: 'แบบทดสอบหลังเรียน',
                  completed: postTestCompleted,
                ),
                SizedBox(height: 30),
                _buildOverallProgress(preTestCompleted, bookViewed, gamePlayed, postTestCompleted),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressItem({required String title, required bool completed}) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: completed ? Colors.green : Colors.grey,
        ),
        title: Text(title),
        trailing: completed
            ? Icon(Icons.chevron_right, color: Colors.grey)
            : null,
      ),
    );
  }

  Widget _buildOverallProgress(bool pre, bool book, bool game, bool post) {
    final total = 4;
    final completed = [pre, book, game, post].where((e) => e).length;
    final percent = (completed / total * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ความคืบหน้าทั้งหมด', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: completed / total,
          backgroundColor: Colors.grey[300],
          color: Color(0xFF6A11CB),
        ),
        SizedBox(height: 4),
        Text('$percent% สำเร็จ ($completed/$total)'),
      ],
    );
  }
}
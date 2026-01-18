// lib/teacher/teacher_main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'teacher_class_list.dart';
import '../role_selection.dart'; // 🔹 เพิ่ม import
import 'reading_summary.dart'; // 🔹 เพิ่ม import
import 'package:fl_chart/fl_chart.dart';
import 'presum.dart';
import 'postsum.dart';

class TeacherMainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 🔹 ปิดปุ่ม back อัตโนมัติ
        title: Text('เมนู'),
        backgroundColor: Color(0xFF6A11CB),
        foregroundColor: Colors.white,
        actions: [
          // 🔹 ปุ่มออกจากระบบ
          IconButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('ยืนยันการออกจากระบบ'),
                  content: Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('ยกเลิก'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('ยืนยัน'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6C5CE7),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => RoleSelectionScreen()),
                  (route) => false,
                );
              }
            },
            icon: Icon(Icons.logout, color: Colors.white),
            tooltip: 'ออกจากระบบ',
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMenuCard(
              context: context,
              title: 'ผลการเรียนนักเรียน',
              icon: Icons.bar_chart,
              color: Color(0xFF3498DB),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeacherClassListScreen(),
                  ),
                );
              },
            ),
            _buildMenuCard(
              context: context,
              title: 'สรุปการอ่านเนื้อหา',
              icon: Icons.book_outlined,
              color: Color(0xFF2ECC71),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReadingSummaryScreen(),
                  ),
                );
              },
            ),
            _buildMenuCard(
              context: context,
              title: 'สรุปการการสอบก่อนเรียน',
              icon: Icons.book_outlined,
              color: Color(0xFF2ECC71),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PresumScreen(),
                  ),
                );
              },
            ),
            _buildMenuCard(
              context: context,
              title: 'สรุปการสอบหลังเรียน',
              icon: Icons.book_outlined,
              color: Color(0xFF2ECC71),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostsumScreen(),
                  ),
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
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

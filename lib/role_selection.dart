// lib/role_selection.dart
import 'package:flutter/material.dart';
import 'student/login_student.dart';
import 'teacher/login_teacher.dart';

class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final purpleColor = Color(0xFF6C5CE7);
    final blueColor = Color(0xFF3498DB);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/img/role.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 60 : 24,
              vertical: 40,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Container(
                padding: EdgeInsets.all(isDesktop ? 32 : 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ยินดีต้อนรับ\nสู่ระบบวิทยาการคำนวณ',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: purpleColor, // สีม่วงตามธีมครู
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),

                    // ปุ่มสำหรับครู
                    _buildRoleCard(
                      context: context,
                      title: 'ครู',
                      subtitle: 'เข้าสู่ระบบเพื่อจัดการนักเรียนและผลการเรียน',
                      color: purpleColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LoginTeacherScreen(role: 'teacher')),
                        );
                      },
                    ),
                    SizedBox(height: 20),

                    // ปุ่มสำหรับนักเรียน
                    _buildRoleCard(
                      context: context,
                      title: 'นักเรียน',
                      subtitle: 'เข้าสู่ระบบเพื่อทำแบบทดสอบและเรียนรู้',
                      color: blueColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LoginStudentScreen(role: 'student')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isDesktop ? 24 : 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isDesktop ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
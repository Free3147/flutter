// lib/home.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'student/pre_test.dart';
import 'student/post_test.dart';
import 'student/book.dart';
import 'student/game.dart';
import 'role_selection.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final user = FirebaseAuth.instance.currentUser;

    final userStream = user != null
        ? FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots()
        : Stream<DocumentSnapshot>.empty();

    return StreamBuilder<DocumentSnapshot>(
      stream: userStream,
      builder: (context, userSnapshot) {
        String? role;
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          role = userSnapshot.data!['role'] as String?;
        }

        if (role == 'student' && user != null) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('progress').doc(user.uid).get(),
            builder: (context, progressSnapshot) {
              Map<String, dynamic> progressData = {};
              if (progressSnapshot.hasData && progressSnapshot.data!.exists) {
                progressData = progressSnapshot.data!.data() as Map<String, dynamic>;
              }

              final preTestDone = progressData['preTestCompleted'] == true;
              final postTestDone = progressData['postTestCompleted'] == true;
              final gamePlayed = progressData['gamePlayed'] == true;
              final bookViewed = progressData['bookViewed'] == true;

              return _buildHomeScreen(
                context: context,
                role: role,
                isDesktop: isDesktop,
                preTestDone: preTestDone,
                postTestDone: postTestDone,
                gamePlayed: gamePlayed,
                bookViewed: bookViewed,
              );
            },
          );
        }

        return _buildHomeScreen(
          context: context,
          role: role,
          isDesktop: isDesktop,
          preTestDone: false,
          postTestDone: false,
          gamePlayed: false,
          bookViewed: false,
        );
      },
    );
  }

  Widget _buildHomeScreen({
    required BuildContext context,
    required String? role,
    required bool isDesktop,
    required bool preTestDone,
    required bool postTestDone,
    required bool gamePlayed,
    required bool bookViewed,
  }) {
    final user = FirebaseAuth.instance.currentUser;
    final padding = isDesktop ? 40.0 : 20.0;
    final spacing = isDesktop ? 20.0 : 12.0;
    final fontSize = isDesktop ? 22.0 : 16.0;
    final iconSize = isDesktop ? 32.0 : 24.0;
    final buttonHeight = isDesktop ? 180.0 : 140.0;

    // 🔹 เงื่อนไขการปลดล็อค
    bool canAccessBook = preTestDone && !postTestDone;
    bool canAccessGame = preTestDone && !postTestDone;
    bool canAccessPostTest = preTestDone && bookViewed && gamePlayed && !postTestDone;

    // 🔹 เมื่อสอบหลังเรียนเสร็จ → เปิดเฉพาะเนื้อหา
    if (postTestDone) {
      canAccessBook = true;
      canAccessGame = false;
      canAccessPostTest = false;
    }

    List<Widget> menuItems = [
      _buildTestCard(
        context: context,
        title: 'แบบทดสอบก่อนเรียน',
        icon: Icons.quiz_outlined,
        color: Color(0xFFA357FF),
        spacing: spacing,
        height: buttonHeight,
        fontSize: fontSize,
        iconSize: iconSize,
        isCompleted: preTestDone,
        onTap: preTestDone
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PreTestScreen(role: role)),
                );
              },
      ),
      _buildMenuCard(
        context: context,
        title: 'เนื้อหา',
        icon: Icons.book_outlined,
        color: Color(0xFF3498DB),
        spacing: spacing,
        height: buttonHeight,
        fontSize: fontSize,
        iconSize: iconSize,
        onTap: canAccessBook
            ? () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => BookScreen()));
              }
            : null,
      ),
      _buildTestCard(
        context: context,
        title: 'เกม',
        icon: Icons.games_outlined,
        color: Color(0xFF2ECC71),
        spacing: spacing,
        height: buttonHeight,
        fontSize: fontSize,
        iconSize: iconSize,
        isCompleted: gamePlayed,
        onTap: canAccessGame
            ? () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen()));
              }
            : null,
      ),
      _buildTestCard(
        context: context,
        title: 'แบบทดสอบหลังเรียน',
        icon: Icons.auto_stories_outlined,
        color: Color(0xFFE67E22),
        spacing: spacing,
        height: buttonHeight,
        fontSize: fontSize,
        iconSize: iconSize,
        isCompleted: postTestDone,
        onTap: canAccessPostTest
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PostTestScreen(role: role)),
                );
              }
            : null,
      ),
    ];

    Widget menuWidget;
    if (isDesktop) {
      menuWidget = Column(
        children: [
          Row(children: [menuItems[0], SizedBox(width: spacing), menuItems[1]]),
          SizedBox(height: spacing),
          Row(children: [menuItems[2], SizedBox(width: spacing), menuItems[3]]),
        ],
      );
    } else {
      menuWidget = Column(
        children: List.generate(menuItems.length, (i) => Column(
              children: [menuItems[i], SizedBox(height: spacing)],
            )),
      );
    }

    return PopScope(
      canPop: false,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => RoleSelectionScreen()),
                    (route) => false,
                  );
                },
                icon: Icon(Icons.logout, color: Colors.white),
                tooltip: 'ออกจากระบบ',
              ),
              SizedBox(width: 16),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: isDesktop ? 20 : 10),
                  Text(
                    'ยินดีต้อนรับเข้าสู่\nรายวิชาวิทยาการคำนวณ',
                    style: TextStyle(
                      fontSize: isDesktop ? 32 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isDesktop ? 24 : 16),
                  Container(
                    width: 80,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 40 : 30),
                  menuWidget,
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required double spacing,
    required double height,
    required double fontSize,
    required double iconSize,
    required bool isCompleted,
    VoidCallback? onTap,
  }) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final cardWidth = isDesktop
        ? (MediaQuery.of(context).size.width - 80 - spacing) / 2
        : MediaQuery.of(context).size.width - 40;

    // 🔹 ตรวจสอบว่าปุ่มถูกปิดใช้งานหรือไม่
    final isDisabled = onTap == null;
    final opacity = isDisabled ? 0.5 : 1.0; // 🔹 ปรับความโปร่งใส

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: cardWidth,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95 * opacity), // 🔹 ปรับสีพื้นหลัง
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2 * opacity),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
          border: isCompleted ? Border.all(color: Colors.green, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconSize + 16,
              height: iconSize + 16,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2 * opacity), // 🔹 ปรับสีวงกลม
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: iconSize, color: color.withOpacity(opacity)), // 🔹 ปรับสีไอคอน
            ),
            SizedBox(height: 14),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 16 : 10),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87.withOpacity(opacity), // 🔹 ปรับสีข้อความ
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isCompleted)
                    Text(
                      'ทำแล้ว',
                      style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
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
    required double spacing,
    required double height,
    required double fontSize,
    required double iconSize,
    VoidCallback? onTap,
  }) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final cardWidth = isDesktop
        ? (MediaQuery.of(context).size.width - 80 - spacing) / 2
        : MediaQuery.of(context).size.width - 40;

    // 🔹 ตรวจสอบว่าปุ่มถูกปิดใช้งานหรือไม่
    final isDisabled = onTap == null;
    final opacity = isDisabled ? 0.5 : 1.0; // 🔹 ปรับความโปร่งใส

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: cardWidth,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95 * opacity), // 🔹 ปรับสีพื้นหลัง
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2 * opacity),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconSize + 16,
              height: iconSize + 16,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2 * opacity), // 🔹 ปรับสีวงกลม
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: iconSize, color: color.withOpacity(opacity)), // 🔹 ปรับสีไอคอน
            ),
            SizedBox(height: 14),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 16 : 10),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87.withOpacity(opacity), // 🔹 ปรับสีข้อความ
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
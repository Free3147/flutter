// lib/student/book.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'lesson_screen.dart';

class BookScreen extends StatefulWidget {
  @override
  _BookScreenState createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  Map<String, bool> _lessonViewed = {
    'lesson1': false,
    'lesson2': false,
    'lesson3': false,
    'lesson4': false,
  };

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('progress').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _lessonViewed['lesson1'] = data?['lesson1Viewed'] == true;
          _lessonViewed['lesson2'] = data?['lesson2Viewed'] == true;
          _lessonViewed['lesson3'] = data?['lesson3Viewed'] == true;
          _lessonViewed['lesson4'] = data?['lesson4Viewed'] == true;
        });
      }
    } catch (e) {
      print('Error loading progress: $e');
    }
  }

  Future<void> _markLessonAsViewed(String lessonKey) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 1. อัปเดตว่าดูบทนี้แล้ว
      await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .set({
        '${lessonKey}Viewed': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. ดึงข้อมูลล่าสุดจาก Firestore
      final doc = await FirebaseFirestore.instance.collection('progress').doc(user.uid).get();
      // ignore: unnecessary_cast
      final data = doc.data() as Map<String, dynamic>?;
      
      // 3. นับจำนวนบทที่ดูแล้ว
      int viewedCount = 0;
      if (data?['lesson1Viewed'] == true) viewedCount++;
      if (data?['lesson2Viewed'] == true) viewedCount++;
      if (data?['lesson3Viewed'] == true) viewedCount++;
      if (data?['lesson4Viewed'] == true) viewedCount++;

      final newProgress = viewedCount * 25;

      // 4. 🔹 แก้ไข: bookViewed = true เมื่ออ่านอย่างน้อย 1 บท
      await FirebaseFirestore.instance
          .collection('progress')
          .doc(user.uid)
          .update({
        'bookViewed': viewedCount > 0, // 🔹 เปลี่ยนจาก newProgress == 100
        'bookProgress': newProgress,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'bookRead': newProgress == 100});

      // 5. อัปเดต UI
      setState(() {
        _lessonViewed[lessonKey] = true;
      });
    } catch (e) {
      print('Error marking lesson as viewed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('บันทึกความคืบหน้าไม่สำเร็จ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final padding = isDesktop ? 40.0 : 20.0;
    final spacing = isDesktop ? 20.0 : 12.0;

    List<Widget> menuItems = [
      _buildLessonCard(
        context: context,
        title: 'บทที่ 1: การคิดเชิงคำนวณ',
        lessonKey: 'lesson1',
        onPressed: () => _navigateToLesson(context, 1, 'lesson1'),
      ),
      _buildLessonCard(
        context: context,
        title: 'บทที่ 2: อัลกอริทึม',
        lessonKey: 'lesson2',
        onPressed: () => _navigateToLesson(context, 2, 'lesson2'),
      ),
      _buildLessonCard(
        context: context,
        title: 'บทที่ 3: การเขียนโปรแกรม',
        lessonKey: 'lesson3',
        onPressed: () => _navigateToLesson(context, 3, 'lesson3'),
      ),
      _buildLessonCard(
        context: context,
        title: 'บทที่ 4: ความปลอดภัยออนไลน์',
        lessonKey: 'lesson4',
        onPressed: () => _navigateToLesson(context, 4, 'lesson4'),
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

    return Scaffold(
      appBar: AppBar(
        title: Text('วิชาวิทยาการคำนวณ'),
        backgroundColor: Color(0xFF6A11CB),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'เลือกบทเรียน',
                style: TextStyle(
                  fontSize: isDesktop ? 32 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isDesktop ? 40 : 30),
              menuWidget,
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 ฟังก์ชันเลือกภาพพื้นหลัง
  Widget _getLessonBackground(String lessonKey) {
    switch (lessonKey) {
      case 'lesson1':
        return Image.asset('lib/img/book1.png', fit: BoxFit.cover);
      case 'lesson2':
        return Image.asset('lib/img/book2.png', fit: BoxFit.cover);
      case 'lesson3':
        return Image.asset('lib/img/book3.png', fit: BoxFit.cover);
      case 'lesson4':
        return Image.asset('lib/img/book4.png', fit: BoxFit.cover);
      default:
        return Container(color: Colors.grey[300]);
    }
  }

  Widget _buildLessonCard({
    required BuildContext context,
    required String title,
    required String lessonKey,
    required VoidCallback onPressed,
  }) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final cardWidth = isDesktop
        ? (MediaQuery.of(context).size.width - 80 - 20) / 2
        : MediaQuery.of(context).size.width - 40;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: cardWidth,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 🔹 พื้นหลังภาพ
            Positioned.fill(
              child: _getLessonBackground(lessonKey),
            ),
            // 🔹 ซ้อนด้วยสีดำโปร่งใสบางๆ
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToLesson(BuildContext context, int lessonNumber, String lessonKey) {
    // 🔹 อัปเดตความคืบหน้าทันทีเมื่อกดปุ่ม
    _markLessonAsViewed(lessonKey);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonScreen(
          lessonNumber: lessonNumber,
          lessonKey: lessonKey, onMarkAsViewed: () {  },
        ),
      ),
    );
  }
}
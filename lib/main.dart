// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'student/login_student.dart';
import 'home.dart';
import 'role_selection.dart';
import 'teacher/teacher_class_list.dart';

// 🔻 เพิ่ม import เหล่านี้
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
} 

class MyApp extends StatelessWidget {
  @override   
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'วิทยาการคำนวณ',
      theme: ThemeData(primarySwatch: Colors.blue),
      /*home: LoginStudentScreen(),*/
      /*home: HomeScreen(),*/
      home: RoleSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
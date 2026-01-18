// lib/password.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ส่งลิงก์รีเซ็ตรหัสผ่านแล้ว (ตรวจสอบอีเมล)')),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = 'ส่งไม่สำเร็จ';
      if (e.code == 'user-not-found') {
        message = 'ไม่พบอีเมลนี้ในระบบ';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ลืมรหัสผ่าน')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'อีเมลที่ใช้สมัคร'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'กรุณาใส่อีเมล';
                  if (!value.contains('@')) return 'อีเมลไม่ถูกต้อง';
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendResetEmail,
                child: Text('ส่งลิงก์รีเซ็ตรหัสผ่าน'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

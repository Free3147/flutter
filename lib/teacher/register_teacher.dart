// lib/teacher/register_teacher.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_teacher.dart';

class RegisterTeacherScreen extends StatefulWidget {
  @override
  _RegisterTeacherScreenState createState() => _RegisterTeacherScreenState();
}

class _RegisterTeacherScreenState extends State<RegisterTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'role': 'teacher',
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('สมัครสมาชิกสำเร็จ!')));
      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      String message = 'สมัครไม่สำเร็จ';
      if (e.code == 'email-already-in-use') {
        message = 'อีเมลนี้มีผู้ใช้งานแล้ว';
      } else if (e.code == 'weak-password') {
        message = 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: กรุณาลองใหม่อีกครั้ง')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final purpleColor = Color(0xFF6C5CE7);
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/img/1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 40 : 20,
              vertical: isDesktop ? 60 : 40,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 500 : double.infinity,
              ),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: isDesktop ? 8 : 4,
                color: Colors.white.withOpacity(0.95), // พื้นหลังโปร่งใสเล็กน้อย
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 32 : 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'สร้างบัญชีใหม่',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: purpleColor, // ← สีม่วง
                              ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isDesktop ? 32 : 24),

                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'อีเมล',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณาใส่อีเมล';
                            }
                            if (!emailRegex.hasMatch(value)) {
                              return 'กรุณาใส่อีเมลให้ถูกต้อง';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // ช่องรหัสผ่านพร้อมปุ่มแสดง/ซ่อน
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'รหัสผ่าน',
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณาใส่รหัสผ่าน';
                            }
                            if (value.length < 6) {
                              return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24),

                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: purpleColor,
                              foregroundColor: Colors.white,
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  )
                                : Text(
                                    'สมัครสมาชิก',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Divider with "หรือ"
                        Row(
                          children: [
                            Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'หรือ',
                                style: TextStyle(color: Theme.of(context).colorScheme.outline),
                              ),
                            ),
                            Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                          ],
                        ),
                        SizedBox(height: 16),

                        // ลิงก์กลับไปล็อกอิน
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: RichText(
                              text: TextSpan(
                                text: 'มีบัญชีอยู่แล้ว? ',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                children: [
                                  TextSpan(
                                    text: 'เข้าสู่ระบบ',
                                    style: TextStyle(
                                      color: purpleColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
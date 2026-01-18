// lib/teacher/login_teacher.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'register_teacher.dart';
import '../password.dart';
import '../teacher/teacher_main.dart';

class LoginTeacherScreen extends StatefulWidget {
  final String? role;

  const LoginTeacherScreen({Key? key, this.role}) : super(key: key);

  @override
  _LoginTeacherScreenState createState() => _LoginTeacherScreenState();
}

class _LoginTeacherScreenState extends State<LoginTeacherScreen> {
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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TeacherMainScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
      if (e.code == 'user-not-found') {
        message = 'ไม่พบผู้ใช้งานนี้';
      } else if (e.code == 'wrong-password') {
        message = 'รหัสผ่านไม่ถูกต้อง';
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final purpleColor = Color(0xFF6C5CE7);

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
              vertical: isDesktop ? 40 : 24,
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
                // พื้นหลังขาวโปร่งแสงเล็กน้อยเพื่ออ่านง่ายบนภาพพื้นหลัง
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 32 : 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ยินดีต้อนรับ',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: purpleColor,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isDesktop ? 32 : 24),

                        // Email Field
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
                            if (!value.contains('@')) {
                              return 'อีเมลไม่ถูกต้อง';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // Password Field
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
                            return null;
                          },
                        ),
                        SizedBox(height: 8),

                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ForgotPasswordScreen(),
                              ),
                            ),
                            child: Text(
                              'ลืมรหัสผ่าน?',
                              style: TextStyle(color: purpleColor),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Login Button
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: purpleColor,
                              foregroundColor: Colors.white,
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  )
                                : Text(
                                    'เข้าสู่ระบบ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Divider with "หรือ"
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'หรือ',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Register Link
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RegisterTeacherScreen(),
                              ),
                            ),
                            child: RichText(
                              text: TextSpan(
                                text: 'ยังไม่มีบัญชี? ',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'สมัครสมาชิก',
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

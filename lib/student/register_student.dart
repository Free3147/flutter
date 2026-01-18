// lib/student/register_student.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_student.dart';

class RegisterStudentScreen extends StatefulWidget {
  @override
  _RegisterStudentScreenState createState() => _RegisterStudentScreenState();
}

class _RegisterStudentScreenState extends State<RegisterStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController(); // ชื่อ
  final _lastNameController = TextEditingController(); // นามสกุล
  final _usernameController = TextEditingController(); // ชื่อผู้ใช้
  final _passwordController = TextEditingController();
  String? _selectedGrade; // ชั้นเรียน
  String? _selectedClassRoom; // ห้อง (ใหม่)

  bool _isLoading = false;
  bool _obscurePassword = true;

  final List<String> grades = ['ป.1', 'ป.2', 'ป.3', 'ป.4', 'ป.5', 'ป.6'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;
    if (_selectedGrade == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('กรุณาเลือกชั้นเรียน')));
      return;
    }
    if (_selectedClassRoom == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('กรุณาเลือกหมายเลขห้อง')));
      return;
    }

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final classRoom = _selectedClassRoom!; // safe เพราะตรวจสอบแล้ว
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final email = '$username@yourdomain.edu';

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // บันทึก username (กันซ้ำ)
      await FirebaseFirestore.instance
          .collection('usernames')
          .doc(username)
          .set({
            'email': email,
            'uid': userCredential.user!.uid,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: false));

      // บันทึกข้อมูลนักเรียนทั้งหมด
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'role': 'student',
            'username': username,
            'firstName': firstName,
            'lastName': lastName,
            'fullName': '$firstName $lastName',
            'grade': _selectedGrade,
            'classRoom': classRoom,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('สมัครสมาชิกสำเร็จ!')));
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = 'สมัครไม่สำเร็จ';
      if (e.code == 'email-already-in-use') {
        message = 'ชื่อผู้ใช้นี้มีผู้ใช้งานแล้ว';
      } else if (e.code == 'weak-password') {
        message = 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } on FirebaseException catch (e) {
      if (e.code == 'already-exists') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ชื่อผู้ใช้นี้ถูกใช้ไปแล้ว โปรดลองชื่ออื่น'),
            ),
          );
        }
        try {
          await FirebaseAuth.instance.currentUser?.delete();
        } catch (_) {}
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาด: กรุณาลองใหม่อีกครั้ง')),
          );
        }
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

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'lib/img/2.jpg',
            ), //
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
                          'สร้างบัญชีนักเรียน',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: purpleColor,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isDesktop ? 18 : 24),

                        // 1. ชื่อ
                        TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: 'ชื่อ',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณาใส่ชื่อ';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // 2. นามสกุล
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'นามสกุล',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณาใส่นามสกุล';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // 3. ชั้นเรียน (Dropdown)
                        InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'ชั้นเรียน',
                            prefixIcon: Icon(Icons.school),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedGrade,
                              isDense: true,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedGrade = newValue;
                                });
                              },
                              items: grades.map((String grade) {
                                return DropdownMenuItem<String>(
                                  value: grade,
                                  child: Text(grade),
                                );
                              }).toList(),
                              hint: Text('เลือกชั้นเรียน'),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // 4. ห้อง (Dropdown 1–9)
                        InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'ห้อง',
                            prefixIcon: Icon(Icons.house),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedClassRoom,
                              isDense: true,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedClassRoom = newValue;
                                });
                              },
                              items: List.generate(7, (index) {
                                final room = '${index + 1}';
                                return DropdownMenuItem<String>(
                                  value: room,
                                  child: Text(room),
                                );
                              }),
                              hint: Text('เลือกห้อง'),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // 5. ชื่อผู้ใช้
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText:
                                'ชื่อผู้ใช้',
                            hintText: 'ใส่ชื่อเล่นและรหัสนักเรียน เช่น prae1005',
                            prefixIcon: Icon(Icons.account_circle),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณาใส่ชื่อผู้ใช้';
                            }
                            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                              return 'ชื่อผู้ใช้ต้องเป็นตัวอักษร ตัวเลข หรือ _';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // 6. รหัสผ่าน
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

                        // ปุ่มสมัคร
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  )
                                : Text(
                                    'สมัครสมาชิก',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 16),

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
                        SizedBox(height: 5),

                        // ลิงก์กลับไปล็อกอิน
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: RichText(
                              text: TextSpan(
                                text: 'มีบัญชีอยู่แล้ว? ',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
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

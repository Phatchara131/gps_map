import 'package:flutter/material.dart';
import 'package:flutter_application_5/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quickalert/quickalert.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPSD extends StatefulWidget {
  const ResetPSD({Key? key}) : super(key: key);

  @override
  State<ResetPSD> createState() => _ResetPSDState();
}

class _ResetPSDState extends State<ResetPSD> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  List<bool> _isSelected = [false, false, false];

  Future<void> resetPassword() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final otp = prefs.getString('otp');
    final email = prefs.getString('email');
    if (otp == null || email == null) {
      return;
    }
    if (passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'กรุณากรอกรหัสผ่าน',
        text: 'กรุณากรอกรหัสผ่านใหม่',
        confirmBtnColor: Colors.red.shade900,
        confirmBtnText: 'ลองอีกครั้ง',
      );
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'รหัสผ่านไม่ตรงกัน',
        text: 'กรุณากรอกรหัสผ่านใหม่อีกครั้ง',
        confirmBtnColor: Colors.red.shade900,
        confirmBtnText: 'ลองอีกครั้ง',
      );
      return;
    }
    if (_isSelected.contains(false)) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'รหัสผ่านไม่ถูกต้อง',
        text: 'กรุณาตรวจสอบรหัสผ่านอีกครั้ง',
        confirmBtnColor: Colors.red.shade900,
        confirmBtnText: 'ลองอีกครั้ง',
      );
      return;
    }
    try {
      String url =
          'https://project-old.000webhostapp.com/User_API/user_rest.php';
      var response = await http.post(Uri.parse(url), body: {
        'email': email,
        'password': passwordController.text,
        'action': 'resetPassword',
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'success') {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'เปลี่ยนรหัสผ่านสำเร็จ',
            text: 'เปลี่ยนรหัสผ่านสำเร็จ กรุณาเข้าสู่ระบบใหม่อีกครั้ง',
            showConfirmBtn: false,
            widget: Container(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(height: 10),
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'กำลังพาคุณไปยังหน้าเข้าสู่ระบบใหม่',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
          Future.delayed(Duration(seconds: 5), () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return LoginPage();
            }));
          });
        } else {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'เปลี่ยนรหัสผ่านไม่สำเร็จ',
            text: 'กรุณาลองใหม่อีกครั้ง',
            confirmBtnColor: Colors.red.shade900,
            confirmBtnText: 'ลองอีกครั้ง',
          );
        }
      }
    } catch (e) {
      print(e);
    }
  }

  // ตรวจสอบรหัสผ่าน
  void checkPassword(String password) {
    // ตรวจสอบว่ามีความยาวอย่างน้อย 6 ตัว
    if (password.length < 6) {
      setState(() {
        _isSelected[0] = false;
      });
    } else {
      setState(() {
        _isSelected[0] = true;
      });
    }

    // ตรวจสอบว่ามีตัวเลขอย่างน้อย 1 ตัว
    if (!password.contains(RegExp(r'[0-9]'))) {
      setState(() {
        _isSelected[1] = false;
      });
    } else {
      setState(() {
        _isSelected[1] = true;
      });
    }

    // ตรวจสอบว่ามีตัวอักษรพิเศษอย่างน้อย 1 ตัว
    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>\_-]'))) {
      setState(() {
        _isSelected[2] = false;
      });
    } else {
      setState(() {
        _isSelected[2] = true;
      });
    }

    print(_isSelected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เปลี่ยนรหัสผ่าน'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://i.imgur.com/w4CxvHQ.png',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
              // SizedBox(height: 10),
              Text(
                'กรุณากรอกรหัสผ่านใหม่',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  checkPassword(value);
                },
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: 'รหัสผ่านใหม่',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.greenAccent),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: 'ยืนยันรหัสผ่านใหม่',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.greenAccent),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: resetPassword,
                child: Text(
                  'ยืนยัน',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 10),
              //validate password
              Container(
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          _isSelected[0]
                              ? Icons.check_circle_sharp
                              : Icons.check_circle_outline,
                          color: Colors.greenAccent,
                          size: 20,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'รหัสผ่านต้องมีความยาว 6 ตัวอักษรขึ้นไป',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    // ตรวจสอบว่ามีตัวเลขอย่างน้อย 1 ตัว
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          _isSelected[1]
                              ? Icons.check_circle_sharp
                              : Icons.check_circle_outline,
                          color: Colors.greenAccent,
                          size: 20,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'ต้องมีตัวเลขอย่างน้อย 1 ตัว',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    // ตรวจสอบว่ามีตัวอักษรพิเศษอย่างน้อย 1 ตัว
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          _isSelected[2]
                              ? Icons.check_circle_sharp
                              : Icons.check_circle_outline,
                          color: Colors.greenAccent,
                          size: 20,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'ต้องมีตัวอักษรพิเศษอย่างน้อย 1 ตัว',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ]
                      .expand((element) => [element, SizedBox(height: 10)])
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

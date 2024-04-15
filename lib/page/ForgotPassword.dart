import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_5/page/SelectOTP.dart';
import 'package:quickalert/quickalert.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  String generateOTP() {
    // สร้างรหัส OTP 6 หลัก
    const digits = '0123456789';
    final random = Random();
    final otp =
        List.generate(6, (index) => digits[random.nextInt(digits.length)]);
    return otp.join();
  }

  Future<bool> checkEmail() async {
    final email = emailController.text;
    try {
      showLoading('กำลังตรวจสอบอีเมล...');
      String url =
          'https://project-old.000webhostapp.com/User_API/user_rest.php?checkEmail=$email';
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print(jsonData);
        if (jsonData['status'] == 'success') {
          Navigator.of(context).pop();
          return true;
        } else {
          Navigator.of(context).pop();
          return false;
        }
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<void> sendOTP() async {
    final email = emailController.text;
    if (email.isEmpty) {
      QuickAlert.show(
        context: context,
        title: 'กรุณากรอกอีเมล',
        text: 'กรุณากรอกอีเมลของคุณ',
        type: QuickAlertType.error,
      );
      return;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      QuickAlert.show(
        context: context,
        title: 'อีเมลไม่ถูกต้อง',
        text: 'กรุณากรอกอีเมลให้ถูกต้อง',
        type: QuickAlertType.error,
      );
      return;
    }

    final isEmailExist = await checkEmail();
    if (!isEmailExist) {
      QuickAlert.show(
        context: context,
        title: 'อีเมลไม่ถูกต้อง',
        text: 'ไม่พบอีเมลนี้ในระบบ',
        type: QuickAlertType.error,
      );
      return;
    }

    final otp = generateOTP();
    try {
      showLoading('กำลังส่งรหัส OTP...');
      final response = await http.post(
        Uri.parse('https://crud-web-g7hi.onrender.com/api/sendEmail'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': email,
          'otp': otp,
          'subject': 'รหัส OTP สำหรับการลืมรหัสผ่าน'
        }),
      );
      if (response.statusCode == 200) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('otp', otp);
        prefs.setString('email', email);
        Navigator.of(context).pop();
        //print response.body
        print(response.body);
        QuickAlert.show(
          barrierDismissible: false,
          context: context,
          title: 'ส่งรหัส OTP สำเร็จ',
          text: 'รหัส OTP ถูกส่งไปยังอีเมลของคุณแล้ว',
          type: QuickAlertType.success,
          showConfirmBtn: false,
          widget: Container(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: 10),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                ),
                SizedBox(height: 10),
                Text('กำลังพาคุณไปยังหน้าเปลี่ยนรหัสผ่าน'),
              ],
            ),
          ),
          // onConfirmBtnTap: () {},
        );
        Future.delayed(Duration(seconds: 5), () {
          Navigator.of(context).pop();
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SelectOTP();
          }));
        });
      } else {
        Navigator.of(context).pop();
        QuickAlert.show(
          context: context,
          title: 'ส่งรหัส OTP ไม่สำเร็จ',
          text: 'กรุณาลองใหม่อีกครั้ง',
          type: QuickAlertType.error,
        );
      }
    } catch (e) {
      print(e);
    }
  }

  void showLoading(String msg) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                  strokeWidth: 10,
                  backgroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                msg,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ลืมรหัสผ่าน'),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent, // สีพื้นหลังของ AppBar
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://i.imgur.com/fxv47XI.png', // เปลี่ยนเป็นที่อยู่ของรูปภาพของคุณ
              height: 200,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            Text(
              'กรุณากรอกอีเมลของคุณ\nเพื่อรับรหัส OTP',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54, // สีของข้อความรายละเอียด
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'อีเมล',
                hintText: 'example@example.com',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendOTP,
              child: Text(
                'ส่งรหัส OTP',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreenAccent, // สีพื้นหลังของปุ่ม
                foregroundColor: Colors.black, // สีของตัวอักษรบนปุ่ม
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

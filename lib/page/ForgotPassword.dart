import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  String generateOTP() {
    // สร้างรหัส OTP 6 หลัก
    const digits = '0123456789';
    final random = Random();
    final otp =
        List.generate(6, (index) => digits[random.nextInt(digits.length)]);
    return otp.join();
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

    final otp = generateOTP();
    try {
      final response = await http.post(
        Uri.parse('https://crud-web-five.vercel.app/api/sendEmail'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': email,
          'otp': otp,
          'subject': 'รหัส OTP สำหรับการลืมรหัสผ่าน'
        }),
      );
      QuickAlert.show(
        context: context,
        title: 'ส่งรหัส OTP',
        text: 'กำลังส่งรหัส OTP ไปยังอีเมลของคุณ',
        type: QuickAlertType.loading,
      );
      if (response.statusCode == 200) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('otp', otp);
        Navigator.of(context).pop();
        //print response.body
        print(response.body);
        QuickAlert.show(
          context: context,
          title: 'ส่งรหัส OTP สำเร็จ',
          text: 'รหัส OTP ถูกส่งไปยังอีเมลของคุณแล้ว',
          type: QuickAlertType.success,
          // onConfirmBtnTap: () {},
        );
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });
      } else {
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

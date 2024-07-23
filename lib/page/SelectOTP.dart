import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_5/page/ResetPassword.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quickalert/quickalert.dart';
import 'package:http/http.dart' as http;

class SelectOTP extends StatefulWidget {
  const SelectOTP({super.key});

  @override
  State<SelectOTP> createState() => _SelectOTPState();
}

class _SelectOTPState extends State<SelectOTP> {
  var _currentOTP = [0, 0, 0, 0, 0, 0];
  List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  String showTime = "00:30";
  int countTime = 30;

  Future<void> CheckOTP() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final otp = prefs.getString('otp');
    if (otp == null) {
      return;
    }
    print(otp);
    final currentOTP = _currentOTP.join();
    if (otp == currentOTP) {
      // Navigator.pushNamed(context, '/reset-password');
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'รหัส OTP ถูกต้อง',
        text: 'รหัส OTP ถูกต้อง กรุณากดยืนยันเพื่อตั้งรหัสผ่านใหม่',
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
      );
      Future.delayed(Duration(seconds: 5), () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return ResetPSD();
        }));
      });
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'รหัส OTP ไม่ถูกต้อง',
        text: 'กรุณาลองใหม่อีกครั้ง',
        confirmBtnColor: Colors.red.shade900,
        confirmBtnText: 'ลองอีกครั้ง',
      );
    }
  }

  void showCountTime() {
    //30 second
    countTime = 30;
    //Timer
    var timer = new Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        countTime--;
        showTime = "00:" + countTime.toString().padLeft(2, '0');
        if (countTime == 0) {
          timer.cancel();
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    showCountTime();
  }

  void showLoading(String msg) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
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

  String generateOTP() {
    // สร้างรหัส OTP 6 หลัก
    const digits = '0123456789';
    final random = Random();
    final otp =
        List.generate(6, (index) => digits[random.nextInt(digits.length)]);
    return otp.join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เลือกรหัส OTP'),
        backgroundColor: Colors.greenAccent,
      ),
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://i.imgur.com/W7CEXIE.png',
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 5),
            Text(
              'เลือกรหัส OTP ที่คุณได้รับ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'เลื่อนเลขให้ตรงกับรหัส OTP ที่คุณได้รับ',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(10.0),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(
                  6,
                  (int index) {
                    return Container(
                      alignment: Alignment.center,
                      width: 50,
                      height: 50,
                      child: TextField(
                        //ปิด cursor
                        showCursor: false,
                        //ปิดตัวชี้
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          if (value.isEmpty) {
                            // ตรวจสอบว่าถ้าค่าที่ใส่เข้ามาเป็นค่าว่าง
                            if (index > 0) {
                              // ตรวจสอบว่า index มากกว่า 0 (ไม่ได้อยู่ที่ช่องแรก)
                              _focusNodes[index - 1]
                                  .requestFocus(); // ให้โฟกัสไปยังช่องก่อนหน้า
                            }
                          } else if (value.length == 1) {
                            // ตรวจสอบว่าถ้าค่าที่ใส่มีความยาวเป็น 1
                            _currentOTP[index] = int.parse(value);
                            if (index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            }
                          } else if (value.isNotEmpty && index == 0) {
                            // เพิ่มเงื่อนไขว่าถ้าค่าไม่ใช่ค่าว่าง และอยู่ที่ช่องแรก
                            _focusNodes[index]
                                .unfocus(); // ให้เลิกโฟกัสที่ช่องปัจจุบัน
                          } else if (value.isEmpty && index == 0) {
                            // เพิ่มเงื่อนไขเมื่อค่าว่างและอยู่ที่ช่องแรก
                            _focusNodes[index]
                                .unfocus(); // ให้เลิกโฟกัสที่ช่องปัจจุบัน
                          }
                        },

                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          counterText: '',
                          counterStyle: TextStyle(fontSize: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.greenAccent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ).expand((widget) => [widget, SizedBox(width: 10)]).toList(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                CheckOTP();
              },
              child: Text('ยืนยันรหัส OTP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide(color: Colors.greenAccent, width: 2),
                foregroundColor: Colors.greenAccent,
                shadowColor: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "ส่งรหัส OTP อีกครั้ง ในอีก $showTime วินาที",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: countTime == 0
                  ? () async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      // String otp = prefs.getString('otp') ?? '';
                      String email = prefs.getString('email') ?? '';
                      final otp = generateOTP();
                      try {
                        showLoading('กำลังส่งรหัส OTP...');
                        final response = await http.post(
                          Uri.parse(
                              'https://crud-web-g7hi.onrender.com/api/sendEmail'),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode({
                            'message': email,
                            'otp': otp,
                            'subject': 'รหัส OTP สำหรับการลืมรหัสผ่าน'
                          }),
                        );
                        if (response.statusCode == 200) {
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setString('otp', otp);
                          prefs.setString('email', email);
                          Navigator.of(context).pop();
                          //print response.body
                          print(response.body);
                          setState(() {
                            showCountTime();
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
                  : null,
              child: Text('ส่งรหัส OTP อีกครั้ง'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide(color: Colors.orangeAccent, width: 2),
                foregroundColor: Colors.white,
                shadowColor: Colors.orangeAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

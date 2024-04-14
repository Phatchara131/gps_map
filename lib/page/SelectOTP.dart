import 'package:flutter/material.dart';
import 'package:flutter_application_5/page/ResetPassword.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quickalert/quickalert.dart';

class SelectOTP extends StatefulWidget {
  const SelectOTP({super.key});

  @override
  State<SelectOTP> createState() => _SelectOTPState();
}

class _SelectOTPState extends State<SelectOTP> {
  var _currentOTP = [0, 0, 0, 0, 0, 0];

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
                    return SizedBox(
                      width: 50,
                      height: 50,
                      child: NumberPicker(
                        value: _currentOTP[index],
                        minValue: 0,
                        maxValue: 9,
                        infiniteLoop: true,
                        itemHeight: 50,
                        itemCount: 2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.greenAccent,
                            width: 2,
                          ),
                        ),
                        //disable number picker
                        onChanged: (value) {
                          setState(() {
                            _currentOTP[index] = value;
                          });
                        },
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
          ],
        ),
      ),
    );
  }
}

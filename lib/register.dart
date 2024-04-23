import 'package:flutter/material.dart';
import 'package:flutter_application_5/login.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  List userdata = [];
  bool _obscurePassword = true;

  final TextEditingController user_name = TextEditingController();
  final TextEditingController user_idcard = TextEditingController();
  final TextEditingController user_email = TextEditingController();
  final TextEditingController user_password = TextEditingController();
  final TextEditingController confirm_password = TextEditingController();

  bool validateThaiID(String id) {
    if (id.length != 13) {
      return false;
    }

    if (!RegExp(r'^[0-9]*$').hasMatch(id)) {
      return false;
    }

    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += int.parse(id[i]) * (13 - i);
    }
    if ((11 - (sum % 11)) % 10 != int.parse(id[12])) {
      return false;
    }

    return true;
  }

  Future<void> getrecord() async {
    try {
      // String uri = "http://192.168.1.32/User_API/user_login.php";
      String uri =
          "https://project-old.000webhostapp.com/User_API/user_login.php";
      // String uri = "http://10.0.2.2/PRO_API/view_data.php";
      var response = await http.get(Uri.parse(uri));
      setState(() {
        userdata = jsonDecode(response.body);
        // print("$userdata\n");
      });
    } catch (e) {
      print(e);
    }
  }

  Future<bool> checkEmail() async {
    final email = user_email.text;
    try {
      showLoading('กำลังตรวจสอบข้อมูล...');
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

  Future<void> register(BuildContext context) async {
    if (user_name.text.isNotEmpty &&
        user_idcard.text.isNotEmpty &&
        user_email.text.isNotEmpty &&
        user_password.text.isNotEmpty) {
      if (user_password.text == confirm_password.text) {
        if (user_password.text.length >= 6) {
          if (await checkEmail()) {
            QuickAlert.show(
              context: context,
              title: 'ตรวจสอบอีเมล',
              text: 'มีอีเมลนี้ในระบบแล้ว',
              type: QuickAlertType.error,
            );
            return;
          }
          if (!validateThaiID(user_idcard.text)) {
            QuickAlert.show(
              context: context,
              title: 'ตรวจสอบบัตรประชาชน',
              text: 'กรุณาใส่บัตรประชาชนให้ถูกต้อง',
              type: QuickAlertType.error,
              confirmBtnText: "ยืนยัน",
            );
            return;
          }

          try {
            String uri =
                "https://project-old.000webhostapp.com/User_API/user_insert.php";
            var res = await http.post(Uri.parse(uri), body: {
              "name": user_name.text,
              "idcard": user_idcard.text,
              "email": user_email.text,
              "password": user_password.text,
            });

            var response = jsonDecode(res.body);
            if (response["success"] == "true") {
              print("Insert success");
            } else {
              print("Some issue");
            }
          } catch (e) {
            print(e);
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else {
          QuickAlert.show(
            context: context,
            title: 'ตรวจสอบรหัสผ่าน',
            text: 'กรุณาใส่รหัสอย่างน้อย 6 ตัว',
            type: QuickAlertType.error,
            confirmBtnText: "ยืนยัน",
          );
        }
      } else {
        QuickAlert.show(
          context: context,
          title: 'ตรวจสอบรหัสผ่าน',
          text: 'กรุณาใส่รหัสผ่านให้ตรงกัน',
          type: QuickAlertType.error,
          confirmBtnText: "ยืนยัน",
        );
      }
    } else {
      QuickAlert.show(
        context: context,
        title: 'ตรวจสอบข้อมูล',
        text: 'กรุณากรอกข้อมูลให้ครบ',
        type: QuickAlertType.error,
        confirmBtnText: "ยืนยัน",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://modernformhealthcare.co.th/wp-content/uploads/2024/02/happy-asian-senior-couple-smiling-outside.webp',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.only(
                  top: 10.0,
                  left: 10.0,
                  right: 10.0,
                  bottom: 10.0,
                ),
                margin: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_add,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        Text(
                          'สมัครสมาชิก',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ]
                          .expand((element) => [element, SizedBox(width: 5.0)])
                          .toList(),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      cursorColor: Colors.white,
                      controller: user_name,
                      decoration: InputDecoration(
                        labelText: 'ชื่อ-สกุล',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.transparent,
                        labelStyle: TextStyle(color: Colors.white),
                        prefixIconColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      cursorColor: Colors.white,
                      controller: user_idcard,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'เลขบัตรประชาชน',
                        prefixIcon: Icon(Icons.add_card_rounded),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.transparent,
                        labelStyle: TextStyle(color: Colors.white),
                        prefixIconColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      cursorColor: Colors.white,
                      controller: user_email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.transparent,
                        labelStyle: TextStyle(color: Colors.white),
                        prefixIconColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      cursorColor: Colors.white,
                      controller: user_password,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.transparent,
                        labelStyle: TextStyle(color: Colors.white),
                        prefixIconColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      obscureText: _obscurePassword,
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      cursorColor: Colors.white,
                      controller: confirm_password,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.transparent,
                        labelStyle: TextStyle(color: Colors.white),
                        prefixIconColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      obscureText: _obscurePassword,
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              register(context);
                            },
                            child: Text(
                              'ยืนยัน',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 0, 255, 157),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'ยกเลิก',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

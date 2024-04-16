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

  Future<void> register(BuildContext context) async {
    if (user_name.text.isNotEmpty &&
        user_idcard.text.isNotEmpty &&
        user_email.text.isNotEmpty &&
        user_password.text.isNotEmpty) {
      if (user_password.text == confirm_password.text) {
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
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("แจ้งเตือน"),
                content: Text("เลขบัตรประชาชนไม่ถูกต้อง"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
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
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("แจ้งเตือน"),
              content: Text("กรุณาใส่รหัสให้ตรงกัน"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("แจ้งเตือน"),
            content: Text("กรุณากรอกข้อมูลให้ครบทุกช่อง"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://modernformhealthcare.co.th/wp-content/uploads/2024/02/happy-asian-senior-couple-smiling-outside.webp',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: user_name,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: user_idcard,
                      decoration: InputDecoration(
                        labelText: 'UserID',
                        prefixIcon: Icon(Icons.add_card_rounded),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: user_email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: user_password,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      obscureText: _obscurePassword,
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: confirm_password,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      obscureText: _obscurePassword,
                    ),
                    SizedBox(height: 32.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            register(context);
                          },
                          child: Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 0, 255, 157),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 248, 86, 75),
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

import 'package:flutter/material.dart';
import 'package:flutter_application_5/login.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;

  final TextEditingController user_name = TextEditingController();
  final TextEditingController user_email = TextEditingController();
  final TextEditingController user_password = TextEditingController();
  final TextEditingController confirm_password = TextEditingController();

  Future<void> register(BuildContext context) async {
    if (user_name.text.isNotEmpty &&
        user_email.text.isNotEmpty &&
        user_password.text.isNotEmpty) {
      if (user_password.text == confirm_password.text) {
        try {
          String uri = "http://10.0.2.2/User_API/user_insert.php";
          var res = await http.post(Uri.parse(uri), body: {
            "name": user_name.text,
            "email": user_email.text,
            "password": user_password.text,
          });

          var response = jsonDecode(res.body);
          if (response["success"] == "true") {
            print("Record Inserted");
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
        // Password and Confirm Password do not match, show alert dialog
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
      // Notify user about empty fields
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
      debugShowCheckedModeBanner:
          false, // เพิ่ม debugShowCheckedModeBanner ที่นี่
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 229, 255, 213),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://f.ptcdn.info/691/055/000/p2n6hzgmmNMzcUSHrM7-o.gif',
                    height: 150,
                  ),
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
    );
  }
}

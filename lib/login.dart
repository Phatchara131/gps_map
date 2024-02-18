import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_5/main.dart';
import 'package:flutter_application_5/register.dart';
import 'package:flutter_application_5/view_old.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  List userdata = [];
  bool loginError = false;
  bool _obscurePassword = true;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> getrecord() async {
    try {
      String uri = "http://192.168.1.32/User_API/user_login.php";
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

  void loginUser() async {
    String enteredUsername = usernameController.text;
    String enteredPassword = passwordController.text;
    getrecord(); // เรียกใช้ getrecord เพื่อดึงข้อมูลล่าสุด
    print(userdata);
    for (var index in userdata) {
      if (index['user_name'] == enteredUsername &&
          index['user_password'] == enteredPassword) {
        // เข้าสู่ระบบสำเร็จ!
        print("เข้าสู่ระบบสำเร็จ!");
        setState(() {
          loginError = false;
        });
        // เพื่อความง่าย, ขอให้เราเข้าสู่หน้าจอ Register ไว้ก่อน
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const View_old()),
        );
        return;
      } else {
        print("เข้าสู่ระบบล้มเหลว!");
        setState(() {
          loginError = true;
        });
      }
    }

    // print(enteredPassword);
    // print(enteredUsername);
  }

  @override
  void initState() {
    getrecord();
    super.initState();
    print(userdata);
    // เรียก getrecord เมื่อหน้าจอเริ่มแสดงผล
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 229, 255, 213),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://f.ptcdn.info/691/055/000/p2n6hzgmmNMzcUSHrM7-o.gif',
                height: 200,
              ),
              const SizedBox(height: 32.0),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
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
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                obscureText: _obscurePassword,
              ),

              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  // เรียกใช้ loginUser เมื่อปุ่มเข้าสู่ระบบถูกกด
                  loginUser();
                },
                child: Text(
                  'เข้าสู่ระบบ',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 0, 255, 157),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 16.0),
              loginError
                  ? Text(
                      'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    )
                  : Container(), // ซ่อนข้อความผิดพลาดในที่สุด
              SizedBox(height: 16.0),
              GestureDetector(
                onTap: () {
                  // Navigate to the Register screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text(
                  'ยังไม่มีบัญชีใช่หรือไม่? ลงทะเบียนที่นี่',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_5/main.dart';
import 'package:flutter_application_5/people/view_people.dart';
import 'package:flutter_application_5/register.dart';
import 'package:flutter_application_5/view_main.dart';
import 'package:flutter_application_5/view_mapnoti.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

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

  final TextEditingController useremailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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

  void loginUser() async {
    String enteredUseremail = useremailController.text;
    String enteredPassword = passwordController.text;
    getrecord(); // เรียกใช้ getrecord เพื่อดึงข้อมูลล่าสุด
    print(userdata);
    for (var index in userdata) {
      if (index['user_email'] == enteredUseremail &&
          index['user_password'] == enteredPassword) {
        // เข้าสู่ระบบสำเร็จ!
        print("เข้าสู่ระบบสำเร็จ!");
        setState(() {
          loginError = false;
        });
        // เพื่อความง่าย, ขอให้เราเข้าสู่หน้าจอ Register ไว้ก่อน
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ViewOld()),
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
    // print(enteredUseremail);
  }

  Future<void> initPlatformState() async {
    // Initialize OneSignal
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.Debug.setAlertLevel(OSLogLevel.none);
    OneSignal.consentRequired(false);
    OneSignal.initialize("a3781753-2e28-49b9-b782-90781230523c");
    OneSignal.Notifications.requestPermission(true);
    print("Permission accepted");
    OneSignal.User.pushSubscription.addObserver((state) {
      print("ID : ${state.jsonRepresentation()}"); // print the user id
    });
    OneSignal.User.addTagWithKey("test2", "val2");
    OneSignal.Notifications.addClickListener((event) async {
      print('NOTIFICATION CLICK LISTENER CALLED WITH EVENT: $event');
      print(event.notification.jsonRepresentation());
      print(event.notification.additionalData?['lon']);
      double lat = double.parse(event.notification.additionalData?['lat']);
      double lon = double.parse(event.notification.additionalData?['lon']);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Mapnoti(lat: lat, lon: lon)),
      );
    });
  }

  @override
  void initState() {
    getrecord();
    super.initState();
    print(userdata);
    initPlatformState();
    // เรียก getrecord เมื่อหน้าจอเริ่มแสดงผล
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color.fromARGB(255, 229, 255, 213),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5), // สีดำโปงใส
                    borderRadius: BorderRadius.circular(
                        15.0), // กำหนดให้มุมเป็นรูปร่างที่โค้ง
                  ), // สีดำโปงใส
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32.0),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          cursorColor: Colors.white,
                          controller: useremailController,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            labelText: 'E-mail',
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.white,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                          right: 8.0,
                        ),
                        child: TextField(
                          cursorColor: Colors.white,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.white,
                            ),
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
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                          obscureText: _obscurePassword,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => Forgot(),
                            //   ),
                            // );
                          },
                          child: Text(
                            'ลืมรหัสผ่าน?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.only(
                              right: 8.0,
                            ),
                            minimumSize: Size(0, 5),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                          right: 8.0,
                        ),
                        child: ElevatedButton(
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
                            shadowColor: Colors.transparent,
                            backgroundColor: Colors.transparent,
                            side: BorderSide(
                              color: Color.fromARGB(255, 0, 255, 157),
                            ),
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            foregroundColor: Color.fromARGB(255, 0, 255, 157),
                          ),
                        ),
                      ),
                      loginError ? SizedBox(height: 16.0) : Container(),
                      loginError
                          ? Text(
                              'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            )
                          : Container(), // ซ่อนข้อความผิดพลาดในที่สุด

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ยังไม่มีบัญชีผู้ใช้?',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterPage()),
                              );
                            },
                            child: Text(
                              'ลงทะเบียนที่นี่',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 255, 157),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewOld_people()),
                          );
                        },
                        child: Text(
                          'ดูข้อมูลผู้สูงอายุ',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 255, 157),
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
    );
  }
}

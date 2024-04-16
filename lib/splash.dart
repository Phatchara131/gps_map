import 'package:flutter/material.dart';
import 'package:flutter_application_5/login.dart';
import 'package:flutter_application_5/relative/view_relative.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      Future.delayed(Duration(seconds: 5), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ViewOld(),
          ),
        );
      });
    } else {
      Future.delayed(Duration(seconds: 5), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            opacity: 0.5,
            image: AssetImage(
              'assets/images/bg.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/rias_gremory_render_23_by_knd_art_de6ea1u-414w-2x.png',
              width: 200,
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade900),
                strokeWidth: 10,
                backgroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'กำลังโหลด...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

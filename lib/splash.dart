import 'package:flutter/material.dart';
import 'package:flutter_application_5/login.dart';
import 'package:flutter_application_5/relative/view_relative.dart';
import 'package:flutter_application_5/view_mapnoti.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
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
    initPlatformState();
    checkLogin();
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
    OneSignal.User.addTagWithKey("test3", "val3");
    //show With custom Key in SnackBar

    var Tage = await OneSignal.User.getTags();

    print("ID : ${Tage}");

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("ID : ${Tage}"),
    ));

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

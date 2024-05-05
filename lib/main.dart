import 'package:flutter_application_5/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_5/relative/view_relative.dart';
import 'package:flutter_application_5/view_main.dart';
import 'package:flutter_application_5/view_mapnoti.dart';
// import 'package:flutter_application_5/relative/view_relative.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:socket_io_client/socket_io_client.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:socket_io_client/socket_io_client.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(
      widgetsBinding: WidgetsFlutterBinding.ensureInitialized());
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  // Initialize OneSignal
  String user_idcard = prefs.getString('user_idcard') ?? '';
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.Debug.setAlertLevel(OSLogLevel.none);
  OneSignal.consentRequired(false);
  OneSignal.initialize("a3781753-2e28-49b9-b782-90781230523c");
  OneSignal.Notifications.requestPermission(true);
  print("Permission accepted");

  OneSignal.User.pushSubscription.addObserver((state) {
    print("ID : ${state.jsonRepresentation()}"); // print the user id
  });
  // OneSignal.User.addTagWithKey("test2", "val2");
  // OneSignal.User.addTagWithKey("test3", "val3");
  //show With custom Key in SnackBar

  var Tage = await OneSignal.User.getTags();

  print("ID : ${Tage}");

  // ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(
  //   content: Text("ID : ${Tage}"),
  // ));

  OneSignal.Notifications.addClickListener((event) async {
    print('Clecked main.dart');
    print('NOTIFICATION CLICK LISTENER CALLED WITH EVENT: $event');
    print(event.notification.jsonRepresentation());
    print(event.notification.additionalData?['lon']);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lat', event.notification.additionalData?['lat']);
    prefs.setString('lon', event.notification.additionalData?['lon']);

    double lat = double.parse(event.notification.additionalData?['lat']);
    double lon = double.parse(event.notification.additionalData?['lon']);
    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => Mapnoti(lat: lat, lon: lon)),
    );
  });
  String titleDrawer = prefs.getString('user_name') ?? '';
  String emailDrawer = prefs.getString('user_email') ?? '';
  // await Future.delayed(Duration(seconds: 2));
  FlutterNativeSplash.remove();
  isLoggedIn ? print("Logged In") : print("Not Logged In");
  runApp(MaterialApp(
    title: "App",
    home: isLoggedIn
        ? user_idcard == 'admin'
            ? ViewOld()
            : ViewOldRela(titleDrawer: titleDrawer, emailDrawer: emailDrawer)
        : LoginPage(),
    navigatorKey: navigatorKey,
    // home: ViewOld(),
  ));
}

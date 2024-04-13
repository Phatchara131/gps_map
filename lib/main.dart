import 'package:flutter_application_5/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_5/view_mapnoti.dart';
// import 'package:flutter_application_5/relative/view_relative.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:socket_io_client/socket_io_client.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:socket_io_client/socket_io_client.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: "App",
    home: LoginPage(),
    navigatorKey: navigatorKey,
    // home: ViewOld(),
  ));
}

//init socket io

// void initSocket() {
//   print('init socket');
//   IO.Socket socket = IO.io('https://socket-location.onrender.com/',
//       OptionBuilder().setTransports(['websocket']).build());
//   socket.onConnect((_) {
//     print('connect to server');
//     socket.on('message', (data) {
//       print(data);
//       _showLocalNotification(data);
//     });
//   });
//   //ถ้าเชื่อมต่อกับ Server ไม่ได้
//   socket.onConnectError((data) {
//     print("Connect Error: $data");
//   });
// }

// void _showLocalNotification(String message) async {
//   const String channelId = "HEE";
//   const String channelName = "HEEYAI";
//   final Person person = const Person(name: 'Heeyai', key: '1');
//   final AndroidNotificationDetails androidNotificationDetails =
//       AndroidNotificationDetails(
//     channelId,
//     channelName,
//     channelDescription: 'KUY',
//     importance: Importance.max,
//     priority: Priority.high,
//     ticker: 'ticker',
//     icon: '@mipmap/ic_launcher',
//     styleInformation: MessagingStyleInformation(
//       person,
//       conversationTitle: 'แจ้งเตือนจาก HEE',
//       groupConversation: true,
//       messages: [
//         Message(
//           message,
//           DateTime.now(),
//           person,
//         )
//       ],
//     ),
//   );

//   final NotificationDetails notificationDetails =
//       NotificationDetails(android: androidNotificationDetails);

//   flutterLocalNotificationsPlugin.show(
//     0,
//     'HEEXD',
//     'HEEYAIMAK',
//     notificationDetails,
//     payload: 'XDXD',
//   );
// }

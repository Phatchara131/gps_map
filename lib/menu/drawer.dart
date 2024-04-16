import 'package:flutter/material.dart';
import 'package:flutter_application_5/insert_old.dart';
import 'package:flutter_application_5/login.dart';
import 'package:flutter_application_5/view_map.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                opacity: 0.5,
                image: AssetImage('assets/images/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapTab(),
                ),
              );
            },
            child: Row(
              children: [
                Icon(Icons.map),
                SizedBox(width: 15),
                Text(
                  'แผนที่',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Insert_old(),
                ),
              );
            },
            child: Row(
              children: [
                Icon(Icons.perm_identity_sharp),
                SizedBox(width: 15),
                Text(
                  'บันทึกข้อมูล',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              prefs.setBool('isLoggedIn', false);
              prefs.remove('user_email');
              Map<String, dynamic> TagsOne = await OneSignal.User.getTags();
              print("ID : ${TagsOne}");
              TagsOne.forEach((key, value) {
                print("Key : $key, Value : $value");
                OneSignal.User.removeTag(key);
              });
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Row(
              children: [
                Icon(Icons.logout),
                SizedBox(width: 15),
                Text(
                  'ออกจากระบบ',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Add more buttons as needed
        ],
      ),
    );
  }
}

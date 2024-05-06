import 'package:flutter/material.dart';
import 'package:flutter_application_5/insert_old.dart';
import 'package:flutter_application_5/insert_oldNew.dart';
import 'package:flutter_application_5/login.dart';
import 'package:flutter_application_5/page/UserListPage.dart';
import 'package:flutter_application_5/view_map.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    Key? key,
    required this.title,
    required this.email,
  }) : super(key: key);
  final String email;
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
                image: NetworkImage(
                    'https://source.unsplash.com/random/900×700/?family'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://source.unsplash.com/random/100×100/?graphic'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      alignment: Alignment.center,
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: Text(
                        email == 'admin' ? 'A' : title[0].toUpperCase(),
                        // "A",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  title,
                  // "สวัสดี $title",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            splashColor: Colors.grey,
            title: Text('แผนที่'),
            leading: Icon(Icons.map),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapTab(),
                ),
              );
            },
          ),
          email == 'admin'
              ? ListTile(
                  title: Text('จัดการผู้ใช้'),
                  leading: Icon(Icons.person),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserListPage(user_idz: 0),
                      ),
                    );
                  },
                )
              : SizedBox(),
          ListTile(
            title: Text('บันทึกข้อมูลผู้สูงอายุ'),
            leading: Icon(Icons.person_3_outlined),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // builder: (context) => Insert_old(),
                  builder: (context) => Insert_oldNew(),
                ),
              );
            },
          ),
          ListTile(
            title: Text('ออกจากระบบ'),
            leading: Icon(Icons.logout),
            onTap: () async {
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
          ),
          // ElevatedButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => MapTab(),
          //       ),
          //     );
          //   },
          //   child: Row(
          //     children: [
          //       Icon(Icons.map),
          //       SizedBox(width: 15),
          //       Text(
          //         'แผนที่',
          //         style: TextStyle(
          //           fontSize: 16,
          //         ),
          //       ),
          //     ],
          //   ),
          //   style: ElevatedButton.styleFrom(
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(0),
          //     ),
          //   ),
          // ),
          // ElevatedButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => Insert_old(),
          //       ),
          //     );
          //   },
          //   child: Row(
          //     children: [
          //       Icon(Icons.perm_identity_sharp),
          //       SizedBox(width: 15),
          //       Text(
          //         'บันทึกข้อมูล',
          //         style: TextStyle(
          //           fontSize: 16,
          //         ),
          //       ),
          //     ],
          //   ),
          //   style: ElevatedButton.styleFrom(
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(0),
          //     ),
          //   ),
          // ),
          // ElevatedButton(
          //   onPressed: () async {
          //     final SharedPreferences prefs =
          //         await SharedPreferences.getInstance();
          //     prefs.setBool('isLoggedIn', false);
          //     prefs.remove('user_email');
          //     Map<String, dynamic> TagsOne = await OneSignal.User.getTags();
          //     print("ID : ${TagsOne}");
          //     TagsOne.forEach((key, value) {
          //       print("Key : $key, Value : $value");
          //       OneSignal.User.removeTag(key);
          //     });
          //     Navigator.pushReplacement(
          //       context,
          //       MaterialPageRoute(builder: (context) => LoginPage()),
          //     );
          //   },
          //   child: Row(
          //     children: [
          //       Icon(Icons.logout),
          //       SizedBox(width: 15),
          //       Text(
          //         'ออกจากระบบ',
          //         style: TextStyle(
          //           fontSize: 16,
          //         ),
          //       ),
          //     ],
          //   ),
          //   style: ElevatedButton.styleFrom(
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(0),
          //     ),
          //   ),
          // ),
          // Add more buttons as needed
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_application_5/insert_old.dart';
import 'package:flutter_application_5/login.dart';
import 'package:flutter_application_5/view_map.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu Drawer',
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
            onPressed: () {
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
                  'ออกจกระบบ',
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

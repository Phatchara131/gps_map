import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_5/menu/drawer.dart';
import 'package:flutter_application_5/update_old.dart';
import 'package:flutter_application_5/view_mapnoti.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewOld extends StatefulWidget {
  const ViewOld({Key? key}) : super(key: key);

  @override
  State<ViewOld> createState() => _ViewOldState();
}

class _ViewOldState extends State<ViewOld> {
  List userdata = [];
  List idcarddata = [];
  bool isDarkModeEnabled = false;
  bool isCardView = true;
  String searchText = '';
  String titleDrawer = '';
  @override
  void initState() {
    super.initState();
    initPlatformState();
    getrecord();
    getEmail();
  }

  Future<void> initPlatformState() async {
    var Tage = await OneSignal.User.getTags();

    print("IDX : ${Tage}");

    // ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(
    //   content: Text("ID : ${Tage}"),
    // ));
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

  void getEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    titleDrawer = prefs.getString('user_email') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("View Data")),
        drawer: CustomDrawer(title: titleDrawer),
        body: RefreshIndicator(
          child: isCardView ? _buildCardView() : _buildTableView(),
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2), () => getrecord());
          },
        ));
  }

  Widget _buildCardView() {
    return ListView.builder(
      itemCount: userdata.length,
      itemBuilder: (context, index) {
        if (searchText.isNotEmpty &&
            !userdata[index]["old_fname"]
                .toString()
                .toLowerCase()
                .contains(searchText.toLowerCase())) {
          return Container();
        }
        return Card(
          color: isDarkModeEnabled ? Colors.grey[800] : Colors.white,
          margin: EdgeInsets.all(10),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Update_old(
                    userdata[index]["old_ID"],
                    userdata[index]["old_loraID"],
                    userdata[index]["old_userID"],
                    userdata[index]["old_fname"],
                    userdata[index]["old_lname"],
                    userdata[index]["old_address"],
                    userdata[index]["old_age"],
                    userdata[index]["old_sex"],
                    userdata[index]["old_disease"],
                    userdata[index]["old_relativeID"],
                    userdata[index]["old_Cname"],
                    userdata[index]["old_Ctel"],
                  ),
                ),
              );
            },
            leading: Icon(
              CupertinoIcons.heart,
              color: Colors.red,
            ),
            title: Text(
              userdata[index]["old_fname"],
              style: TextStyle(
                  color: isDarkModeEnabled ? Colors.white : Colors.black),
            ),
            subtitle: Text(
              userdata[index]["old_lname"],
              style: TextStyle(
                  color: isDarkModeEnabled ? Colors.white : Colors.black),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    showDeleteConfirmationDialog(userdata[index]["old_ID"]);
                  },
                  icon: Icon(Icons.delete),
                  color: Colors.red,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableView() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('First Name')),
            DataColumn(label: Text('Last Name')),
            DataColumn(label: Text('Age')),
          ],
          rows: userdata.map((user) {
            return DataRow(cells: [
              DataCell(Text(user["old_ID"].toString())),
              DataCell(Text(user["old_fname"].toString())),
              DataCell(Text(user["old_lname"].toString())),
              DataCell(Text(user["old_age"].toString())),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Future<void> delrecord(String id) async {
    try {
      String uri =
          "https://project-old.000webhostapp.com/Old_API/old_delete.php";
      var res = await http.post(Uri.parse(uri), body: {"id": id});
      var response = jsonDecode(res.body);
      if (response["success"] == "true") {
        print(userdata);
        print("record deleted");
        getrecord();
      } else {
        print("some issue");
      }
    } catch (e) {
      print(e);
      print("Error");
    }
  }

  Future<void> getrecord() async {
    try {
      String uri = "https://project-old.000webhostapp.com/Old_API/old_view.php";
      var response = await http.post(Uri.parse(uri));
      setState(() {
        userdata = jsonDecode(response.body);
        print(userdata);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> getidcard() async {
    try {
      String uri =
          "https://project-old.000webhostapp.com/User_API/user_login.php";
      var response = await http.post(Uri.parse(uri));
      setState(() {
        idcarddata = jsonDecode(response.body);
        print(userdata);
      });
    } catch (e) {
      print(e);
    }
  }

  void showDeleteConfirmationDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("คุณแน่ใจที่จะลบข้อมูลนี้?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("ยกเลิก"),
            ),
            TextButton(
              onPressed: () {
                delrecord(id);
                Navigator.of(context).pop();
              },
              child: Text("ลบ"),
            ),
          ],
        );
      },
    );
  }
}

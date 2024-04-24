import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_5/menu/drawer.dart';
import 'package:flutter_application_5/update_old.dart';
import 'package:flutter_application_5/view_mapnoti.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

class ViewOld extends StatefulWidget {
  const ViewOld({Key? key}) : super(key: key);

  @override
  State<ViewOld> createState() => _ViewOldState();
}

class _ViewOldState extends State<ViewOld> {
  List userdata = [];
  bool isDarkModeEnabled = false;
  bool isCardView = true;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    getrecord();
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

  bool isEnglish(String text) {
    // รายการตัวอักษรที่ใช้ในภาษาอังกฤษ
    final englishChars = RegExp(r'[a-zA-Z]');

    // ตรวจสอบว่าข้อความมีตัวอักษรอังกฤษหรือไม่
    return englishChars.hasMatch(text);
  }

  Color getRandomColor() {
    Random random = Random();
    Color color;
    do {
      color = Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );
    } while (!_isColorReadableOnWhite(color));

    return color;
  }

  bool _isColorReadableOnWhite(Color color) {
    // ค่าความเข้มของสี
    double darkness = 1 -
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

    // ถ้าความเข้มมากกว่าหรือเท่ากับ 0.5 สีจะอ่านได้ดีกับพื้นหลังสีขาว
    return darkness < 0.5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("รายชื่อผู้สูงอายุ")),
      // สีดำโปงใส
      drawer: CustomDrawer(title: 'เมนู'),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://modernformhealthcare.co.th/wp-content/uploads/2024/02/happy-asian-senior-couple-smiling-outside.webp',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: RefreshIndicator(
          child: isCardView ? _buildCardView() : _buildTableView(),
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2), () => getrecord());
          },
        ),
      ),
    );
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
        return Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDarkModeEnabled ? Colors.black : Colors.white,
            border: Border.all(
              color: isDarkModeEnabled ? Colors.white : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: isDarkModeEnabled
                    ? Colors.black
                    : Colors.black.withOpacity(0.5),
                blurRadius: 5,
                spreadRadius: 1,
                offset: Offset(2, 5),
              ),
            ],
          ),
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
            leading: Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: getRandomColor(),
              ),
              child: Center(
                child: Text(
                  isEnglish(userdata[index]["old_fname"].toString())
                      ? userdata[index]["old_fname"]
                          .toString()
                          .substring(0, 1)
                          .toUpperCase()
                      : userdata[index]["old_fname"].toString().substring(0, 1),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
            // trailing: Row(
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     IconButton(
            //       onPressed: () {
            //         showDeleteConfirmationDialog(userdata[index]["old_ID"]);
            //       },
            //       icon: Icon(Icons.delete),
            //       color: Colors.red,
            //     ),
            //   ],
            // ),
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

  void showDeleteConfirmationDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("ยืนยันการลบข้อมูล"),
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

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
      // appBar: AppBar(
      //   title: Text("รายชื่อผู้สูงอายุ"),
      // ),
      // สีดำโปงใส
      drawer: CustomDrawer(title: 'เมนู', email: 'admin'),
      body: Builder(builder: (BuildContext innerContext) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
              // image: DecorationImage(
              //   image: NetworkImage(
              //     'https://modernformhealthcare.co.th/wp-content/uploads/2024/02/happy-asian-senior-couple-smiling-outside.webp',
              //   ),
              //   fit: BoxFit.cover,
              // ),
              ),
          child: RefreshIndicator(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/wengang-zhai-MJ_0PxIuquI-unsplash.jpg',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  children: [
                    SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Scaffold.of(innerContext).openDrawer();
                          },
                          icon: Icon(
                            Icons.menu,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "รายชื่อผู้สูงอายุ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 5,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "รายชื่อผู้สูงอายุทั้งหมด ${userdata.length} รายการ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 5,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "แตะที่รายชื่อเพื่อแก้ไขข้อมูล",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 5,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        child: TextField(
                          cursorColor: Colors.white,
                          style: TextStyle(
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 5,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "ค้นหาผู้สูงอายุ",
                            hintStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            prefixIcon: Icon(Icons.search, color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("รายการแสดงผลแบบ: "),
                        CupertinoSwitch(
                          value: isCardView,
                          onChanged: (value) {
                            setState(() {
                              isCardView = value;
                            });
                          },
                        ),
                        Text(isCardView ? "การ์ด" : "ตาราง"),
                        SizedBox(width: 20),
                      ],
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: isCardView ? _buildCardView() : _buildTableView(),
                    ),
                  ],
                ),
              ],
            ),
            onRefresh: () async {
              await Future.delayed(
                  const Duration(seconds: 2), () => getrecord());
            },
          ),
        );
      }),
    );
  }

  Widget _buildCardView() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      // shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
      ),
      itemCount: userdata.length,
      itemBuilder: (context, index) {
        if (searchText.isNotEmpty &&
            !userdata[index]["old_fname"]
                .toString()
                .toLowerCase()
                .contains(searchText.toLowerCase())) {
          return Container();
        }
        return GestureDetector(
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
          child: Container(
            margin: EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 20,
            ),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: getRandomColor(),
                  child: Text(
                    isEnglish(userdata[index]["old_fname"].toString())
                        ? userdata[index]["old_fname"]
                            .toString()
                            .substring(0, 1)
                            .toUpperCase()
                        : userdata[index]["old_fname"]
                            .toString()
                            .substring(0, 1),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "${userdata[index]["old_fname"]} ${userdata[index]["old_lname"]}",
                  style: TextStyle(
                    color: isDarkModeEnabled ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
          // columnSpacing: 20, // เพิ่มระยะห่างระหว่างคอลัมน์
          columns: [
            DataColumn(
              label: Text(
                'รหัส',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16), // เพิ่มสไตล์ข้อความ
              ),
            ),
            DataColumn(
              label: Text(
                'ชื่อ',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16), // เพิ่มสไตล์ข้อความ
              ),
            ),
            DataColumn(
              label: Text(
                'นามสกุล',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16), // เพิ่มสไตล์ข้อความ
              ),
            ),
            DataColumn(
              label: Text(
                'อายุ',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16), // เพิ่มสไตล์ข้อความ
              ),
            ),
          ],
          rows: List.generate(userdata.length, (index) {
            final user = userdata[index];
            final bool isEven = index % 2 == 0;

            return DataRow(
              color: MaterialStateColor.resolveWith((states) =>
                  isEven ? Colors.grey.withOpacity(0.1) : Colors.transparent),
              cells: [
                DataCell(
                  Text(
                    user["old_ID"].toString(),
                    style: TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    movepageEdit(user);
                  },
                ),
                DataCell(
                  Text(
                    user["old_fname"].toString(),
                    style: TextStyle(fontSize: 14),
                  ),
                  onTap: () => movepageEdit(user),
                ),
                DataCell(
                  Text(
                    user["old_lname"].toString(),
                    style: TextStyle(fontSize: 14),
                  ),
                  onTap: () => movepageEdit(user),
                ),
                DataCell(
                  Text(
                    user["old_age"].toString(),
                    style: TextStyle(fontSize: 14),
                  ),
                  onTap: () => movepageEdit(user),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  void movepageEdit(
    Map<String, dynamic> userdata,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Update_old(
          userdata["old_ID"],
          userdata["old_loraID"],
          userdata["old_userID"],
          userdata["old_fname"],
          userdata["old_lname"],
          userdata["old_address"],
          userdata["old_age"],
          userdata["old_sex"],
          userdata["old_disease"],
          userdata["old_relativeID"],
          userdata["old_Cname"],
          userdata["old_Ctel"],
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

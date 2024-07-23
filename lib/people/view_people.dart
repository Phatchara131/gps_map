import 'dart:async';
import 'dart:convert';
// import 'dart:ffi';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_5/menu/drawer.dart';
import 'package:flutter_application_5/people/update_people.dart';
import 'package:flutter_application_5/update_old.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ViewOld_people extends StatefulWidget {
  const ViewOld_people({Key? key}) : super(key: key);

  @override
  State<ViewOld_people> createState() => _ViewOld_peopleState();
}

class _ViewOld_peopleState extends State<ViewOld_people> {
  List userdata = [];
  bool isDarkModeEnabled = false;
  bool isCardView = true;
  String searchText = '';
  List<Map<String, dynamic>> ColorsUsernameEng = [
    {'A': Colors.red.shade200},
    {'B': Colors.blue.shade200},
    {'C': Colors.green.shade200},
    {'D': Colors.orange.shade200},
    {'E': Colors.yellow.shade200},
    {'F': Colors.purple.shade200},
    {'G': Colors.teal.shade200},
    {'H': Colors.pink.shade200},
    {'I': Colors.cyan.shade200},
    {'J': Colors.deepOrange.shade200},
    {'K': Colors.indigo.shade200},
    {'L': Colors.amber.shade200},
    {'M': Colors.lightBlue.shade200},
    {'N': Colors.deepPurple.shade200},
    {'O': Colors.lime.shade200},
    {'P': Colors.brown.shade200},
    {'Q': Colors.grey.shade200},
    {'R': Colors.blueGrey.shade200},
    {'S': Colors.redAccent.shade200},
    {'T': Colors.blueAccent.shade200},
    {'U': Colors.greenAccent.shade200},
    {'V': Colors.orangeAccent.shade200},
    {'W': Colors.yellowAccent.shade200},
    {'X': Colors.purpleAccent.shade200},
    {'Y': Colors.tealAccent.shade200},
    {'Z': Colors.pinkAccent.shade200},
  ];
  List<Map<String, dynamic>> ColorsUsernameThai = [
    {'ก': Colors.red.shade200},
    {'ข': Colors.blue.shade200},
    {'ค': Colors.green.shade200},
    {'ง': Colors.orange.shade200},
    {'จ': Colors.yellow.shade200},
    {'ฉ': Colors.purple.shade200},
    {'ช': Colors.teal.shade200},
    {'ซ': Colors.pink.shade200},
    {'ฌ': Colors.cyan.shade200},
    {'ญ': Colors.deepOrange.shade200},
    {'ฎ': Colors.indigo.shade200},
    {'ฏ': Colors.amber.shade200},
    {'ฐ': Colors.lightBlue.shade200},
    {'ฑ': Colors.deepPurple.shade200},
    {'ฒ': Colors.lime.shade200},
    {'ณ': Colors.brown.shade200},
    {'ด': Colors.grey.shade200},
    {'ต': Colors.blueGrey.shade200},
    {'ถ': Colors.redAccent.shade200},
    {'ท': Colors.blueAccent.shade200},
    {'ธ': Colors.greenAccent.shade200},
    {'น': Colors.orangeAccent.shade200},
    {'บ': Colors.yellowAccent.shade200},
    {'ป': Colors.purpleAccent.shade200},
    {'ผ': Colors.tealAccent.shade200},
    {'ฝ': Colors.pinkAccent.shade200},
    {'พ': Colors.brown.shade200},
    {'ฟ': Colors.grey.shade200},
    {'ภ': Colors.blueGrey.shade200},
    {'ม': Colors.redAccent.shade200},
    {'ย': Colors.blueAccent.shade200},
    {'ร': Colors.greenAccent.shade200},
    {'ล': Colors.orangeAccent.shade200},
    {'ว': Colors.yellowAccent.shade200},
    {'ศ': Colors.purpleAccent.shade200},
    {'ษ': Colors.tealAccent.shade200},
    {'ส': Colors.pinkAccent.shade200},
    {'ห': Colors.red.shade200},
    {'ฬ': Colors.blue.shade200},
    {'อ': Colors.green.shade200},
    {'ฮ': Colors.orange.shade200},
  ];
  bool isLoaded = true;
  @override
  void initState() {
    super.initState();
    getrecord();
  }

  void showLoadingMsg(String msg) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                  strokeWidth: 10,
                  backgroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                msg,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  bool isEnglishLetter(String letter) {
    return RegExp(r'^[a-zA-Z]$').hasMatch(letter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      // สีดำโปงใส
      // drawer: CustomDrawer(title: 'เมนู'),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(),
        child: RefreshIndicator(
          child: Column(
            children: [
              Text(
                "รายชื่อผู้สูงอายุ",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: isLoaded
                    ? Center(
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.greenAccent),
                            strokeWidth: 10,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: isCardView
                                ? _buildCardView()
                                : _buildTableView(),
                          ),
                        ],
                      ),
              ),
            ],
          ),
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2), () => getrecord());
          },
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> getrecordByid(String id) async {
    try {
      String uri =
          "https://project-old.000webhostapp.com/User_API/user_rest.php?getOldByID=$id";
      var response = await http.get(Uri.parse(uri));
      var jsonData = jsonDecode(response.body);
      if (jsonData['status'] == 'success') {
        print(jsonData['data']);
        print(jsonData['data']['relativeData']);
        return jsonData['data'];
      } else {
        print("error");
        return {};
      }
    } catch (e) {
      print(e);
      return {};
    }
  }

  void showOldDiaLog(String id) async {
    showLoadingMsg("กำลังโหลดข้อมูล...");
    var data = await getrecordByid(id);
    print(data.runtimeType);
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(10),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: double.infinity,
                // height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("ข้อมูลผู้สูงอายุ",
                        style: TextStyle(fontSize: 24),
                        textAlign: TextAlign.center),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 10),
                        Text(
                          "ชื่อ-สกุล : " +
                              data["old_fname"].toString() +
                              " " +
                              data["old_lname"].toString(),
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 10),
                        Text(
                          "อายุ : " + data["old_age"].toString() + " ปี",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "เบอร์โทรญาติ",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ...data["relativeData"].map<Widget>((relative) {
                      return Column(
                        children: [
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              final Uri _phoneLaunchUri = Uri(
                                scheme: 'tel',
                                path: relative["or_phone"].toString(),
                              );
                              launchUrl(_phoneLaunchUri);
                            },
                            child: Row(
                              children: [
                                Icon(Icons.phone),
                                SizedBox(width: 10),
                                Text(
                                  relative["or_phone"].toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    decoration: TextDecoration.underline,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
              Positioned(
                  top: -100,
                  child: Image.asset(
                    "assets/images/app_logox.png",
                    width: 150,
                    height: 150,
                  ))
            ],
          ),
        );
      },
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
          padding: EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isEnglishLetter(userdata[index]["old_fname"]
                          .toString()
                          .toUpperCase()[0])
                      ? ColorsUsernameEng.firstWhere((element) => element.keys.first == userdata[index]["old_fname"].toString().toUpperCase()[0])[
                          userdata[index]["old_fname"]
                              .toString()
                              .toUpperCase()[0]]
                      : isThaiCharacter(userdata[index]["old_fname"]
                              .toString()
                              .toUpperCase()[0])
                          ? ColorsUsernameThai.firstWhere((element) =>
                              element.keys.first ==
                              userdata[index]["old_fname"]
                                  .toString()
                                  .toUpperCase()[0])[userdata[index]["old_fname"].toString().toUpperCase()[0]]
                          : Colors.pink.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  userdata[index]["old_fname"].toString()[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),
              ),
              // SizedBox(width: 10),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 98,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(
                        right: 15,
                        bottom: 10,
                        top: 10,
                        left: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            userdata[index]["old_fname"].toString() +
                                " " +
                                userdata[index]["old_lname"].toString(),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "อายุ " +
                                userdata[index]["old_age"].toString() +
                                " ปี",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: -16,
                      bottom: 35,
                      child: ElevatedButton(
                        onPressed: () {
                          showOldDiaLog(userdata[index]["old_ID"].toString());
                        },
                        child: Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: Colors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isEnglishLetter(userdata[index]["old_fname"].toString().toUpperCase()[0])
                                  ? ColorsUsernameEng.firstWhere((element) => element.keys.first == userdata[index]["old_fname"].toString().toUpperCase()[0])[
                                      userdata[index]["old_fname"]
                                          .toString()
                                          .toUpperCase()[0]]
                                  : ColorsUsernameThai.firstWhere((element) =>
                                          element.keys.first ==
                                          userdata[index]["old_fname"]
                                              .toString()
                                              .toUpperCase()[0])[
                                      userdata[index]["old_fname"]
                                          .toString()
                                          .toUpperCase()[0]],
                          shape: CircleBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

  bool isThaiCharacter(String character) {
    return RegExp(r'^[ก-ฮ]$').hasMatch(character);
  }

  Future<void> getrecord() async {
    try {
      String uri =
          "https://project-old.000webhostapp.com/User_API/user_rest.php?getOldAll";
      var response = await http.get(Uri.parse(uri));
      print(response.body);
      var jsonData = jsonDecode(response.body);
      if (jsonData['status'] == 'success') {
        setState(() {
          userdata = jsonData['data'];
          isLoaded = false;
        });
      } else {
        print("error");
      }
    } catch (e) {
      print(e);
    }
  }
}

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_5/add_user.dart';
import 'package:flutter_application_5/update_old.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key, required this.user_idz}) : super(key: key);
  final int user_idz;

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  String viewtype = 'grid';
  List<Map<String, dynamic>> users = [];
  List<bool> selectedDelete = [];
  List<Map<String, dynamic>> usersBackup = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  ScrollController _scrollController = ScrollController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController idcardController = TextEditingController();
  int _page = 0;
  int _limit = 6;
  bool isLoadMore = false;
  List<Map<String, dynamic>> ColorsUsername = [
    {'A': Colors.red.shade700},
    {'B': Colors.blue.shade700},
    {'C': Colors.green.shade700},
    {'D': Colors.orange.shade700},
    {'E': Colors.yellow.shade700},
    {'F': Colors.purple.shade700},
    {'G': Colors.teal.shade700},
    {'H': Colors.pink.shade700},
    {'I': Colors.cyan.shade700},
    {'J': Colors.deepOrange.shade700},
    {'K': Colors.indigo.shade700},
    {'L': Colors.amber.shade700},
    {'M': Colors.lightBlue.shade700},
    {'N': Colors.deepPurple.shade700},
    {'O': Colors.lime.shade700},
    {'P': Colors.brown.shade700},
    {'Q': Colors.grey.shade700},
    {'R': Colors.blueGrey.shade700},
    {'S': Colors.redAccent.shade700},
    {'T': Colors.blueAccent.shade700},
    {'U': Colors.greenAccent.shade700},
    {'V': Colors.orangeAccent.shade700},
    {'W': Colors.yellowAccent.shade700},
    {'X': Colors.purpleAccent.shade700},
    {'Y': Colors.tealAccent.shade700},
    {'Z': Colors.pinkAccent.shade700},
  ];

  Future<void> loadData() async {
    setState(() {
      _page = 0;
      _limit = 6;
      isLoading = true;
    });
    print('Load data');
    try {
      String url =
          'https://project-old.000webhostapp.com/User_API/user_rest.php?getAllUser&page=$_page&limit=$_limit';
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // print(response.body);
        var jsonData = json.decode(response.body);
        // print(jsonData['data']);
        // selectedDelete = [];
        // users = [];
        // usersBackup = [];
        print(jsonData['data'].length);
        setState(() {
          print("Load data success ${jsonData['data'].length}");
          selectedDelete = List<bool>.filled(jsonData['data'].length, false);
          users = List<Map<String, dynamic>>.from(jsonData['data']);
          usersBackup = List<Map<String, dynamic>>.from(jsonData['data']);
          isLoading = false;
        });
        print(users);
      } else {
        print('Failed to load data!');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadMoreData() async {
    setState(() {
      _page += 6;
      _limit += 6;
    });
    try {
      String url =
          'https://project-old.000webhostapp.com/User_API/user_rest.php?getAllUser&page=$_page&limit=$_limit';
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // print(response.body);
        var jsonData = json.decode(response.body);
        // print(jsonData['data']);
        if (jsonData['status'] == 'success') {
          setState(() {
            users.addAll(List<Map<String, dynamic>>.from(jsonData['data']));
            usersBackup
                .addAll(List<Map<String, dynamic>>.from(jsonData['data']));
            selectedDelete = List<bool>.filled(users.length, false);
            isLoadMore = false;
          });
          print(users);
        } else {
          print('No more data');
          //show SnackBar
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('ไม่มีข้อมูลเพิ่มเติม'),
          //     duration: Duration(seconds: 2),
          //     backgroundColor: Colors.black.withOpacity(0.5),
          //   ),
          // );
          setState(() {
            isLoadMore = false;
          });
        }
      } else {
        print('Failed to load data!');
      }
    } catch (e) {
      print(e);
    }
  }

  void searchUser(String keyword) async {
    print(keyword);
    if (keyword.isEmpty) {
      setState(() {
        users = usersBackup;
        selectedDelete = List<bool>.filled(users.length, false);
      });
      return;
    } else {
      users = usersBackup;
      setState(() {
        users = users.where((user) {
          return user['user_name']
                  .toLowerCase()
                  .contains(keyword.toLowerCase()) ||
              user['user_email'].toLowerCase().contains(keyword.toLowerCase());
        }).toList();
        selectedDelete = List<bool>.filled(users.length, false);
      });
    }
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

  void delUser() async {
    Navigator.pop(context);
    showLoadingMsg('กำลังลบข้อมูล...');
    List<int> selectedDeleteID = [];
    for (int i = 0; i < selectedDelete.length; i++) {
      if (selectedDelete[i]) {
        selectedDeleteID.add(users[i]['user_ID']);
      }
    }
    print(selectedDeleteID);
    bool checkdel = await deleteUser(selectedDeleteID);
    if (checkdel) {
      await loadData();
      // setState(() {
      //   users.removeWhere((user) => selectedDeleteID.contains(user['user_ID']));
      //   usersBackup
      //       .removeWhere((user) => selectedDeleteID.contains(user['user_ID']));
      //   selectedDelete = List<bool>.filled(users.length, false);
      // });
      print('Delete success');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ลบข้อมูลสำเร็จ'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green.shade800,
        ),
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ลบข้อมูลไม่สำเร็จ'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<bool> deleteUser(List<int> userIdData) async {
    try {
      String url =
          'https://project-old.000webhostapp.com/User_API/user_rest.php?deleteUserByID';
      var response = await http.post(Uri.parse(url), body: {
        'user_id': json.encode(userIdData),
        'action': 'deleteUserByID',
      });
      if (response.statusCode == 200) {
        print(response.body);
        var jsonData = json.decode(response.body);
        // print(jsonData);
        if (jsonData['status'] == 'success') {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('User ID: ${widget.user_idz}');

    loadData();
    showLoading();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('Load more data');
        setState(() {
          isLoadMore = true;
        });
        _loadMoreData();
      }
    });
    if (widget.user_idz != 0) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        dialogEditUser(widget.user_idz.toString());
      });
    }
  }

  void showLoading() {
    // print('showLoading');
    //รอ 2 วินาที
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('User List'),
      // ),
      body: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 200,
            // padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              // color: Colors.blue,
              color: Colors.grey,
              image: DecorationImage(
                image: AssetImage('assets/images/userpage.jpg'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 34),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      Container(
                        child: Text(
                          'จัดการข้อมูลผู้ใช้',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black,
                                offset: Offset(2.0, 5.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.only(left: 20),
                  width: double.infinity,
                  child: Text(
                    "จำนวนผู้ใช้ทั้งหมด 10 คน",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black,
                          offset: Offset(2.0, 5.0),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                //search
                Container(
                  // padding: EdgeInsets.only(left: 20, right: 20),
                  margin: EdgeInsets.only(left: 20, right: 20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  width: double.infinity,
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      print(value);
                      searchUser(value);
                    },
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      hintText: 'ค้นหา',
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          searchController.clear();
                          searchUser('');
                        },
                        child: Icon(
                          Icons.clear,
                          color: Colors.white,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // SizedBox(height: 10),
          // Container(
          //   padding: EdgeInsets.only(left: 10, right: 10),
          //   width: double.infinity,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     crossAxisAlignment: CrossAxisAlignment.end,
          //     children: [
          //       Text(
          //         "แสดงรายการแบบ",
          //         style: TextStyle(
          //           color: Colors.black,
          //           fontSize: 20,
          //           // fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //       //icon grid and table
          //       GestureDetector(
          //         onTap: () {
          //           setState(() {
          //             viewtype = 'grid';
          //           });
          //         },
          //         child: Icon(
          //           Icons.grid_view,
          //           color: viewtype == 'grid' ? Colors.green : Colors.black,
          //         ),
          //       ),
          //       // SizedBox(width: 10),
          //       GestureDetector(
          //         onTap: () {
          //           setState(() {
          //             viewtype = 'table';
          //           });
          //         },
          //         child: Icon(
          //           Icons.table_rows,
          //           color: viewtype == 'grid' ? Colors.black : Colors.green,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // print('Add');
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return RegisterUserPage(updateData: loadData);
                    }));
                  },
                  child: Icon(Icons.add),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade900,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.zero,
                    minimumSize: Size(50, 40),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    // print('Delete');
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.confirm,
                      title: 'ยืนยันการลบข้อมูล',
                      text: 'คุณต้องการลบข้อมูลที่เลือกหรือไม่?',
                      showCancelBtn: true,
                      cancelBtnText: 'ยกเลิก',
                      confirmBtnText: 'ยืนยัน',
                      confirmBtnColor: Colors.red,
                      onConfirmBtnTap: () async {
                        delUser();
                        // Navigator.pop(context);
                      },
                    );
                  },
                  child: Icon(Icons.delete),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.zero,
                    minimumSize: Size(50, 40),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.green,
                      backgroundColor: Colors.grey.shade300,
                      strokeWidth: 5,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: loadData,
                    child: viewtype == 'grid'
                        ? GridView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.only(bottom: 40),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1,
                              mainAxisExtent: 200,
                            ),
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              return _buildUserCard(users[index]);
                            },
                          )
                        : RefreshIndicator(
                            onRefresh: loadData,
                            child: _buildUserTable(),
                          ),
                  ),
          ),
          isLoadMore
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.green,
                    backgroundColor: Colors.grey.shade300,
                    strokeWidth: 5,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Color generateRandomCoolColor() {
    final Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256), // สร้างค่าสีสุ่มสำหรับสีแดง
      random.nextInt(256), // สร้างค่าสีสุ่มสำหรับสีเขียว
      random.nextInt(256), // สร้างค่าสีสุ่มสำหรับสีน้ำเงิน
      1.0, // ให้ alpha มีค่าเป็น 1 (ค่าสูงสุด)
    );
  }

  Future<List<Map<String, dynamic>>> loaduserDataById(String user_id) async {
    try {
      String url =
          'https://project-old.000webhostapp.com/User_API/user_rest.php?getUserByID=$user_id';
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        return List<Map<String, dynamic>>.from(jsonData['data']);
      } else {
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> loadoldData(String user_id) async {
    try {
      String url =
          'https://project-old.000webhostapp.com/User_API/user_rest.php?getUserOld_by_relativeID=$user_id';
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        return List<Map<String, dynamic>>.from(jsonData['data']);
      } else {
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> updateUserData(String user_id) async {
    showLoadingMsg('กำลังแก้ไขข้อมูล...');
    try {
      String url =
          'https://project-old.000webhostapp.com/User_API/user_rest.php?updateUser';
      var response = await http.post(Uri.parse(url), body: {
        'user_ID': user_id,
        'user_name': nameController.text,
        'user_email': emailController.text,
        'user_idcard': idcardController.text,
        'action': 'updateuser',
      });
      if (response.statusCode == 200) {
        print(response.body);
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          Navigator.pop(context);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('แก้ไขข้อมูลสำเร็จ'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green.shade800,
            ),
          );
          // loadData();
        } else {
          Navigator.pop(context);
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'แก้ไขข้อมูลไม่สำเร็จ',
            text: jsonData['message'],
            showCancelBtn: false,
            confirmBtnText: 'ตกลง',
            confirmBtnColor: Colors.red,
            onConfirmBtnTap: () {
              Navigator.pop(context);
            },
          );
        }
      } else {
        print('Update failed');
      }
    } catch (e) {
      print(e);
      // Navigator.pop(context);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('แก้ไขข้อมูลไม่สำเร็จ'),
      //     duration: Duration(seconds: 2),
      //     backgroundColor: Colors.red.shade700,
      //   ),
      // );
    }
  }

  void dialogEditUser(String user_id) async {
    print('Edit user $user_id');
    showLoadingMsg('กำลังโหลดข้อมูล...');
    var oldData = await loadoldData(user_id);
    var userData = await loaduserDataById(user_id);
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return (Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(10),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    // height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'แก้ไขข้อมูลผู้ใช้',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextField(
                            cursorColor: Colors.black,
                            controller: nameController
                              ..text = userData[0]['user_name'],
                            decoration: InputDecoration(
                              labelText: 'ชื่อ-สกุล',
                              hintText: 'ชื่อ-สกุล',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              labelStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          TextField(
                            cursorColor: Colors.black,
                            controller: emailController
                              ..text = userData[0]['user_email'],
                            decoration: InputDecoration(
                              labelText: 'อีเมล',
                              hintText: 'อีเมล',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              labelStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          TextField(
                            cursorColor: Colors.black,
                            controller: idcardController
                              ..text = userData[0]['user_idcard'],
                            decoration: InputDecoration(
                              labelText: 'เลขบัตรประชาชน',
                              hintText: 'เลขบัตรประชาชน',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              labelStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          oldData.length != 0
                              ? Text(
                                  'รายการผู้สูงอายุ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Container(),
                          oldData.length != 0
                              ? Container(
                                  width: double.infinity,
                                  child: Text(
                                    "*กดเพื่อดูและแก้ไขข้อมูลผู้สูงอายุ",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Container(),
                          oldData.length != 0
                              ? Container(
                                  width: double.infinity,
                                  height: 100,
                                  child: ListView.builder(
                                    itemCount: oldData.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: ListTile(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    Update_old(
                                                  oldData[index]["old_ID"]
                                                      .toString(),
                                                  oldData[index]["old_loraID"]
                                                      .toString(),
                                                  oldData[index]["old_userID"]
                                                      .toString(),
                                                  oldData[index]["old_fname"]
                                                      .toString(),
                                                  oldData[index]["old_lname"]
                                                      .toString(),
                                                  oldData[index]["old_address"]
                                                      .toString(),
                                                  oldData[index]["old_age"]
                                                      .toString(),
                                                  oldData[index]["old_sex"]
                                                      .toString(),
                                                  oldData[index]["old_disease"]
                                                      .toString(),
                                                  oldData[index]
                                                          ["old_relativeID"]
                                                      .toString(),
                                                  oldData[index]["old_Cname"]
                                                      .toString(),
                                                  oldData[index]["old_Ctel"]
                                                      .toString(),
                                                  "userpage",
                                                  userData[0]['user_idcard']
                                                      .toString(),
                                                ),
                                              ),
                                            );
                                          },
                                          title: Text(
                                              "${oldData[index]['old_fname']} ${oldData[index]['old_lname']}"),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  "ที่อยู่ ${oldData[index]['old_address']} โทร ${oldData[index]['or_phone']}"),
                                              Text(
                                                  "อายุ ${oldData[index]['old_age']} เพศ ${oldData[index]['old_sex']}"),
                                            ],
                                          ),
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.blue,
                                            child: Text(
                                              oldData[index]['old_fname'][0]
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Container(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(Icons.close),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade800,
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(50, 50),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  updateUserData(
                                      userData[0]['user_ID'].toString());
                                  // Navigator.pop(context);
                                },
                                child: Icon(Icons.save),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade800,
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(50, 50),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ]
                            .expand((widget) => [
                                  widget,
                                  SizedBox(height: 15),
                                ])
                            .toList(),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -100,
                    child: Image.asset(
                      "assets/images/app_logo.png",
                      width: 150,
                      height: 150,
                    ),
                  )
                ],
              ),
            ));
          },
        );
      },
    );
  }

  _buildUserCard(Map<String, dynamic> user) {
    return GestureDetector(
      onTap: () {
        // print(user);
        dialogEditUser(user['user_idcard'].toString());
      },
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(10),
        // padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              height: 200,
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      color: ColorsUsername.where((element) =>
                              element.keys.first ==
                              user['user_name'][0].toUpperCase())
                          .first
                          .values
                          .first,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        alignment: Alignment.center,
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                        ),
                        child: Text(
                          user['user_email'][0].toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black,
                                offset: Offset(2.0, 5.0),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Divider(),
                  Container(
                    height: 60,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection:
                          Axis.vertical, // เปลี่ยนเป็น Axis.vertical
                      child: SingleChildScrollView(
                        // ใช้ SingleChildScrollView ชั้นในเพื่อเลื่อนแนวนอน
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.black,
                                  size: 14,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  user['user_name'],
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.email,
                                  color: Colors.black,
                                  size: 14,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  user['user_email'],
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            //idcard
                            Row(
                              children: [
                                Icon(
                                  Icons.credit_card,
                                  color: Colors.black,
                                  size: 14,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  user['user_idcard'],
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -3,
              left: -5,
              child: Checkbox(
                activeColor: Colors.red.shade800,
                value: selectedDelete[users.indexOf(user)],
                onChanged: (value) {
                  print(user);
                  setState(() {
                    selectedDelete[users.indexOf(user)] = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(
              label: Checkbox(
                value: selectedDelete.every((element) => element),
                onChanged: (value) {
                  setState(() {
                    selectedDelete = List<bool>.filled(users.length, value!);
                  });
                },
              ),
            ),
            DataColumn(
              label: Text(
                'ชื่อ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'อีเมล',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'บัตรประชาชน',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: users
              .asMap()
              .map((index, user) => MapEntry(
                    index,
                    DataRow(
                      color: MaterialStateColor.resolveWith((states) =>
                          index % 2 == 0 ? Colors.grey[200]! : Colors.white),
                      cells: [
                        DataCell(Checkbox(
                          value: selectedDelete[index],
                          onChanged: (value) {
                            setState(() {
                              selectedDelete[index] = value!;
                            });
                          },
                        )),
                        DataCell(Text(user['user_name'])),
                        DataCell(Text(user['user_email'])),
                        DataCell(Text(user['user_idcard'])),
                      ],
                    ),
                  ))
              .values
              .toList(),
        ),
      ),
    );
  }
}

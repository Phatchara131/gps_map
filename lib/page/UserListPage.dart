import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

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
  Future<void> _loadData() async {
    try {
      String url =
          'https://project-old.000webhostapp.com/User_API/user_rest.php?getAllUser';
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // print(response.body);
        var jsonData = json.decode(response.body);
        // print(jsonData['data']);
        setState(() {
          selectedDelete = List<bool>.filled(jsonData['data'].length, false);
          users = List<Map<String, dynamic>>.from(jsonData['data']);
          usersBackup = List<Map<String, dynamic>>.from(jsonData['data']);
        });
        print(users);
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
    showLoading();
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
                image: AssetImage(
                    'assets/images/roel-dierckens-SsuQQAaZoZQ-unsplash.jpg'),
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
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "แสดงรายการแบบ",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
                //icon grid and table
                GestureDetector(
                  onTap: () {
                    setState(() {
                      viewtype = 'grid';
                    });
                  },
                  child: Icon(
                    Icons.grid_view,
                    color: viewtype == 'grid' ? Colors.green : Colors.black,
                  ),
                ),
                // SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      viewtype = 'table';
                    });
                  },
                  child: Icon(
                    Icons.table_rows,
                    color: viewtype == 'grid' ? Colors.black : Colors.green,
                  ),
                ),
              ],
            ),
          ),
          // SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    print('Add');
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
                  onPressed: () {
                    // print('Delete');
                    for (int i = 0; i < selectedDelete.length; i++) {
                      if (selectedDelete[i]) {
                        print(users[i]['user_name']);
                      }
                    }
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
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: viewtype == 'grid'
                        ? GridView.builder(
                            padding: EdgeInsets.all(0),
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
                        : _buildUserTable(),
                  ),
          ),
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

  _buildUserCard(Map<String, dynamic> user) {
    return GestureDetector(
      onTap: () {
        print(user);
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
                      gradient: LinearGradient(
                        colors: [
                          generateRandomCoolColor(),
                          generateRandomCoolColor(),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        alignment: Alignment.center,
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: Text(
                          user['user_name'][0].toUpperCase(),
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
                    width: double.infinity,
                    child: SingleChildScrollView(
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
                ],
              ),
            ),
            Positioned(
              top: -3,
              left: -5,
              child: Checkbox(
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
    //use datatable
    return SingleChildScrollView(
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
          )),
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
    );
  }
}

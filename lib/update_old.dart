import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_5/page/UserListPage.dart';
import 'package:flutter_application_5/relative/view_relative.dart';
import 'package:flutter_application_5/view_main.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Update_old extends StatefulWidget {
  String old_id;
  String loraId;
  String userId;
  String fname;
  String lname;
  String address;
  String age;
  String gender;
  String medicalCondition;
  String relativeID;
  String relativeName;
  String contactNumber;
  String action;
  String relativeIDCARD;

  Update_old(
    this.old_id,
    this.loraId,
    this.userId,
    this.fname,
    this.lname,
    this.address,
    this.age,
    this.gender,
    this.medicalCondition,
    this.relativeID,
    this.relativeName,
    this.contactNumber,
    this.action,
    this.relativeIDCARD,
  );
  @override
  State<Update_old> createState() => _Update_oldState();
}

class _Update_oldState extends State<Update_old> {
  String? selectedGender;
  TextEditingController loraId = TextEditingController();
  TextEditingController userId = TextEditingController();
  TextEditingController fname = TextEditingController();
  TextEditingController lname = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController age = TextEditingController();
  TextEditingController gender = TextEditingController();
  TextEditingController medicalCondition = TextEditingController();
  TextEditingController relativeID = TextEditingController();
  TextEditingController relativeName = TextEditingController();
  TextEditingController contactNumber = TextEditingController();
  TextEditingController passwordCheck = TextEditingController();
  TextEditingController relativeIDController = TextEditingController();
  TextEditingController relativeNameController = TextEditingController();
  List<TextEditingController> relativeNameControllerList = [];
  TextEditingController contactNumberController = TextEditingController();
  List<Map<String, String>> relativeData = [];
  bool ischeckIDCARD = false;
  String relativeIDstr = '';
  List<String> relativeIDList = [];
  FocusNode focusNode = FocusNode();

  Future<void> updaterecord() async {
    showLoading('กำลังอัพเดทข้อมูล...');
    try {
      String uri =
          "https://project-old.000webhostapp.com/User_API/user_rest.php";
      var res = await http.post(Uri.parse(uri), body: {
        "action": "update_old_data",
        "old_ID": widget.old_id,
        "old_loraID": loraId.text,
        "old_userID": userId.text,
        "old_fname": fname.text,
        "old_lname": lname.text,
        "old_address": address.text,
        "old_age": age.text,
        "old_sex": selectedGender,
        "old_disease": medicalCondition.text,
        // "old_relativeID": relativeID.text,
        // "old_Cname": relativeName.text,
        // "old_Ctel": contactNumber.text,
      });
      if (res.statusCode == 200) {
        print(res.body);
        var response = jsonDecode(res.body);
        if (response["status"] == "success") {
          print("update");
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          String user_idcard = prefs.getString('user_idcard') ?? '';
          print(user_idcard);
          Navigator.of(context).pop();
          if (widget.action == 'userpage') {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => UserListPage(
                        user_idz: int.parse(widget.relativeIDCARD))));
          } else {
            if (user_idcard == 'admin') {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => ViewOld()),
                  (route) => false);
            } else {
              String titleDrawer = prefs.getString('user_name') ?? '';
              String emailDrawer = prefs.getString('user_email') ?? '';
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewOldRela(
                          titleDrawer: titleDrawer, emailDrawer: emailDrawer)),
                  (route) => false);
            }
          }
        } else {
          print("some issue");
        }
      }
      // var response = jsonDecode(res.body);
      // if (response["success"] == "true") {
      //   print("update");
      //   final SharedPreferences prefs = await SharedPreferences.getInstance();
      //   String user_idcard = prefs.getString('user_idcard') ?? '';
      //   print(user_idcard);
      //   if (user_idcard == 'admin') {
      //     Navigator.pushAndRemoveUntil(
      //         context,
      //         MaterialPageRoute(builder: (context) => ViewOld()),
      //         (route) => false);
      //   } else {
      //     Navigator.pushAndRemoveUntil(
      //         context,
      //         MaterialPageRoute(builder: (context) => ViewOldRela()),
      //         (route) => false);
      //   }
      // } else {
      //   print("some issue");
      // }
    } catch (e) {
      print(e);
    }
  }

  bool validateThaiID(String id) {
    if (id.length != 13) {
      return false;
    }

    if (!RegExp(r'^[0-9]*$').hasMatch(id)) {
      return false;
    }

    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += int.parse(id[i]) * (13 - i);
    }
    if ((11 - (sum % 11)) % 10 != int.parse(id[12])) {
      return false;
    }

    return true;
  }

  Future<void> getOldrelative(String id) async {
    try {
      String uri =
          "https://project-old.000webhostapp.com/User_API/user_rest.php?old_relative_data_by_id=$id";
      var res = await http.get(Uri.parse(uri));
      if (res.statusCode == 200) {
        var response = jsonDecode(res.body);
        print(response);
        if (response["status"] == "success") {
          print(response["data"]);
          relativeData.clear();
          relativeIDList.clear();
          response["data"].forEach((element) {
            setState(() {
              relativeData.add({
                'relativeID': element['user_ID'].toString(),
                'relativeName': element['user_name'].toString(),
                'contactNumber': element['or_phone'].toString(),
                'relativeIDCARD': element['user_idcard'].toString(),
              });
              relativeIDList.add(element['or_id'].toString());
            });
          });
          // print(relativeData);
          print(relativeIDList);
        } else {
          print("some issue");
        }
      }
    } catch (e) {
      print(e);
      print("Error");
    }
  }

  bool isThaiPhoneNumber(String number) {
    // ตรวจสอบว่ามีแต่ตัวเลขหรือไม่
    if (number == null ||
        number.isEmpty ||
        !RegExp(r'^[0-9]+$').hasMatch(number)) {
      return false;
    }

    // ตรวจสอบความยาวของหมายเลขโทรศัพท์
    if (number.length != 10 && number.length != 11) {
      return false;
    }

    // ตรวจสอบหมายเลขโทรศัพท์ที่เริ่มต้นด้วย 0 หรือ +66
    if (!number.startsWith('0') && !number.startsWith('+66')) {
      return false;
    }

    // แปลงหมายเลขที่เริ่มต้นด้วย +66 เป็น 0
    if (number.startsWith('+66')) {
      number = '0' + number.substring(3);
    }

    // ตรวจสอบหมายเลขโทรศัพท์ในประเทศไทย
    if (!RegExp(r'^0[689][0-9]{8}$').hasMatch(number)) {
      return false;
    }

    return true;
  }

  void showLoading(String msg) {
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

  Future<void> insert_old_relative_data(
      String or_user_id, String or_old_id, String or_phone) async {
    showLoading('กำลังเพิ่มข้อมูล...');
    try {
      String uri =
          "https://project-old.000webhostapp.com/User_API/user_rest.php";
      var res = await http.post(Uri.parse(uri), body: {
        "action": "insert_old_relative_data",
        "or_user_id": or_user_id,
        "or_old_id": or_old_id,
        "or_phone": or_phone
      });
      if (res.statusCode == 200) {
        print(res.body);
        var response = jsonDecode(res.body);
        if (response["status"] == "success") {
          await getOldrelative(widget.old_id);
          Navigator.of(context).pop();
        } else {
          print("some issue");
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteOldrelative(String id) async {
    try {
      String uri =
          "https://project-old.000webhostapp.com/User_API/user_rest.php?deleteOldrelative=$id";
      var res = await http.get(Uri.parse(uri));
      if (res.statusCode == 200) {
        var response = jsonDecode(res.body);
        if (response["status"] == "success") {
          print("delete success");
          await getOldrelative(widget.old_id);
          Navigator.of(context).pop();
        } else {
          print("some issue");
        }
      }
    } catch (e) {
      print(e);
      print("Error");
    }
  }

  @override
  void initState() {
    loraId.text = widget.loraId;
    userId.text = widget.userId;
    fname.text = widget.fname;
    lname.text = widget.lname;
    address.text = widget.address;
    age.text = widget.age;
    gender.text = widget.gender;
    medicalCondition.text = widget.medicalCondition;
    relativeID.text = widget.relativeID;
    relativeName.text = widget.relativeName;
    contactNumber.text = widget.contactNumber;
    selectedGender = widget.gender;
    // print(widget.relativeID);
    // print(widget.relativeName);
    print(widget.old_id);
    getOldrelative(widget.old_id);
    super.initState();
  }

  Future<void> delrecord(String id) async {
    try {
      String uri =
          "https://project-old.000webhostapp.com/Old_API/old_delete.php";
      var res = await http.post(Uri.parse(uri), body: {"id": id});
      var response = jsonDecode(res.body);
      if (response["success"] == "true") {
        // print(userdata);
        print("record deleted");
        // getrecord();
      } else {
        print("some issue");
      }
    } catch (e) {
      print(e);
      print("Error");
    }
  }

  Future<bool> checkRelative(String id) async {
    try {
      String url =
          'https://project-old.000webhostapp.com/User_API/user_rest.php?check_user_idcard=$id';
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        // print(jsonData);
        if (jsonData['status'] == 'success') {
          print(jsonData['data']['user_name']);
          setState(() {
            relativeNameController.text = jsonData['data']['user_name'];
            relativeIDstr = jsonData['data']['user_ID'].toString();
            // contactNumberController.text = jsonData['data']['user_tel'];
          });
          return true;
        } else {
          return false;
        }
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ข้อมูลผู้สูงอายุ"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          ElevatedButton(
            onPressed: () {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.confirm,
                title: 'ยืนยันการอัพเดทข้อมูล',
                text: 'คุณต้องการที่จะอัพเดทข้อมูลหรือไม่?',
                showConfirmBtn: true,
                confirmBtnText: 'ใช่',
                confirmBtnColor: Colors.green,
                cancelBtnText: 'ไม่',
                onConfirmBtnTap: () {
                  Navigator.of(context).pop(); // ปิด AlertDialog
                  updaterecord(); // เรียกใช้งานฟังก์ชัน
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(0),
              minimumSize: Size(40, 40),
            ),
            child: Icon(Icons.save),
          ),
          //delete btn
          ElevatedButton(
            onPressed: () {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.confirm,
                title: 'ยืนยันการลบข้อมูล',
                text: 'คุณต้องการที่จะลบข้อมูลหรือไม่?',
                showConfirmBtn: true,
                confirmBtnText: 'ใช่',
                confirmBtnColor: Colors.red,
                cancelBtnText: 'ไม่',
                widget: Container(
                  margin: EdgeInsets.only(top: 10),
                  width: double.infinity,
                  child: TextField(
                    controller: passwordCheck,
                    focusNode: focusNode,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'กรอกรหัสผ่านเพื่อลบข้อมูล',
                      labelStyle: TextStyle(
                        color: focusNode.hasFocus ? Colors.green : Colors.grey,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 2),
                      ),
                      hintText: 'รหัสผ่าน...',
                    ),
                  ),
                ),
                onConfirmBtnTap: () async {
                  // Navigator.of(context).pop(); // ปิด AlertDialog
                  // delrecord(widget.old_id); // เรียกใช้งานฟังก์ชัน
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String password = prefs.getString('user_password') ?? '';
                  print(password);
                  if (passwordCheck.text == password) {
                    Navigator.of(context).pop(); // ปิด AlertDialog
                    delrecord(widget.old_id); // เรียกใช้งานฟังก์ชัน
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => ViewOld()),
                        (route) => false);
                  } else {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: 'รหัสผ่านไม่ถูกต้อง',
                      text: 'กรุณากรอกรหัสผ่านให้ถูกต้อง',
                      showConfirmBtn: true,
                      confirmBtnText: 'ตกลง',
                      confirmBtnColor: Colors.red,
                    );
                  }
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(0),
              minimumSize: Size(40, 40),
            ),
            child: Icon(Icons.delete),
          ),
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(10),
                child: TextFormField(
                  controller: loraId,
                  readOnly: true, // Set this to true to make it readonly
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'รหัสอุปกรณ์...',
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: TextFormField(
                  controller: userId,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'รหัสประจำตัว...',
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: TextFormField(
                  controller: fname,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'ชื่อ...',
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: TextFormField(
                  controller: lname,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'นามสกุล...',
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: TextFormField(
                  controller: address,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'ที่อยู่...',
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: TextFormField(
                  controller: age,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'อายุ...',
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    labelText: 'เพศ...',
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    fillColor: Colors.transparent,
                    // prefixIcon: Icon(Icons.wc),
                  ),
                  items: ['ชาย', 'หญิง', 'อื่นๆ'].map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                ),

                // child: TextFormField(
                //   controller: gender,
                //   decoration: const InputDecoration(
                //     border: OutlineInputBorder(),
                //     labelText: 'เพศ...',
                //   ),
                // ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: TextFormField(
                  controller: medicalCondition,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'โรคประจำตัว...',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      ischeckIDCARD = false;
                      //clear Textfield
                      relativeIDController.clear();
                      relativeNameController.clear();
                      contactNumberController.clear();
                    });
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (context, setStatex) {
                            return Dialog(
                              insetPadding: EdgeInsets.all(10),
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.white,
                                    ),
                                    padding:
                                        EdgeInsets.fromLTRB(20, 50, 20, 20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "เพิ่มญาติ",
                                          style: TextStyle(fontSize: 24),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 10),
                                        TextFormField(
                                          readOnly: ischeckIDCARD,
                                          controller: relativeIDController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(),
                                            filled: true,
                                            labelText: 'บัตรประจำตัว(ญาติ)...',
                                            labelStyle:
                                                TextStyle(color: Colors.black),
                                            prefixIcon:
                                                Icon(Icons.perm_identity),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                        //ตรวจสอบรหัสบัตรประจำตัว
                                        SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: ischeckIDCARD
                                              ? null
                                              : () async {
                                                  if (relativeIDController
                                                      .text.isEmpty) {
                                                    QuickAlert.show(
                                                      context: context,
                                                      title: 'ข้อมูลไม่ครบถ้วน',
                                                      text:
                                                          'กรุณากรอกข้อมูลให้ครบถ้วน',
                                                      type:
                                                          QuickAlertType.error,
                                                      confirmBtnText: 'ตกลง',
                                                      confirmBtnColor:
                                                          Colors.red.shade900,
                                                    );
                                                    return;
                                                  }
                                                  if (!validateThaiID(
                                                      relativeIDController
                                                          .text)) {
                                                    QuickAlert.show(
                                                      context: context,
                                                      title:
                                                          'รหัสบัตรประจำตัวไม่ถูกต้อง',
                                                      text:
                                                          'กรุณากรอกรหัสบัตรประจำตัวให้ถูกต้อง',
                                                      type:
                                                          QuickAlertType.error,
                                                      confirmBtnText: 'ตกลง',
                                                      confirmBtnColor:
                                                          Colors.red.shade900,
                                                    );
                                                    return;
                                                  }
                                                  QuickAlert.show(
                                                    context: context,
                                                    title: 'กำลังตรวจสอบ...',
                                                    text: 'กรุณารอสักครู่',
                                                    type:
                                                        QuickAlertType.loading,
                                                  );
                                                  bool isRelativeExist =
                                                      await checkRelative(
                                                          relativeIDController
                                                              .text);
                                                  Navigator.of(context).pop();
                                                  print(
                                                      "isRelativeExist: $isRelativeExist");
                                                  if (!isRelativeExist) {
                                                    QuickAlert.show(
                                                      context: context,
                                                      title: 'ไม่พบข้อมูลญาติ',
                                                      text:
                                                          'ไม่พบข้อมูลญาติในระบบ',
                                                      type:
                                                          QuickAlertType.error,
                                                      confirmBtnText: 'ตกลง',
                                                      confirmBtnColor:
                                                          Colors.red.shade900,
                                                    );
                                                    return;
                                                  }
                                                  QuickAlert.show(
                                                    context: context,
                                                    title:
                                                        'รหัสบัตรประจำตัวถูกต้อง',
                                                    text:
                                                        'รหัสบัตรประจำตัวนี้สามารถใช้ได้',
                                                    type:
                                                        QuickAlertType.success,
                                                    confirmBtnText: 'ตกลง',
                                                    confirmBtnColor:
                                                        Colors.green,
                                                  );
                                                  setStatex(() {
                                                    ischeckIDCARD = true;
                                                  });
                                                },
                                          child: Text('ตรวจสอบ'),
                                          style: ElevatedButton.styleFrom(
                                            minimumSize:
                                                Size(double.infinity, 50),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            foregroundColor: Colors.blue,
                                            backgroundColor: Colors.white,
                                            shadowColor: Colors.white,
                                            side:
                                                BorderSide(color: Colors.blue),
                                            textStyle: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        ischeckIDCARD
                                            ? SizedBox(height: 20)
                                            : Container(),
                                        ischeckIDCARD
                                            ? TextFormField(
                                                readOnly: true,
                                                controller:
                                                    relativeNameController,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  labelText: 'ชื่อ(ญาติ)...',
                                                  labelStyle: TextStyle(
                                                      color: Colors.black),
                                                  prefixIcon:
                                                      Icon(Icons.person),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        ischeckIDCARD
                                            ? SizedBox(height: 10)
                                            : Container(),
                                        ischeckIDCARD
                                            ? TextFormField(
                                                keyboardType:
                                                    TextInputType.phone,
                                                controller:
                                                    contactNumberController,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  labelText:
                                                      'เบอร์ติดต่อ(ญาติ)...',
                                                  labelStyle: TextStyle(
                                                      color: Colors.black),
                                                  prefixIcon: Icon(Icons.phone),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        ischeckIDCARD
                                            ? SizedBox(height: 10)
                                            : Container(),
                                        ischeckIDCARD
                                            ? ElevatedButton(
                                                onPressed: () async {
                                                  if (relativeIDController
                                                          .text.isEmpty ||
                                                      relativeNameController
                                                          .text.isEmpty ||
                                                      contactNumberController
                                                          .text.isEmpty) {
                                                    QuickAlert.show(
                                                      context: context,
                                                      title: 'ข้อมูลไม่ครบถ้วน',
                                                      text:
                                                          'กรุณากรอกข้อมูลให้ครบถ้วน',
                                                      type:
                                                          QuickAlertType.error,
                                                      confirmBtnText: 'ตกลง',
                                                      confirmBtnColor:
                                                          Colors.red.shade900,
                                                    );
                                                    return;
                                                  }
                                                  if (!validateThaiID(
                                                      relativeIDController
                                                          .text)) {
                                                    QuickAlert.show(
                                                      context: context,
                                                      title:
                                                          'รหัสบัตรประจำตัวไม่ถูกต้อง',
                                                      text:
                                                          'กรุณากรอกรหัสบัตรประจำตัวให้ถูกต้อง',
                                                      type:
                                                          QuickAlertType.error,
                                                      confirmBtnText: 'ตกลง',
                                                      confirmBtnColor:
                                                          Colors.red.shade900,
                                                    );
                                                    return;
                                                  }
                                                  if (contactNumberController
                                                          .text.length !=
                                                      10) {
                                                    QuickAlert.show(
                                                      context: context,
                                                      title:
                                                          'เบอร์ติดต่อไม่ถูกต้อง',
                                                      text:
                                                          'กรุณากรอกเบอร์ติดต่อให้ถูกต้อง',
                                                      type:
                                                          QuickAlertType.error,
                                                      confirmBtnText: 'ตกลง',
                                                      confirmBtnColor:
                                                          Colors.red.shade900,
                                                    );
                                                    return;
                                                  }
                                                  //regex ตรวจสอบเบอร์โทร
                                                  if (!isThaiPhoneNumber(
                                                      contactNumberController
                                                          .text)) {
                                                    QuickAlert.show(
                                                      context: context,
                                                      title:
                                                          'เบอร์ติดต่อไม่ถูกต้อง',
                                                      text:
                                                          'กรุณากรอกเบอร์ติดต่อให้ถูกต้อง',
                                                      type:
                                                          QuickAlertType.error,
                                                      confirmBtnText: 'ตกลง',
                                                      confirmBtnColor:
                                                          Colors.red.shade900,
                                                    );
                                                    return;
                                                  }

                                                  bool isRelativeExist =
                                                      await checkRelative(
                                                          relativeIDController
                                                              .text);
                                                  print(
                                                      "isRelativeExist: $isRelativeExist");
                                                  setState(() {
                                                    if (relativeData.length ==
                                                        0) {
                                                      relativeData.add({
                                                        'relativeID':
                                                            relativeIDstr,
                                                        'relativeName':
                                                            relativeNameController
                                                                .text,
                                                        'contactNumber':
                                                            contactNumberController
                                                                .text,
                                                        'relativeIDCARD':
                                                            relativeIDController
                                                                .text,
                                                      });
                                                      relativeIDController
                                                          .clear();
                                                      relativeNameController
                                                          .clear();
                                                      contactNumberController
                                                          .clear();
                                                      relativeIDstr = '';
                                                      Navigator.pop(context);
                                                    } else {
                                                      print(
                                                          'relativeDatax: $relativeData');
                                                      //เช็ค relativeID ซ้ำ
                                                      for (var i = 0;
                                                          i <
                                                              relativeData
                                                                  .length;
                                                          i++) {
                                                        if (relativeData[i][
                                                                'relativeIDCARD'] ==
                                                            relativeIDController
                                                                .text) {
                                                          print(
                                                              'รหัสบัตรประจำตัวซ้ำ');
                                                          QuickAlert.show(
                                                            context: context,
                                                            title:
                                                                'รหัสบัตรประจำตัวซ้ำ',
                                                            text:
                                                                'รหัสบัตรประจำตัวนี้ถูกใช้ไปแล้ว',
                                                            type: QuickAlertType
                                                                .error,
                                                            confirmBtnText:
                                                                'ตกลง',
                                                            confirmBtnColor:
                                                                Colors.red
                                                                    .shade900,
                                                          );
                                                          return;
                                                        }
                                                      }
                                                      relativeData.add({
                                                        'relativeID':
                                                            relativeIDstr,
                                                        'relativeName':
                                                            relativeNameController
                                                                .text,
                                                        'contactNumber':
                                                            contactNumberController
                                                                .text,
                                                        'relativeIDCARD':
                                                            relativeIDController
                                                                .text,
                                                      });

                                                      Navigator.pop(context);
                                                      insert_old_relative_data(
                                                          relativeIDstr,
                                                          widget.old_id,
                                                          contactNumberController
                                                              .text);
                                                      relativeIDController
                                                          .clear();
                                                      relativeNameController
                                                          .clear();
                                                      contactNumberController
                                                          .clear();
                                                      relativeIDstr = '';
                                                    }

                                                    // Navigator.pop(context);
                                                  });
                                                  print(relativeData);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  minimumSize:
                                                      Size(double.infinity, 50),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  foregroundColor: Colors.white,
                                                  backgroundColor: Colors.green,
                                                ),
                                                child: Text(
                                                  'เพิ่ม',
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: -100,
                                    child: Image.asset(
                                        "assets/images/app_logoxxx.png",
                                        width: 170,
                                        height: 170),
                                  ),
                                  Positioned(
                                    right: -10,
                                    top: 0,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Icon(Icons.close),
                                      style: ElevatedButton.styleFrom(
                                        shape: CircleBorder(),
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        minimumSize: Size(30, 30),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.person_add),
                  label: Text('เพิ่มญาติ'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
              if (relativeData.length > 0)
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: relativeData.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(
                              'รหัสบัตรประจำตัว: ${relativeData[index]['relativeIDCARD']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'ชื่อ: ${relativeData[index]['relativeName']}'),
                              Text(
                                  'เบอร์ติดต่อ: ${relativeData[index]['contactNumber']}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red.shade900,
                            ),
                            onPressed: () async {
                              // setState(() {
                              //   print(relativeIDList[index]);
                              //   // relativeData.removeAt(index);
                              //   deleteOldrelative(relativeIDList[index]);
                              // });
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.confirm,
                                title: 'ยืนยันการลบข้อมูล',
                                text: 'คุณต้องการที่จะลบข้อมูลหรือไม่?',
                                showConfirmBtn: true,
                                confirmBtnText: 'ใช่',
                                confirmBtnColor: Colors.red,
                                cancelBtnText: 'ไม่',
                                onConfirmBtnTap: () async {
                                  Navigator.of(context).pop();
                                  showLoading('กำลังลบข้อมูล...');
                                  deleteOldrelative(relativeIDList[index]);
                                  // เรียกใช้งานฟังก์ชัน
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Container(
              //   margin: EdgeInsets.all(10),
              //   child: TextFormField(
              //     controller: relativeID,
              //     readOnly: true,
              //     decoration: const InputDecoration(
              //       border: OutlineInputBorder(),
              //       labelText: 'บัตรประจำตัว(ญาติ)...',
              //     ),
              //   ),
              // ),
              // Container(
              //   margin: EdgeInsets.all(10),
              //   child: TextFormField(
              //     controller: relativeName,
              //     decoration: const InputDecoration(
              //       border: OutlineInputBorder(),
              //       labelText: 'ชื่อ(ญาติ)...',
              //     ),
              //   ),
              // ),
              // Container(
              //   margin: EdgeInsets.all(10),
              //   child: TextFormField(
              //     controller: contactNumber,
              //     decoration: const InputDecoration(
              //       border: OutlineInputBorder(),
              //       labelText: 'เบอร์ติดต่อ(ญาติ)...',
              //     ),
              //   ),
              // ),
              // Container(
              //   margin: EdgeInsets.all(10),
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       QuickAlert.show(
              //         context: context,
              //         type: QuickAlertType.confirm,
              //         title: 'ยืนยันการอัพเดทข้อมูล',
              //         text: 'คุณต้องการที่จะอัพเดทข้อมูลหรือไม่?',
              //         showConfirmBtn: true,
              //         confirmBtnText: 'ใช่',
              //         confirmBtnColor: Colors.green,
              //         cancelBtnText: 'ไม่',
              //         onConfirmBtnTap: () {
              //           Navigator.of(context).pop(); // ปิด AlertDialog
              //           updaterecord(); // เรียกใช้งานฟังก์ชัน
              //         },
              //       );
              //       // showDialog(
              //       //   context: context,
              //       //   builder: (BuildContext context) {
              //       //     return AlertDialog(
              //       //       title: Text('ยืนยันการอัพเดทข้อมูล'),
              //       //       content: Text('คุณต้องการที่จะอัพเดทข้อมูลหรือไม่?'),
              //       //       actions: <Widget>[
              //       //         TextButton(
              //       //           onPressed: () async {
              //       //             Navigator.of(context).pop(); // ปิด AlertDialog
              //       //             updaterecord(); // เรียกใช้งานฟังก์ชัน updaterecord() เมื่อยืนยัน
              //       //             //กลับไปหน้าแสดงข้อมูล
              //       //           },
              //       //           child: Text('ใช่'),
              //       //         ),
              //       //         TextButton(
              //       //           onPressed: () {
              //       //             Navigator.of(context).pop(); // ปิด AlertDialog
              //       //           },
              //       //           child: Text('ไม่'),
              //       //         ),
              //       //       ],
              //       //     );
              //       //   },
              //       // );
              //     },
              //     child: Text('แก้ไขข้อมูล'),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.white,
              //       foregroundColor: Colors.green,
              //       side: BorderSide(color: Colors.green, width: 2),
              //       padding: EdgeInsets.all(10),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10),
              //       ),
              //       textStyle: TextStyle(
              //         fontSize: 20,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

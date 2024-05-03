import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_5/relative/view_relative.dart';
import 'package:flutter_application_5/view_main.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/quickalert.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Insert_old extends StatefulWidget {
  const Insert_old({Key? key}) : super(key: key);

  @override
  State<Insert_old> createState() => _Insert_oldState();
}

class _Insert_oldState extends State<Insert_old> {
  List userdata = [];

  TextEditingController loraController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController medicalConditionController = TextEditingController();
  TextEditingController relativeIDController = TextEditingController();
  TextEditingController relativeNameController = TextEditingController();
  List<TextEditingController> relativeNameControllerList = [];
  TextEditingController contactNumberController = TextEditingController();
  List<Map<String, String>> relativeData = [];
  bool ischeckIDCARD = false;
  String relativeID = '';

  String? selectedGender;

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
            relativeID = jsonData['data']['user_ID'].toString();
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

  Future<bool> checkLora() async {
    final lora = loraController.text;
    try {
      showLoading('กำลังตรวจสอบข้อมูล...');
      String url =
          'https://project-old.000webhostapp.com/User_API/user_rest.php?checkOldLoraID=$lora';
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print(jsonData);
        if (jsonData['status'] == 'success') {
          Navigator.of(context).pop();
          return true;
        } else {
          Navigator.of(context).pop();
          return false;
        }
      }
    } catch (e) {
      print(e);
    }
    return false;
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

  Future<void> inserrecordold() async {
    if (loraController.text.isEmpty ||
        idController.text.isEmpty ||
        nameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        addressController.text.isEmpty ||
        ageController.text.isEmpty ||
        selectedGender == null ||
        medicalConditionController.text.isEmpty) {
      QuickAlert.show(
        context: context,
        title: 'ข้อมูลไม่ครบถ้วน',
        text: 'กรุณากรอกข้อมูลให้ครบถ้วน',
        type: QuickAlertType.error,
        confirmBtnText: 'ตกลง',
        confirmBtnColor: Colors.red.shade900,
      );
      return;
    }
    if (!validateThaiID(idController.text)) {
      QuickAlert.show(
        context: context,
        title: 'รหัสบัตรประจำตัวไม่ถูกต้อง',
        text: 'กรุณากรอกรหัสบัตรประจำตัวให้ถูกต้อง',
        type: QuickAlertType.error,
        confirmBtnText: 'ตกลง',
        confirmBtnColor: Colors.red.shade900,
      );
      return;
    }
    if (await checkLora()) {
      QuickAlert.show(
        context: context,
        title: 'รหัสอุปกรณ์ซ้ำ',
        text: 'รหัสอุปกรณ์นี้ถูกใช้ไปแล้ว',
        type: QuickAlertType.error,
        confirmBtnText: 'ตกลง',
        confirmBtnColor: Colors.red.shade900,
      );
      return;
    }
    if (relativeData.length == 0) {
      QuickAlert.show(
        context: context,
        title: 'ไม่พบข้อมูลญาติ',
        text: 'กรุณาเพิ่มข้อมูลญาติก่อนบันทึกข้อมูล',
        type: QuickAlertType.error,
        confirmBtnText: 'ตกลง',
        confirmBtnColor: Colors.red.shade900,
      );
      return;
    }
    print("relativeData: $relativeData");

    try {
      showLoading('กำลังบันทึกข้อมูล...');
      String url =
          'https://project-old.000webhostapp.com/User_API/user_rest.php';
      var response = await http.post(Uri.parse(url), body: {
        "action": "insertOld",
        "loraid": loraController.text,
        "id": idController.text,
        "name": nameController.text,
        "lastName": lastNameController.text,
        "address": addressController.text,
        "age": ageController.text,
        "gender": selectedGender!,
        "medicalCondition": medicalConditionController.text,
        "relativeData": jsonEncode(relativeData),
      });
      if (response.statusCode == 200) {
        var jsonData = await jsonDecode(response.body);
        print("insertOld: ${response.body}");
        if (jsonData['status'] == 'success') {
          Navigator.of(context).pop();
          QuickAlert.show(
            context: context,
            title: 'บันทึกข้อมูลสำเร็จ',
            text: 'ข้อมูลของคุณถูกบันทึกเรียบร้อยแล้ว',
            type: QuickAlertType.success,
            confirmBtnText: 'ตกลง',
            confirmBtnColor: Colors.green.shade900,
            onConfirmBtnTap: () async {
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              String user_idcard = prefs.getString('user_idcard') ?? '';
              if (user_idcard == 'admin') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ViewOld()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ViewOldRela()),
                );
              }
            },
          );
        } else {
          Navigator.of(context).pop();
          QuickAlert.show(
            context: context,
            title: 'บันทึกข้อมูลไม่สำเร็จ',
            text: 'กรุณาลองใหม่อีกครั้ง',
            type: QuickAlertType.error,
            confirmBtnText: 'ตกลง',
            confirmBtnColor: Colors.red.shade900,
          );
        }
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print(e);
    }

    //===================================================================================================
    // try {
    //   var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    //   var request = http.Request(
    //       'POST',
    //       Uri.parse(
    //           'http://project-old.000webhostapp.com/Old_API/old_insert.php'));
    //   request.bodyFields = {
    //     "loraid": loraController.text,
    //     "id": idController.text,
    //     "name": nameController.text,
    //     "lastName": lastNameController.text,
    //     "address": addressController.text,
    //     "age": ageController.text,
    //     "gender": selectedGender!,
    //     "medicalCondition": medicalConditionController.text,
    //     "relativeID": relativeIDController.text,
    //     "relativeName": relativeNameController.text,
    //     "contactNumber": contactNumberController.text
    //   };
    //   request.headers.addAll(headers);

    //   http.StreamedResponse response = await request.send();

    //   if (response.statusCode == 200) {
    //     print(await response.stream.bytesToString());
    //     final SharedPreferences prefs = await SharedPreferences.getInstance();
    //     String user_idcard = prefs.getString('user_idcard')!;
    //     QuickAlert.show(
    //       context: context,
    //       title: 'บันทึกข้อมูลสำเร็จ',
    //       text: 'ข้อมูลของคุณถูกบันทึกเรียบร้อยแล้ว',
    //       type: QuickAlertType.success,
    //       confirmBtnText: 'ตกลง',
    //       confirmBtnColor: Colors.green.shade900,
    //       onConfirmBtnTap: () {
    //         if (user_idcard == 'admin') {
    //           Navigator.pushReplacement(
    //             context,
    //             MaterialPageRoute(builder: (context) => ViewOld()),
    //           );
    //         } else {
    //           Navigator.pushReplacement(
    //             context,
    //             MaterialPageRoute(builder: (context) => ViewOldRela()),
    //           );
    //         }
    //       },
    //     );
    //   } else {
    //     print(response.reasonPhrase);
    //   }
    // } catch (e) {
    //   print(e);
    // }
  }

  // Future<void> _getImage() async {
  //   final picker = ImagePicker();
  //   // ignore: deprecated_member_use
  //   final pickedFile = await picker.getImage(source: ImageSource.gallery);

  //   setState(() {
  //     if (pickedFile != null) {
  //       _imageFile = File(pickedFile.path);
  //     } else {
  //       print('No image selected.');
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ลงทะเบียน'),
      ),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: loraController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      labelText: 'รหัสอุปกรณ์...',
                      prefixIcon: Icon(Icons.perm_identity),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: idController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      labelText: 'บัตรประจำตัว...',
                      prefixIcon: Icon(Icons.perm_identity),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      labelText: 'ชื่อ...',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      labelText: 'นามสกุล...',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      labelText: 'ที่อยู่...',
                      prefixIcon: Icon(Icons.home),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: ageController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      labelText: 'อายุ...',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      labelText: 'เพศ...',
                      prefixIcon: Icon(Icons.wc),
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
                  SizedBox(height: 10),
                  TextFormField(
                    controller: medicalConditionController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      labelText: 'โรคประจำตัว...',
                      prefixIcon: Icon(Icons.local_hospital),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
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
                                              labelText:
                                                  'บัตรประจำตัว(ญาติ)...',
                                              labelStyle: TextStyle(
                                                  color: Colors.black),
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
                                                        title:
                                                            'ข้อมูลไม่ครบถ้วน',
                                                        text:
                                                            'กรุณากรอกข้อมูลให้ครบถ้วน',
                                                        type: QuickAlertType
                                                            .error,
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
                                                        type: QuickAlertType
                                                            .error,
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
                                                      type: QuickAlertType
                                                          .loading,
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
                                                        title:
                                                            'ไม่พบข้อมูลญาติ',
                                                        text:
                                                            'ไม่พบข้อมูลญาติในระบบ',
                                                        type: QuickAlertType
                                                            .error,
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
                                                      type: QuickAlertType
                                                          .success,
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
                                              side: BorderSide(
                                                  color: Colors.blue),
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
                                                    border:
                                                        OutlineInputBorder(),
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
                                                    border:
                                                        OutlineInputBorder(),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    labelText:
                                                        'เบอร์ติดต่อ(ญาติ)...',
                                                    labelStyle: TextStyle(
                                                        color: Colors.black),
                                                    prefixIcon:
                                                        Icon(Icons.phone),
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
                                                        title:
                                                            'ข้อมูลไม่ครบถ้วน',
                                                        text:
                                                            'กรุณากรอกข้อมูลให้ครบถ้วน',
                                                        type: QuickAlertType
                                                            .error,
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
                                                        type: QuickAlertType
                                                            .error,
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
                                                        type: QuickAlertType
                                                            .error,
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
                                                        type: QuickAlertType
                                                            .error,
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
                                                              relativeID,
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
                                                        relativeID = '';
                                                        Navigator.pop(context);
                                                      } else {
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
                                                            QuickAlert.show(
                                                              context: context,
                                                              title:
                                                                  'รหัสบัตรประจำตัวซ้ำ',
                                                              text:
                                                                  'รหัสบัตรประจำตัวนี้ถูกใช้ไปแล้ว',
                                                              type:
                                                                  QuickAlertType
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
                                                              relativeID,
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
                                                        relativeID = '';
                                                        Navigator.pop(context);
                                                      }
                                                    });
                                                    print(relativeData);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    minimumSize: Size(
                                                        double.infinity, 50),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    foregroundColor:
                                                        Colors.white,
                                                    backgroundColor:
                                                        Colors.green,
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
                  SizedBox(height: 10),
                  //show relative
                  if (relativeData.length > 0)
                    ListView.builder(
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
                              onPressed: () {
                                setState(() {
                                  relativeData.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("ยืนยันการบันทึกข้อมูล"),
                                content: Text(
                                    "ข้อมูลของคุณอาจถูกเปิดเผยแก่บุคคลอื่น\nคุณต้องการจะยืนยันที่จะบันทึกข้อมูลหรือไม่?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      inserrecordold();
                                      // Navigator.pushReplacement(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //       builder: (context) => ViewOld()),
                                      // );
                                    },
                                    child: Text("ยืนยัน"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("ยกเลิก"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('ยืนยัน'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("ยกเลิก"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

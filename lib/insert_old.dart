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
  TextEditingController contactNumberController = TextEditingController();

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

  Future<void> inserrecordold() async {
    if (loraController.text.isEmpty ||
        idController.text.isEmpty ||
        nameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        addressController.text.isEmpty ||
        ageController.text.isEmpty ||
        selectedGender == null ||
        medicalConditionController.text.isEmpty ||
        relativeIDController.text.isEmpty ||
        relativeNameController.text.isEmpty ||
        contactNumberController.text.isEmpty) {
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
    if (!validateThaiID(relativeIDController.text)) {
      QuickAlert.show(
        context: context,
        title: 'รหัสบัตรประจำตัว(ญาติ)ไม่ถูกต้อง',
        text: 'กรุณากรอกรหัสบัตรประจำตัว(ญาติ)ให้ถูกต้อง',
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
    try {
      var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
      var request = http.Request(
          'POST',
          Uri.parse(
              'http://project-old.000webhostapp.com/Old_API/old_insert.php'));
      request.bodyFields = {
        "loraid": loraController.text,
        "id": idController.text,
        "name": nameController.text,
        "lastName": lastNameController.text,
        "address": addressController.text,
        "age": ageController.text,
        "gender": selectedGender!,
        "medicalCondition": medicalConditionController.text,
        "relativeID": relativeIDController.text,
        "relativeName": relativeNameController.text,
        "contactNumber": contactNumberController.text
      };
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        String user_idcard = prefs.getString('user_idcard')!;
        QuickAlert.show(
          context: context,
          title: 'บันทึกข้อมูลสำเร็จ',
          text: 'ข้อมูลของคุณถูกบันทึกเรียบร้อยแล้ว',
          type: QuickAlertType.success,
          confirmBtnText: 'ตกลง',
          confirmBtnColor: Colors.green.shade900,
          onConfirmBtnTap: () {
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
        print(response.reasonPhrase);
      }
    } catch (e) {
      print(e);
    }
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
                TextFormField(
                  controller: relativeIDController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    labelText: 'บัตรประจำตัว(ญาติ)...',
                    prefixIcon: Icon(Icons.add_card_rounded),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: relativeNameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    labelText: 'ชื่อ(ญาติ)...',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: contactNumberController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    labelText: 'เบอร์ติดต่อ(ญาติ)...',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                SizedBox(height: 10),
                // ส่วนเลือกรูปภาพ
                // ElevatedButton(
                //   onPressed: _getImage,
                //   child: Text('เลือกรูปภาพ'),
                // ),
                SizedBox(height: 10),
                // ปุ่มยืนยัน
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
    );
  }
}

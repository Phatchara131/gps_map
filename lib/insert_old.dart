import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_5/view_main.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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
  TextEditingController genderController = TextEditingController();
  TextEditingController medicalConditionController = TextEditingController();
  TextEditingController relativeIDController = TextEditingController();
  TextEditingController relativeNameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();

  late File _imageFile;

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

  Future<void> inserrecordold() async {
    if (loraController.text != "" ||
        idController.text != "" ||
        nameController.text != "" ||
        lastNameController.text != "" ||
        addressController.text != "" ||
        ageController.text != "" ||
        genderController.text != "" ||
        medicalConditionController.text != "" ||
        relativeIDController.text != "" ||
        relativeNameController.text != "" ||
        contactNumberController.text != "" ||
        _imageFile != null) {
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
        "gender": genderController.text,
        "medicalCondition": medicalConditionController.text,
        "relativeID": relativeIDController.text,
        "relativeName": relativeNameController.text,
        "contactNumber": contactNumberController.text
      };
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
      } else {
        print(response.reasonPhrase);
      }
    } else {
      print("Please fill all fields and select an image");
    }
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    // ignore: deprecated_member_use
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

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
                TextFormField(
                  controller: genderController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    labelText: 'เพศ...',
                    prefixIcon: Icon(Icons.wc),
                  ),
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
                                  "คุณต้องการจะยืนยันที่จะบันทึกข้อมูลหรือไม่?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    inserrecordold();
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ViewOld()),
                                    );
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

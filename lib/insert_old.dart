import 'dart:convert';
import 'dart:io';
import 'package:flutter_application_5/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_5/view_old.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() => runApp(MaterialApp(
      title: "App",
      // home: insert_old(),
      home: const View_old(),
    ));

class insert_old extends StatefulWidget {
  const insert_old({Key? key}) : super(key: key);

  @override
  State<insert_old> createState() => _insert_oldState();
}

class _insert_oldState extends State<insert_old> {
  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController medicalConditionController = TextEditingController();
  TextEditingController relativeNameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  late File _imageFile;

  Future<void> inserrecord() async {
    if (idController.text != "" ||
        nameController.text != "" ||
        lastNameController.text != "" ||
        addressController.text != "" ||
        ageController.text != "" ||
        genderController.text != "" ||
        medicalConditionController.text != "" ||
        relativeNameController.text != "" ||
        contactNumberController.text != "" ||
        _imageFile != null) {
      try {
        String uri = "http://10.0.2.2/Old_API/old_insert.php";
        var request = http.MultipartRequest('POST', Uri.parse(uri));
        request.fields['id'] = idController.text;
        request.fields['name'] = nameController.text;
        request.fields['lastName'] = lastNameController.text;
        request.fields['address'] = addressController.text;
        request.fields['age'] = ageController.text;
        request.fields['gender'] = genderController.text;
        request.fields['medicalCondition'] = medicalConditionController.text;
        request.fields['relativeName'] = relativeNameController.text;
        request.fields['contactNumber'] = contactNumberController.text;
        request.files
            .add(await http.MultipartFile.fromPath('image', _imageFile.path));
        var res = await request.send();
        if (res.statusCode == 200) {
          print("Record Inserted");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => View_old()),
          );
        } else {
          print("Some issue");
        }
      } catch (e) {
        print(e);
      }
    } else {
      print("Please fill all fields and select an image");
    }
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextFormField(
                controller: idController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'รหัสประจำตัว...',
                  prefixIcon: Icon(Icons.perm_identity),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'ชื่อ...',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'นามสกุล...',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'ที่อยู่...',
                  prefixIcon: Icon(Icons.home),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: ageController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'อายุ...',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: genderController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'เพศ...',
                  prefixIcon: Icon(Icons.wc),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: medicalConditionController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'โรคประจำตัว...',
                  prefixIcon: Icon(Icons.local_hospital),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: relativeNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'ชื่อ(ญาติ)...',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: contactNumberController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'เบอร์ติดต่อ(ญาติ)...',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              SizedBox(height: 10),
              // ส่วนเลือกรูปภาพ
              ElevatedButton(
                onPressed: _getImage,
                child: Text('เลือกรูปภาพ'),
              ),
              SizedBox(height: 10),
              // ปุ่มยืนยัน
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      inserrecord();
                    },
                    child: Text('ยืนยัน'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => View_old()),
                      );
                    },
                    child: Text("ยกเลิก"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_5/view_old.dart';
import 'package:http/http.dart' as http;

class Update_old extends StatefulWidget {
  String old_id;
  String userId;
  String fname;
  String lname;
  String address;
  String age;
  String gender;
  String medicalCondition;
  String relativeName;
  String contactNumber;

  Update_old(
      this.old_id,
      this.userId,
      this.fname,
      this.lname,
      this.address,
      this.age,
      this.gender,
      this.medicalCondition,
      this.relativeName,
      this.contactNumber);

  @override
  State<Update_old> createState() => _Update_oldState();
}

class _Update_oldState extends State<Update_old> {
  TextEditingController userId = TextEditingController();
  TextEditingController fname = TextEditingController();
  TextEditingController lname = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController age = TextEditingController();
  TextEditingController gender = TextEditingController();
  TextEditingController medicalCondition = TextEditingController();
  TextEditingController relativeName = TextEditingController();
  TextEditingController contactNumber = TextEditingController();

  Future<void> updaterecord() async {
    try {
      String uri = "http://10.0.2.2/Old_API/old_update.php";
      var res = await http.post(Uri.parse(uri), body: {
        "old_ID": widget.old_id,
        "old_userID": userId.text,
        "old_fname": fname.text,
        "old_lname": lname.text,
        "old_address": address.text,
        "old_age": age.text,
        "old_sex": gender.text,
        "old_disease": medicalCondition.text,
        "old_Cname": relativeName.text,
        "old_Ctel": contactNumber.text,
      });
      var response = jsonDecode(res.body);
      if (response["success"] == "true") {
        print("update");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const View_old()),
        );
      } else {
        print("some issue");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    userId.text = widget.userId;
    fname.text = widget.fname;
    lname.text = widget.lname;
    address.text = widget.address;
    age.text = widget.age;
    gender.text = widget.gender;
    medicalCondition.text = widget.medicalCondition;
    relativeName.text = widget.relativeName;
    contactNumber.text = widget.contactNumber;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Record")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: TextFormField(
                controller: userId,
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
              child: TextFormField(
                controller: gender,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'เพศ...',
                ),
              ),
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
            Container(
              margin: EdgeInsets.all(10),
              child: TextFormField(
                controller: relativeName,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'ชื่อ(ญาติ)...',
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: TextFormField(
                controller: contactNumber,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'เบอร์ติดต่อ(ญาติ)...',
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  updaterecord();
                },
                child: Text('Update Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

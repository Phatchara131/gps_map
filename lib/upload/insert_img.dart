import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class Insert_img extends StatefulWidget {
  const Insert_img({super.key});

  @override
  State<Insert_img> createState() => _Insert_imgState();
}

class _Insert_imgState extends State<Insert_img> {
  TextEditingController caption = TextEditingController();

  File? imagepath;
  String? imagename;
  String? imagedata;

  ImagePicker imagePicker new ImagePicker();

  Future<void> getImage() async {
    var getimage = await imagePicker pickImage(source:ImageSource.gallery);

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Upload Image'),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 20,
            ),

            TextFormField(
              controller: caption,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Enter the Caption')),
            ),
            SizedBox(
              height: 20,
            ),
            // Image.file(file),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  getImage();
                },
                child: Text('Chosse Image')),
            ElevatedButton(onPressed: () {}, child: Text('Upload')),
          ],
        ),
      ),
    );
  }
}

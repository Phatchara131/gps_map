import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageUpload extends StatefulWidget {
  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  late File _imageFile;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadImage() async {
    final uri = Uri.parse("http://your_domain/upload_image.php");
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', _imageFile.path));
    final response = await request.send();
    if (response.statusCode == 200) {
      print("Image uploaded successfully");
    } else {
      print("Failed to upload image");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Upload"),
      ),
      body: Center(
        child: _imageFile == null
            ? Text('No image selected.')
            : Image.file(_imageFile),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _pickImage,
            tooltip: 'Pick Image',
            child: Icon(Icons.add_a_photo),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _uploadImage,
            tooltip: 'Upload Image',
            child: Icon(Icons.cloud_upload),
          ),
        ],
      ),
    );
  }
}

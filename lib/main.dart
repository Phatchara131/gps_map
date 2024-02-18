import 'dart:convert';

import 'package:flutter_application_5/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// void main() {
//   runApp(const Project());
// }

void main() => runApp(MaterialApp(
      title: "App",
      home: LoginPage(),
      // home: ImageUpload(),
      // home: Project(),
    ));

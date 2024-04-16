import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_5/menu/drawer.dart';
import 'package:flutter_application_5/people/update_people.dart';
import 'package:flutter_application_5/update_old.dart';
import 'package:http/http.dart' as http;

class ViewOld_people extends StatefulWidget {
  const ViewOld_people({Key? key}) : super(key: key);

  @override
  State<ViewOld_people> createState() => _ViewOld_peopleState();
}

class _ViewOld_peopleState extends State<ViewOld_people> {
  List userdata = [];
  bool isDarkModeEnabled = false;
  bool isCardView = true;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    getrecord();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("")),
      // สีดำโปงใส
      // drawer: CustomDrawer(title: 'เมนู'),
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
        child: RefreshIndicator(
          child: isCardView ? _buildCardView() : _buildTableView(),
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2), () => getrecord());
          },
        ),
      ),
    );
  }

  Widget _buildCardView() {
    return ListView.builder(
      itemCount: userdata.length,
      itemBuilder: (context, index) {
        if (searchText.isNotEmpty &&
            !userdata[index]["old_fname"]
                .toString()
                .toLowerCase()
                .contains(searchText.toLowerCase())) {
          return Container();
        }
        return Card(
          color: isDarkModeEnabled ? Colors.grey[800] : Colors.white,
          margin: EdgeInsets.all(10),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Update_people(
                    userdata[index]["old_ID"],
                    userdata[index]["old_loraID"],
                    userdata[index]["old_userID"],
                    userdata[index]["old_fname"],
                    userdata[index]["old_lname"],
                    userdata[index]["old_address"],
                    userdata[index]["old_age"],
                    userdata[index]["old_sex"],
                    userdata[index]["old_disease"],
                    userdata[index]["old_relativeID"],
                    userdata[index]["old_Cname"],
                    userdata[index]["old_Ctel"],
                  ),
                ),
              );
            },
            leading: Icon(
              CupertinoIcons.heart,
              color: Colors.red,
            ),
            title: Text(
              userdata[index]["old_fname"],
              style: TextStyle(
                  color: isDarkModeEnabled ? Colors.white : Colors.black),
            ),
            subtitle: Text(
              userdata[index]["old_lname"],
              style: TextStyle(
                  color: isDarkModeEnabled ? Colors.white : Colors.black),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableView() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('First Name')),
            DataColumn(label: Text('Last Name')),
            DataColumn(label: Text('Age')),
          ],
          rows: userdata.map((user) {
            return DataRow(cells: [
              DataCell(Text(user["old_ID"].toString())),
              DataCell(Text(user["old_fname"].toString())),
              DataCell(Text(user["old_lname"].toString())),
              DataCell(Text(user["old_age"].toString())),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Future<void> delrecord(String id) async {
    try {
      String uri =
          "https://project-old.000webhostapp.com/Old_API/old_delete.php";
      var res = await http.post(Uri.parse(uri), body: {"id": id});
      var response = jsonDecode(res.body);
      if (response["success"] == "true") {
        print(userdata);
        print("record deleted");
        getrecord();
      } else {
        print("some issue");
      }
    } catch (e) {
      print(e);
      print("Error");
    }
  }

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
}

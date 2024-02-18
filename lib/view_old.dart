import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_5/insert_old.dart';
import 'package:flutter_application_5/update_old.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:longdo_maps_api3_flutter/longdo_maps_api3_flutter.dart';
import 'package:geolocator/geolocator.dart';

class View_old extends StatefulWidget {
  const View_old({Key? key}) : super(key: key);

  @override
  State<View_old> createState() => _View_oldState();
}

class _View_oldState extends State<View_old> {
  List userdata = [];
  bool loginError = false;
  bool isDarkModeEnabled = false;
  bool isCardView = true;
  String searchText = '';
  final map = GlobalKey<LongdoMapState>();
  final GlobalKey<ScaffoldMessengerState> messenger =
      GlobalKey<ScaffoldMessengerState>();
  //-----map-----
  static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  @override
  void initState() {
    super.initState();
    getrecord();
    print(userdata);
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> delrecord(String id) async {
    try {
      String uri = "http://10.0.2.2/Old_API/old_delete.php";
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
      String uri = "http://10.0.2.2/Old_API/old_view.php";
      var response = await http.post(Uri.parse(uri));
      setState(() {
        userdata = jsonDecode(response.body);
        print(userdata);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    var localtion = await Geolocator.getCurrentPosition();
    print("lat: ${localtion.latitude} lon: ${localtion.longitude}");
    return await Geolocator.getCurrentPosition();
  }

  void move_location() {
    map.currentState?.call("location", args: [
      {
        "lon": _longitudeController.text,
        "lat": _latitudeController.text,
      }
    ]);
  }

  @override
  Widget build(BuildContext context) {
    var marker;
    var markerMap = {};
    var isAddSourceAnimatedRouting = false;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: isDarkModeEnabled ? Colors.grey[900] : Colors.blue,
          bottom: TabBar(
            tabs: [
              Tab(text: 'View'),
              Tab(text: 'Map'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => insert_old()),
                );
              },
              icon: Icon(
                Icons.add,
                color: Color.fromARGB(255, 0, 38, 255),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  isDarkModeEnabled = !isDarkModeEnabled;
                });
              },
              icon: Icon(
                isDarkModeEnabled ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10),
            IconButton(
              onPressed: () {
                setState(() {
                  isCardView = !isCardView;
                });
              },
              icon: Icon(
                isCardView ? Icons.table_chart : Icons.view_module,
                color: Colors.white,
              ),
            ),
          ],
          title: TextField(
            onChanged: (value) {
              setState(() {
                searchText = value;
              });
            },
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              border: InputBorder.none,
            ),
          ),
        ),
        body: TabBarView(
          children: [
            isCardView
                ? ListView.builder(
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
                        color:
                            isDarkModeEnabled ? Colors.grey[800] : Colors.white,
                        margin: EdgeInsets.all(10),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Update_old(
                                  userdata[index]["old_ID"],
                                  userdata[index]["old_userID"],
                                  userdata[index]["old_fname"],
                                  userdata[index]["old_lname"],
                                  userdata[index]["old_address"],
                                  userdata[index]["old_age"],
                                  userdata[index]["old_sex"],
                                  userdata[index]["old_disease"],
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
                                color: isDarkModeEnabled
                                    ? Colors.white
                                    : Colors.black),
                          ),
                          subtitle: Text(
                            userdata[index]["old_lname"],
                            style: TextStyle(
                                color: isDarkModeEnabled
                                    ? Colors.white
                                    : Colors.black),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  delrecord(userdata[index]["old_ID"]);
                                },
                                icon: Icon(Icons.delete),
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : SingleChildScrollView(
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
                  ),
            Column(
              children: [
                Expanded(
                  flex: 3,
                  child: LongdoMapWidget(
                    apiKey: "556e31e859f72e9ec99600ae7135f479",
                    key: map,
                    eventName: [
                      JavascriptChannel(
                        name: "ready",
                        onMessageReceived: (message) {
                          var lay = map.currentState
                              ?.LongdoStatic("Layers", 'RASTER_POI');
                          if (lay != null) {
                            print("ready");
                            map.currentState
                                ?.call('Layers.setBase', args: [lay]);
                          }
                          // var marker = Longdo.LongdoObject(
                          //   "Marker",
                          //   args: [
                          //     {
                          //       "lon": 100.56,
                          //       "lat": 13.74,
                          //     },
                          //   ],
                          // );
                          // map.currentState
                          //     ?.call("Overlays.add", args: [marker]);
                          // var id = marker["\$id"];
                          // print(id);
                          // markerMap[id] = marker;
                          // marker["\$id"] = "TEST";
                          // id = marker["\$id"];
                          // print(id);
                          var latlon = _determinePosition();
                          print(latlon);
                          latlon.then((value) => {
                                setState(() {
                                  map.currentState?.call("location", args: [
                                    {
                                      "lon": value.longitude,
                                      "lat": value.latitude,
                                    }
                                  ]);
                                  var marker = Longdo.LongdoObject(
                                    "Marker",
                                    args: [
                                      {
                                        "lon": value.longitude,
                                        "lat": value.latitude,
                                      },
                                      {"draggable": true}
                                    ],
                                  );
                                  map.currentState
                                      ?.call("Overlays.add", args: [marker]);
                                  final id = marker["\$id"];
                                  markerMap[id] = marker;
                                })
                              });
                        },
                      ),
                      JavascriptChannel(
                        name: "click",
                        onMessageReceived: (message) {
                          var jsonObj = json.decode(message.message);
                          var lat = jsonObj['data']['lat'];
                          var lon = jsonObj['data']['lon'];
                          print("lat: $lat, lon: $lon");
                          // check type lat and lon
                          print(lat.runtimeType);
                          setState(() {
                            _latitudeController.text = lat.toStringAsFixed(6);
                            _longitudeController.text = lon.toStringAsFixed(6);
                          });
                          // var marker = Longdo.LongdoObject(
                          //   "Marker",
                          //   args: [
                          //     {
                          //       "lon": lon,
                          //       "lat": lat,
                          //     },
                          //     {"draggable": true}
                          //   ],
                          // );
                          // map.currentState
                          //     ?.call("Overlays.add", args: [marker]);

                          // final id = marker["\$id"];
                          // markerMap[id] = marker;
                        },
                      ),
                      JavascriptChannel(
                        name: "overlayClick",
                        onMessageReceived: (message) {
                          var jsonObj = json.decode(message.message);
                          map.currentState?.call("Overlays.remove",
                              args: [jsonObj["data"]]);
                          final id = jsonObj["data"]["\$id"];
                          markerMap.remove(id);
                        },
                      ),
                      JavascriptChannel(
                        name: "overlayDrop",
                        onMessageReceived: (message) async {
                          var obj = json.decode(message.message);
                          final location = await map.currentState
                              ?.objectCall(obj["data"], "location");
                          print(location);
                        },
                      ),
                    ],
                    options: {
                      // "ui": Longdo.LongdoStatic(
                      //   "UiComponent",
                      //   "None",
                      // )
                      // "zoom": 9
                      // "layer": Longdo.LongdoStatic("Layers", "POLITICAL")
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _latitudeController,
                                  decoration: InputDecoration(
                                    labelText: 'Latitude',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _longitudeController,
                                  decoration: InputDecoration(
                                    labelText: 'Longitude',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Handle confirm button pressed
                                  double latitude = double.tryParse(
                                          _latitudeController.text) ??
                                      0.0;
                                  double longitude = double.tryParse(
                                          _longitudeController.text) ??
                                      0.0;
                                  // Do something with latitude and longitude
                                  move_location();
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(70, 50),
                                ),
                                child: Text('Confirm'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Handle cancel button pressed
                                  _latitudeController.clear();
                                  _longitudeController.clear();
                                },
                                child: Text('Cancel'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Center(
            //   child: SingleChildScrollView(
            //     child: Padding(
            //       padding: const EdgeInsets.all(16.0),
            //       child: Column(
            //         children: [
            //           Card(
            //             child: SizedBox(
            //               height: 300,
            //               child:
            //               // child: GoogleMap(
            //               //   initialCameraPosition: CameraPosition(
            //               //     target: _pGooglePlex,
            //               //     zoom: 13,
            //               //   ),
            //               // ),
            //             ),
            //           ),
            //           SizedBox(height: 16),
            //           Row(
            //             children: [
            //               Expanded(
            //                 child: TextField(
            //                   controller: _latitudeController,
            //                   decoration: InputDecoration(
            //                     labelText: 'Latitude',
            //                     border: OutlineInputBorder(),
            //                   ),
            //                 ),
            //               ),
            //               SizedBox(width: 8),
            //               Expanded(
            //                 child: TextField(
            //                   controller: _longitudeController,
            //                   decoration: InputDecoration(
            //                     labelText: 'Longitude',
            //                     border: OutlineInputBorder(),
            //                   ),
            //                 ),
            //               ),
            //             ],
            //           ),
            //           SizedBox(height: 16),
            //           Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //             children: [
            //               ElevatedButton(
            //                 onPressed: () {
            //                   // Handle confirm button pressed
            //                   double latitude =
            //                       double.tryParse(_latitudeController.text) ??
            //                           0.0;
            //                   double longitude =
            //                       double.tryParse(_longitudeController.text) ??
            //                           0.0;
            //                   // Do something with latitude and longitude
            //                 },
            //                 child: Text('Confirm'),
            //               ),
            //               ElevatedButton(
            //                 onPressed: () {
            //                   // Handle cancel button pressed
            //                   _latitudeController.clear();
            //                   _longitudeController.clear();
            //                 },
            //                 child: Text('Cancel'),
            //               ),
            //             ],
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        backgroundColor: isDarkModeEnabled ? Colors.grey : Colors.white,
      ),
    );
  }
}

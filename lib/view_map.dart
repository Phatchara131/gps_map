import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_5/menu/drawer.dart';
import 'package:flutter_application_5/relative/view_relative.dart';
import 'package:flutter_application_5/view_main.dart';
import 'package:longdo_maps_api3_flutter/longdo_maps_api3_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapTab extends StatefulWidget {
  const MapTab({Key? key}) : super(key: key);

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final map = GlobalKey<LongdoMapState>();
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _areaController;
  int _selectedIndex = 0;
  String _selecteddevEui = '';
  Future<Map<String, dynamic>> authLoRa() async {
    try {
      String uri = "https://loraiot.cattelecom.com/portal/iotapi/auth/token";
      var res = await http.post(Uri.parse(uri),
          headers: {
            "Content-Type": "application/json",
          },
          body: json.encode({
            "username": "wivach ",
            "password": "BananaLavender14",
          }));
      if (res.statusCode == 200) {
        var data = json.decode(res.body);

        return data;
      } else {
        return {};
      }
    } catch (e) {
      print(e);
      return {};
    }
  }

  Future<Map<String, dynamic>> getOldData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_idcard = prefs.getString('user_idcard')!;
    // print(user_idcard);
    try {
      String url =
          'https://project-old.000webhostapp.com/User_API/user_rest.php?getUserOld_by_relativeID=$user_idcard';
      var res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        return data;
      } else {
        return {};
      }
    } catch (e) {
      print(e);
      return {};
    }
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

  String stringToHex(String text) {
    print(text);
    var bytes = utf8.encode(text); // Encode the text as UTF-8 bytes
    var hexString =
        bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return hexString;
  }

  Future<void> setDownlink(String access_token, String devEui) async {
    print(access_token);
    showLoading('กำลังส่งข้อมูล...');
    String hexdata = stringToHex(
        '${_latitudeController.text},${_longitudeController.text},${_areaController.text}');
    print(hexdata);
    try {
      String uri =
          "https://loraiot.cattelecom.com/portal/iotapi/core/devices/${devEui}/downlinkMessages";
      var res = await http.post(Uri.parse(uri),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $access_token",
          },
          body: json.encode({"payloadHex": hexdata, "targetPorts": "8"}));
      if (res.statusCode == 200) {
        print(res.body);
        var res_data = json.decode(res.body);
        Navigator.of(context).pop();
        if (res_data['status'] == 'QUEUED') {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'สำเร็จ',
            text: 'ส่งข้อมูลสำเร็จ',
            confirmBtnText: 'ตกลง',
            onConfirmBtnTap: () async {
              Navigator.of(context).pop();
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              String user_idcard = prefs.getString('user_idcard')!;
              if (user_idcard == 'admin') {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => ViewOld()),
                    (route) => false);
              } else {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => ViewOldRela()),
                    (route) => false);
              }
            },
          );
        } else {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'เกิดข้อผิดพลาด',
            text: 'ส่งข้อมูลไม่สำเร็จ',
            confirmBtnText: 'ตกลง',
          );
        }
        // Navigator.of(context).pop();
      } else {
        print("Downlink Failed");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> insertRecord() async {
    showLoading('กำลังโหลดข้อมูล...');
    Map<String, dynamic> auth = await authLoRa();
    print(auth['access_token']);
    Map<String, dynamic> oldData = await getOldData();
    print(oldData['data']);
    _selectedIndex = 0;
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Builder(
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  child: Container(
                    height: 300,
                    width: MediaQuery.of(context).size.height * 0.9,
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text(
                          'เลือกผู้สูงอายุที่ต้องการเพิ่มข้อมูล',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: oldData['data'].length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: double.infinity,
                                margin: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _selectedIndex ==
                                            oldData['data'][index]['old_ID']
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: ListTile(
                                  title: Text(
                                    oldData['data'][index]['old_fname'] +
                                        ' ' +
                                        oldData['data'][index]['old_lname'],
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    oldData['data'][index]['old_loraID'],
                                  ),
                                  onTap: () {
                                    print(oldData['data'][index]['old_ID']);
                                    setState(() {
                                      _selectedIndex =
                                          oldData['data'][index]['old_ID'];
                                      _selecteddevEui =
                                          oldData['data'][index]['old_loraID'];
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                if (_selectedIndex == 0) {
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    title: 'เกิดข้อผิดพลาด',
                                    text:
                                        'กรุณาเลือกผู้สูงอายุที่ต้องการเพิ่มข้อมูล',
                                    confirmBtnText: 'ตกลง',
                                  );
                                  return;
                                }
                                print(_selecteddevEui);
                                await setDownlink(
                                    auth['access_token'], _selecteddevEui);
                              },
                              child: Text('บันทึก'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('ยกเลิก'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ]
                              .expand((element) => [
                                    SizedBox(width: 10),
                                    element,
                                  ])
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );

    // oldData['data'].forEach((element) {
    //   print(element);
    // });
    // if (_latitudeController.text.isNotEmpty &&
    //     _longitudeController.text.isNotEmpty &&
    //     _areaController.text.isNotEmpty) {
    //   try {
    //     String uri = "http://10.0.2.2/GPS_API/gps_insert.php";
    //     var request = http.MultipartRequest('POST', Uri.parse(uri));
    //     request.fields['lat'] = _latitudeController.text;
    //     request.fields['long'] = _longitudeController.text;
    //     request.fields['area'] = _areaController.text;
    //     var res = await request.send();
    //     if (res.statusCode == 200) {
    //       print("Record Inserted");
    //     } else {
    //       print("Some issue");
    //     }
    //   } catch (e) {
    //     print(e);
    //   }
    // } else {
    //   print("Please fill all fields");
    // }
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
    var location = await Geolocator.getCurrentPosition();
    print("lat: ${location.latitude} lon: ${location.longitude}");
    return location;
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
  void initState() {
    super.initState();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
    _areaController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLoading('กำลังโหลดข้อมูล...');
    });
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var marker;
    var markerMap = {};
    var isAddSourceAnimatedRouting = false;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          title: Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map),
              Text('กำหนดจุดที่อยู่อาศัย'),
            ],
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
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
                        map.currentState?.call('Layers.setBase', args: [lay]);
                      }
                      var latlon = _determinePosition();
                      print(latlon);
                      latlon.then((value) => {
                            Navigator.of(context).pop(),
                            setState(() {
                              _latitudeController.text =
                                  value.latitude.toStringAsFixed(6);
                              _longitudeController.text =
                                  value.longitude.toStringAsFixed(6);
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
                                ],
                              );
                              map.currentState
                                  ?.call("Overlays.add", args: [marker]);
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
                      print(lat.runtimeType);
                      setState(() {
                        _latitudeController.text = lat.toStringAsFixed(6);
                        _longitudeController.text = lon.toStringAsFixed(6);
                      });
                      var marker = Longdo.LongdoObject(
                        "Marker",
                        args: [
                          {
                            "lon": lon,
                            "lat": lat,
                          },
                          {"draggable": true}
                        ],
                      );
                      map.currentState?.call("Overlays.add", args: [marker]);
                      final id = marker["\$id"];
                      markerMap[id] = marker;
                    },
                  ),
                  JavascriptChannel(
                    name: "overlayClick",
                    onMessageReceived: (message) {
                      var jsonObj = json.decode(message.message);
                      map.currentState
                          ?.call("Overlays.remove", args: [jsonObj["data"]]);
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _latitudeController,
                        decoration: InputDecoration(
                          labelText: 'ละติจูด',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _longitudeController,
                        decoration: InputDecoration(
                          labelText: 'ลองจิจูด',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _areaController,
                        decoration: InputDecoration(
                          labelText: 'พื้นที่',
                          hintText: 'เมตร',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                bottom: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        move_location();
                        insertRecord();
                      },
                      icon: Icon(Icons.save),
                      label: Text('บันทึก'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                        shadowColor: Colors.transparent,
                        side: BorderSide(color: Colors.green, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _latitudeController.clear();
                        _longitudeController.clear();
                      },
                      icon: Icon(Icons.close),
                      label: Text('ยกเลิก'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        shadowColor: Colors.transparent,
                        side: BorderSide(color: Colors.red, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

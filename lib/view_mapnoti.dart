import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_5/menu/drawer.dart';
import 'package:longdo_maps_api3_flutter/longdo_maps_api3_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Mapnoti extends StatefulWidget {
  const Mapnoti({Key? key, required this.lat, required this.lon})
      : super(key: key);
  final double lat;
  final double lon;

  @override
  State<Mapnoti> createState() => _MapnotiState();
}

class _MapnotiState extends State<Mapnoti> {
  final map = GlobalKey<LongdoMapState>();
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _areaController;

  Future<void> insertRecord() async {
    if (_latitudeController.text.isNotEmpty &&
        _longitudeController.text.isNotEmpty &&
        _areaController.text.isNotEmpty) {
      try {
        String uri = "http://10.0.2.2/GPS_API/gps_insert.php";
        var request = http.MultipartRequest('POST', Uri.parse(uri));
        request.fields['lat'] = _latitudeController.text;
        request.fields['long'] = _longitudeController.text;
        request.fields['area'] = _areaController.text;
        var res = await request.send();
        if (res.statusCode == 200) {
          print("Record Inserted");
        } else {
          print("Some issue");
        }
      } catch (e) {
        print(e);
      }
    } else {
      print("Please fill all fields");
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
    removelatlon();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
    _areaController = TextEditingController();
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void removelatlon() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('lat');
    prefs.remove('lon');
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
          title: Row(
            children: [
              Icon(Icons.map),
              SizedBox(width: 5),
              Text('View Map'),
            ],
          ),
        ),
        body: Expanded(
          child: LongdoMapWidget(
            apiKey: "556e31e859f72e9ec99600ae7135f479",
            key: map,
            eventName: [
              JavascriptChannel(
                name: "ready",
                onMessageReceived: (message) {
                  print("lat: ${widget.lat} lon: ${widget.lon} loaded");
                  var lay =
                      map.currentState?.LongdoStatic("Layers", 'RASTER_POI');
                  if (lay != null) {
                    print("ready");
                    map.currentState?.call('Layers.setBase', args: [lay]);
                  }
                  var latlon = _determinePosition();
                  print(latlon);
                  map.currentState?.call("location", args: [
                    {
                      "lon": widget.lon,
                      "lat": widget.lat,
                    }
                  ]);
                  var marker = Longdo.LongdoObject(
                    "Marker",
                    args: [
                      {
                        "lon": widget.lon,
                        "lat": widget.lat,
                      },
                    ],
                  );
                  map.currentState?.call("Overlays.add", args: [marker]);

                  // latlon.then((value) => {
                  //       setState(() {
                  //         map.currentState?.call("location", args: [
                  //           {
                  //             "lon": widget.lon,
                  //             "lat": widget.lat,
                  //           }
                  //         ]);
                  //         var marker = Longdo.LongdoObject(
                  //           "Marker",
                  //           args: [
                  //             {
                  //               "lon": widget.lon,
                  //               "lat": widget.lat,
                  //             },
                  //           ],
                  //         );
                  //         map.currentState
                  //             ?.call("Overlays.add", args: [marker]);
                  //       })
                  //     });
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  @override
  void initState() {
    super.initState();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                child: SizedBox(
                  height: 300,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _pGooglePlex,
                      zoom: 13,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
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
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Handle confirm button pressed
                      double latitude =
                          double.tryParse(_latitudeController.text) ?? 0.0;
                      double longitude =
                          double.tryParse(_longitudeController.text) ?? 0.0;
                      // Do something with latitude and longitude
                    },
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
            ],
          ),
        ),
      ),
    );
  }
}

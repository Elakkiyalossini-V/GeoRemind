import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({
    super.key,
  });

  @override
  State<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState
    extends State<LocationPickerScreen> {
  // Default starting location.
  // We will later replace this with the user's
  // actual current location.
  LatLng _selectedLocation = const LatLng(
    10.9601,
    79.3780,
  );

  final MapController _mapController =
      MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Home Location'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 15,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                    'com.example.geo_remind',
              ),

              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_pin,
                      size: 50,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Instruction card
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding:
                    const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.touch_app,
                      color: Colors.indigo,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tap anywhere on the map to select your home location.',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Confirm button
          Positioned(
            left: 20,
            right: 20,
            bottom: 25,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(
                  context,
                  _selectedLocation,
                );
              },
              icon: const Icon(
                Icons.check,
              ),
              label: const Text(
                'Confirm Location',
              ),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 17,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
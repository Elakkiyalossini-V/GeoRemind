import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({
    super.key,
    this.initialLocation,
  });

  final LatLng? initialLocation;

  @override
  State<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState
    extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();

  LatLng? _selectedLocation;
  bool _loadingLocation = true;

  // Default location if current location cannot be obtained.
  static const LatLng _defaultLocation =
      LatLng(10.9601, 79.3845);

  @override
  void initState() {
    super.initState();

    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation;
      _loadingLocation = false;
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _selectedLocation = _defaultLocation;
          _loadingLocation = false;
        });
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _selectedLocation = _defaultLocation;
          _loadingLocation = false;
        });
        return;
      }

      final position =
          await Geolocator.getCurrentPosition();

      final location = LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        _selectedLocation = location;
        _loadingLocation = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(
            location,
            16,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _selectedLocation = _defaultLocation;
        _loadingLocation = false;
      });
    }
  }

  void _confirmLocation() {
    if (_selectedLocation == null) {
      return;
    }

    Navigator.pop(
      context,
      _selectedLocation,
    );
  }

  void _useCurrentLocation() async {
    try {
      final position =
          await Geolocator.getCurrentPosition();

      final location = LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        _selectedLocation = location;
      });

      _mapController.move(
        location,
        16,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to get your current location.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final location =
        _selectedLocation ?? _defaultLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Home Location',
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: location,
              initialZoom: 16,
              onPositionChanged:
                  (camera, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _selectedLocation =
                        camera.center;
                  });
                }
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
                    point: location,
                    width: 60,
                    height: 60,
                    child: const Icon(
                      Icons.location_pin,
                      size: 52,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),

              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                  ),
                ],
              ),
            ],
          ),

          if (_loadingLocation)
            Container(
              color: Colors.white.withValues(
                alpha: 0.75,
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Move the map until the pin is exactly at your home.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            right: 16,
            bottom: 105,
            child: FloatingActionButton(
              heroTag: 'currentLocation',
              onPressed: _useCurrentLocation,
              child: const Icon(
                Icons.my_location,
              ),
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: ElevatedButton.icon(
              onPressed: _confirmLocation,
              icon: const Icon(
                Icons.check_circle_outline,
              ),
              label: const Text(
                'Confirm Home Location',
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
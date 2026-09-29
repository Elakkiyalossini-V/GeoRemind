// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../theme/app_theme.dart';

class LocationPickerScreen extends StatefulWidget {
  final String title;

  const LocationPickerScreen({
    super.key,
    this.title = 'Choose location',
  });

  @override
  State<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState
    extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();

  final TextEditingController _searchController =
      TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  LatLng _selectedLocation =
      const LatLng(10.7870, 79.1378);

  bool _loadingLocation = false;
  bool _searching = false;

  List<Map<String, dynamic>> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ============================================================
  // SEARCH OPENSTREETMAP / NOMINATIM
  // ============================================================

  Future<void> _searchPlaces(String query) async {
    final text = query.trim();

    if (text.isEmpty) {
      setState(() {
        _searchResults = [];
        _searching = false;
      });
      return;
    }

    setState(() {
      _searching = true;
    });

    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': text,
          'format': 'jsonv2',
          'limit': '6',
          'addressdetails': '1',
        },
      );

      final client = HttpClient();

      final request = await client.getUrl(uri);

      request.headers.set(
        HttpHeaders.userAgentHeader,
        'GeoRemind/1.0 (Flutter Android App)',
      );

      final response = await request.close();

      final responseBody =
          await response.transform(utf8.decoder).join();

      client.close();

      if (response.statusCode != 200) {
        throw Exception('Search failed');
      }

      final List<dynamic> data =
          jsonDecode(responseBody);

      if (!mounted) return;

      setState(() {
        _searchResults = data
            .map(
              (item) => {
                'display_name':
                    item['display_name'] ?? '',
                'lat': item['lat'],
                'lon': item['lon'],
              },
            )
            .toList();

        _searching = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _searchResults = [];
        _searching = false;
      });

      _showMessage(
        'Could not search places. Please try again.',
      );
    }
  }

  // ============================================================
  // SELECT SEARCH RESULT
  // ============================================================

  void _selectSearchResult(
    Map<String, dynamic> result,
  ) {
    final latitude =
        double.tryParse(result['lat'].toString());

    final longitude =
        double.tryParse(result['lon'].toString());

    if (latitude == null || longitude == null) {
      return;
    }

    final location = LatLng(
      latitude,
      longitude,
    );

    setState(() {
      _selectedLocation = location;
      _searchResults = [];
      _searchController.text =
          result['display_name'].toString();
    });

    _searchFocusNode.unfocus();

    _mapController.move(
      location,
      16,
    );
  }

  // ============================================================
  // CURRENT LOCATION
  // ============================================================

  Future<void> _useCurrentLocation() async {
    setState(() {
      _loadingLocation = true;
    });

    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _showMessage(
          'Please turn on location services.',
        );
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission ==
              LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        _showMessage(
          'Location permission was not granted.',
        );
        return;
      }

      final position =
          await Geolocator.getCurrentPosition();

      final location = LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _selectedLocation = location;
        _searchResults = [];
      });

      _searchController.clear();

      _mapController.move(
        location,
        16,
      );
    } catch (e) {
      _showMessage(
        'Could not get your location.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingLocation = false;
        });
      }
    }
  }

  // ============================================================
  // CONFIRM
  // ============================================================

  void _confirmLocation() {
    Navigator.of(context).pop(
      _selectedLocation,
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,

      // --------------------------------------------------------
      // APP BAR
      // --------------------------------------------------------

      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        foregroundColor: Colors.white,
        elevation: 0,

        title: Text(
          widget.title,
          style: AppText.body(
            size: 17,
            weight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),

      body: Stack(
        children: [

          // ====================================================
          // OSM MAP
          // ====================================================

          FlutterMap(
            mapController: _mapController,

            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 14,

              onTap: (_, point) {
                setState(() {
                  _selectedLocation = point;
                  _searchResults = [];
                });

                _searchFocusNode.unfocus();
              },
            ),

            children: [

              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                userAgentPackageName:
                    'com.example.geo_remind',
              ),

              // ------------------------------------------------
              // SELECTED LOCATION PIN
              // ------------------------------------------------

              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 50,
                    height: 50,

                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ====================================================
          // SEARCH BAR
          // ====================================================

          Positioned(
            left: 16,
            right: 16,
            top: 12,

            child: Column(
              children: [

                Container(
                  height: 54,

                  decoration: BoxDecoration(
                    // Slightly transparent white
                    color: Colors.white.withOpacity(0.92),

                    borderRadius:
                        BorderRadius.circular(16),

                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.18),
                        blurRadius: 10,
                        offset:
                            const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [

                      const SizedBox(width: 14),

                      const Icon(
                        Icons.search_rounded,
                        color: Colors.black54,
                        size: 23,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: TextField(
                          controller:
                              _searchController,

                          focusNode:
                              _searchFocusNode,

                          // IMPORTANT:
                          // Text typed by user is BLACK
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w500,
                          ),

                          cursorColor: Colors.black,

                          textInputAction:
                              TextInputAction.search,

                          decoration:
                              const InputDecoration(
                            hintText:
                                'Search places...',
                            hintStyle:
                                TextStyle(
                              color:
                                  Colors.black45,
                              fontSize: 14,
                            ),
                            border:
                                InputBorder.none,
                            enabledBorder:
                                InputBorder.none,
                            focusedBorder:
                                InputBorder.none,
                            contentPadding:
                                EdgeInsets.zero,
                          ),

                          onSubmitted:
                              _searchPlaces,

                          onChanged: (value) {
                            if (value.trim().isEmpty) {
                              setState(() {
                                _searchResults = [];
                              });
                            }
                          },
                        ),
                      ),

                      if (_searching)
                        const Padding(
                          padding:
                              EdgeInsets.only(
                            right: 12,
                          ),
                          child:
                              SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      else if (_searchController
                          .text
                          .isNotEmpty)
                        IconButton(
                          onPressed: () {
                            _searchController.clear();

                            setState(() {
                              _searchResults = [];
                            });
                          },

                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.black54,
                          ),
                        )
                      else
                        IconButton(
                          onPressed: () {
                            _searchPlaces(
                              _searchController.text,
                            );
                          },

                          icon: const Icon(
                            Icons.search_rounded,
                            color: Colors.black87,
                          ),
                        ),
                    ],
                  ),
                ),

                // =================================================
                // SEARCH RESULTS
                // =================================================

                if (_searchResults.isNotEmpty)
                  Container(
                    margin:
                        const EdgeInsets.only(
                      top: 6,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.96),

                      borderRadius:
                          BorderRadius.circular(16),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.20),
                          blurRadius: 12,
                          offset:
                              const Offset(0, 5),
                        ),
                      ],
                    ),

                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(16),

                      child: Column(
                        children:
                            _searchResults.map(
                          (result) {
                            final name =
                                result[
                                    'display_name'];

                            return InkWell(
                              onTap: () =>
                                  _selectSearchResult(
                                result,
                              ),

                              child: Padding(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),

                                child: Row(
                                  children: [

                                    const Icon(
                                      Icons
                                          .location_on_outlined,
                                      color:
                                          Colors.black54,
                                      size: 21,
                                    ),

                                    const SizedBox(
                                      width: 10,
                                    ),

                                    Expanded(
                                      child: Text(
                                        name
                                            .toString(),

                                        maxLines: 2,

                                        overflow:
                                            TextOverflow
                                                .ellipsis,

                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.black87,
                                          fontSize: 13,
                                          fontWeight:
                                              FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ====================================================
          // CURRENT LOCATION BUTTON
          // ====================================================

          Positioned(
            right: 18,
            bottom: 165,

            child: FloatingActionButton(
              heroTag:
                  'current_location',

              onPressed:
                  _loadingLocation
                      ? null
                      : _useCurrentLocation,

              backgroundColor:
                  Colors.white,

              foregroundColor:
                  Colors.black87,

              elevation: 5,

              child: _loadingLocation
                  ? const SizedBox(
                      width: 22,
                      height: 22,

                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons
                          .my_location_rounded,
                    ),
            ),
          ),

          // ====================================================
          // BOTTOM CONFIRM PANEL
          // ====================================================

          Positioned(
  left: 16,
  right: 16,
  bottom: 16,
  child: SizedBox(
    height: 50,
    child: ElevatedButton(
      onPressed: _confirmLocation,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: const Text(
        'Confirm location',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    ),
  ),
),
        ],
      ),
    );
  }
}
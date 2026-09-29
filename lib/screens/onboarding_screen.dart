import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/api_service.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'root_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  final TextEditingController _nameController =
      TextEditingController();

  int _currentPage = 0;
  bool _locationPermissionGranted = false;
  bool _notificationPermissionGranted = false;
  bool _microphonePermissionGranted = false;

  String? _selectedCategory;

  LatLng? _homeLocation;
  String _homeAddress = '';
  String _homeCity = '';

  final List<Place> _frequentPlaces = [];

  final List<Map<String, dynamic>> _categories = [
    {
      'label': 'College',
      'icon': Icons.school_rounded,
    },
    {
      'label': 'Office',
      'icon': Icons.work_rounded,
    },
    {
      'label': 'Gym',
      'icon': Icons.fitness_center_rounded,
    },
    {
      'label': 'Supermarket',
      'icon': Icons.shopping_cart_rounded,
    },
    {
      'label': 'Other',
      'icon': Icons.place_rounded,
    },
  ];

  bool _requestingPermissions = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ============================================================
  // NEXT
  // ============================================================

  void _next() {
  // STEP 1 — NAME
  if (_currentPage == 0) {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please tell us what we should call you.'),
        ),
      );
      return;
    }

    // Save the name
    appState.setUserName(name);

    // Move to Step 2
    setState(() {
      _currentPage = 1;
    });

    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );

    return;
  }

  // STEP 2 — HOME LOCATION
  if (_currentPage == 1) {
    setState(() {
      _currentPage = 2;
    });

    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );

    return;
  }

  // STEP 3 — FREQUENT PLACES
  if (_currentPage == 2) {
  setState(() {
    _currentPage = 3;
  });

  _pageController.animateToPage(
    3,
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeInOut,
  );

  _loadPermissionStatuses();

  return;
}

  // STEP 4 — PERMISSIONS
  if (_currentPage == 3) {
  _requestAllPermissionsAndFinish();
  return;
}

}

  // ============================================================
  // SKIP
  // ============================================================

  void _skipCurrent() {
    if (_currentPage == 2) {
      setState(() {
        _currentPage = 3;
      });

      _pageController.animateToPage(
        3,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );

      return;
    }

    _next();
  }

  // ============================================================
  // FINAL PERMISSIONS
  // ============================================================

  Future<void> _loadPermissionStatuses() async {
  final locationStatus =
      await Permission.locationWhenInUse.status;

  final notificationStatus =
      await Permission.notification.status;

  final microphoneStatus =
      await Permission.microphone.status;

  if (!mounted) return;

  setState(() {
    _locationPermissionGranted = locationStatus.isGranted;
    _notificationPermissionGranted = notificationStatus.isGranted;
    _microphonePermissionGranted = microphoneStatus.isGranted;
  });
}

  // ============================================================
  // FINISH
  // ============================================================

  Future<void> _finishOnboarding() async {
  if (!mounted) return;

  debugPrint('GEOREMIND: Preparing user data for FastAPI');

  try {
    // ------------------------------------------------------------
    // Get user name
    // ------------------------------------------------------------
    final name = _nameController.text.trim();

    // ------------------------------------------------------------
    // Convert selected home location to "latitude, longitude"
    // ------------------------------------------------------------
    String? homeLocation;

    if (_homeLocation != null) {
      homeLocation =
          '${_homeLocation!.latitude}, ${_homeLocation!.longitude}';
    }

    debugPrint('GEOREMIND: Name = $name');
    debugPrint('GEOREMIND: Home location = $homeLocation');

    // ------------------------------------------------------------
    // Send user data to FastAPI
    // ------------------------------------------------------------
    final apiSuccess = await ApiService.createUser(
      name: name,
      homeLocation: homeLocation,
    );

    if (apiSuccess) {
      debugPrint(
        'GEOREMIND: User successfully sent to FastAPI',
      );
    } else {
      debugPrint(
        'GEOREMIND: FastAPI unavailable - continuing offline',
      );
    }

    // ------------------------------------------------------------
    // Continue to the main application
    // ------------------------------------------------------------
    if (!mounted) return;

    debugPrint(
      'GEOREMIND: Starting navigation to RootShell',
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const RootShell(),
      ),
      (route) => false,
    );

    debugPrint(
      'GEOREMIND: Navigation command executed',
    );
  } catch (e, stackTrace) {
    debugPrint(
      'GEOREMIND: Finish onboarding error: $e',
    );

    debugPrint(
      stackTrace.toString(),
    );

    // ------------------------------------------------------------
    // Even if FastAPI fails, GeoRemind continues.
    // This keeps the app offline-friendly.
    // ------------------------------------------------------------
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const RootShell(),
        ),
        (route) => false,
      );
    }
  }
}

  // ============================================================
  // CATEGORY
  // ============================================================

  void _selectCategory(String label) {
    setState(() {
      _selectedCategory = label;
    });
  }

  // ============================================================
  // HOME MAP
  // ============================================================

  Future<void> _chooseHomeLocation() async {
    final result = await Navigator.of(context).push<SelectedLocation>(
      MaterialPageRoute(
        builder: (_) => const LocationPickerPage(
          title: 'Choose your home location',
          confirmText: 'Confirm home location',
        ),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      _homeLocation = result.location;
      _homeAddress = result.address;
      _homeCity = result.city;
    });
  }

  // ============================================================
  // FREQUENT PLACE MAP
  // ============================================================

  Future<void> _addPlace() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose a place type first.'),
        ),
      );
      return;
    }

    final category = _selectedCategory!;

    final result =
        await Navigator.of(context).push<SelectedLocation>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(
          title: 'Choose your $category location',
          confirmText: 'Confirm $category location',
        ),
      ),
    );

    if (result == null || !mounted) return;

    final place = Place(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      icon: _iconForCategory(category),
      name: category,
      addr: result.address,
      latitude: result.location.latitude,
      longitude: result.location.longitude,
    );

    await databaseService.savePlace(place);

    setState(() {
      _frequentPlaces.add(place);
      _selectedCategory = null;
    });
  }

  String _iconForCategory(String category) {
    switch (category) {
      case 'College':
        return '🎓';
      case 'Office':
        return '💼';
      case 'Gym':
        return '🏋️';
      case 'Supermarket':
        return '🛒';
      default:
        return '📍';
    }
  }

  Future<void> _requestAllPermissionsAndFinish() async {
  if (_requestingPermissions) return;

  setState(() {
    _requestingPermissions = true;
  });

  try {
    debugPrint('GEOREMIND: Requesting permissions');

    await Permission.locationWhenInUse.request();

    if (!mounted) return;

    await Permission.notification.request();

    if (!mounted) return;

    await Permission.microphone.request();

    if (!mounted) return;

    debugPrint(
      'GEOREMIND: All permission requests completed',
    );

    // IMPORTANT:
    // Go directly to the home page.
    await _finishOnboarding();
  } catch (e, stackTrace) {
    debugPrint(
      'GEOREMIND: Permission error: $e',
    );

    debugPrint(
      stackTrace.toString(),
    );

    // Even if a permission request fails,
    // continue to the app.
    if (mounted) {
      await _finishOnboarding();
    }
  }
}
  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(),
                children: [
                  _buildNamePage(),
                  _buildHomeLocationPage(),
                  _buildPlacesPage(),
                  _buildPermissionsPage(),
                ],
              ),
            ),

            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        22,
        16,
        22,
        10,
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            IconButton(
              onPressed: _requestingPermissions
                  ? null
                  : () {
                      setState(() {
                        _currentPage--;
                      });

                      _pageController.animateToPage(
                        _currentPage,
                        duration:
                            const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
              ),
            )
          else
            const SizedBox(width: 48),

          Expanded(
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) {
                  final active =
                      index <= _currentPage;

                  return AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 250),
                    margin:
                        const EdgeInsets.symmetric(
                      horizontal: 3,
                    ),
                    height: 5,
                    width: index == _currentPage
                        ? 28
                        : 9,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.emerald
                          : AppColors.glassBorder,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE 1 - NAME
  // ============================================================

  Widget _buildNamePage() {
    return _pageContainer(
      icon: Icons.waving_hand_rounded,
      title: 'What should we call you?',
      subtitle:
          'Your name will be used to make GeoRemind feel personal.',
      child: TextField(
        controller: _nameController,
        autofocus: true,
        textCapitalization:
            TextCapitalization.words,
        style: AppText.body(
          size: 17,
          weight: FontWeight.w600,
          color: Colors.white,
        ),
        decoration: _inputDecoration(
          hint: 'Your name or nickname',
          icon: Icons.person_outline_rounded,
        ),
      ),
    );
  }

  // ============================================================
  // PAGE 2 - HOME
  // ============================================================

  Widget _buildHomeLocationPage() {
    final hasLocation = _homeLocation != null;

    return _pageContainer(
      icon: Icons.home_rounded,
      title: 'Where do you live?',
      subtitle:
          'Your home helps GeoRemind understand journeys and location-based reminders.',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF17122F),
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.glassBorder,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.emerald
                        .withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.emerald,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasLocation
                            ? 'Home location selected'
                            : 'Home location',
                        style: AppText.body(
                          size: 13,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasLocation
                            ? _homeAddress
                            : 'Choose your location on the map',
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: AppText.body(
                          size: 11,
                          color: AppColors.textLow,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasLocation)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.emerald,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _chooseHomeLocation,
              icon: const Icon(
                Icons.map_outlined,
              ),
              label: Text(
                hasLocation
                    ? 'Change home location'
                    : 'Choose on map',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    Colors.white,
                side: const BorderSide(
                  color: AppColors.glassBorder,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE 3 - FREQUENT PLACES
  // ============================================================

  Widget _buildPlacesPage() {
    return _pageContainer(
      icon: Icons.place_rounded,
      title: 'Places you visit often',
      subtitle:
          'Add places like your college, office, gym or supermarket.',
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((category) {
              final selected =
                  _selectedCategory ==
                      category['label'];

              return ChoiceChip(
                selected: selected,
                label: Text(
                  category['label'],
                ),
                avatar: Icon(
                  category['icon'] as IconData,
                  size: 18,
                ),
                onSelected: (_) {
                  _selectCategory(
                    category['label'] as String,
                  );
                },
                selectedColor:
                    AppColors.emerald
                        .withValues(alpha: 0.18),
                backgroundColor:
                    const Color(0xFF17122F),
                labelStyle: TextStyle(
                  color: selected
                      ? AppColors.emerald
                      : AppColors.textMid,
                  fontWeight:
                      FontWeight.w600,
                ),
                side: BorderSide(
                  color: selected
                      ? AppColors.emerald
                      : AppColors.glassBorder,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          if (_frequentPlaces.isNotEmpty)
            ..._frequentPlaces.map(
              (place) => Container(
                margin:
                    const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFF17122F),
                  borderRadius:
                      BorderRadius.circular(15),
                  border: Border.all(
                    color:
                        AppColors.glassBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      place.icon,
                      style:
                          const TextStyle(
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.name,
                            style:
                                AppText.body(
                              size: 13,
                              weight:
                                  FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            place.addr,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                AppText.body(
                              size: 11,
                              color:
                                  AppColors.textLow,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.check_circle_rounded,
                      color:
                          AppColors.emerald,
                      size: 21,
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _addPlace,
              icon: const Icon(
                Icons.add_location_alt_outlined,
              ),
              label: Text(
                _selectedCategory == null
                    ? 'Select a place type first'
                    : 'Choose $_selectedCategory location',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    Colors.white,
                side: const BorderSide(
                  color: AppColors.glassBorder,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE 4 - PERMISSIONS
  // ============================================================

  Widget _buildPermissionsPage() {
    return _pageContainer(
      icon: Icons.security_rounded,
      title: 'Few Permissions',
      subtitle:
          'Allow these permissions so location reminders, notifications and voice features can work.',
      child: Column(
        children: [
          _permissionTile(
            Icons.location_on_rounded,
            'Location',
            'For location-aware reminders.',
            Permission.locationWhenInUse,
          ),
          _permissionTile(
            Icons.notifications_rounded,
            'Notifications',
            'To alert you when a reminder triggers.',
            Permission.notification,
          ),
          _permissionTile(
            Icons.mic_rounded,
            'Microphone',
            'For voice reminder creation.',
            Permission.microphone,
          ),
        ],
      ),
    );
  }

  Widget _permissionTile(
    IconData icon,
    String title,
    String description,
    Permission permission,
    
  ) {
    return FutureBuilder<PermissionStatus>(
      future: permission.status,
      builder: (context, snapshot) {
        final granted =
            snapshot.data?.isGranted ?? false;

        return Container(
          margin:
              const EdgeInsets.only(bottom: 10),
          padding:
              const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color:
                const Color(0xFF17122F),
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color:
                  AppColors.glassBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.emerald
                      .withValues(alpha: 0.10),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color:
                      AppColors.emerald,
                  size: 21,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppText.body(
                        size: 13,
                        weight:
                            FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: AppText.body(
                        size: 10.5,
                        color:
                            AppColors.textLow,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                granted
                    ? Icons.check_circle_rounded
                    : Icons
                        .check_circle_outline_rounded,
                color: granted
                    ? AppColors.emerald
                    : AppColors.textLow,
                size: 21,
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // PAGE CONTAINER
  // ============================================================

  Widget _pageContainer({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        24,
        24,
        24,
        20,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient:
                  AppColors.mainGradient,
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(height: 25),

          Text(
            title,
            style: AppText.display(
              size: 27,
              weight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            subtitle,
            style: AppText.body(
              size: 13,
              color: AppColors.textMid,
            ),
          ),

          const SizedBox(height: 30),

          child,
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM BUTTON
  // ============================================================

  Widget _buildBottomControls() {
    final isLast = _currentPage == 3;
    final isPlaces = _currentPage == 2;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        8,
        24,
        20,
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient:
                    AppColors.mainGradient,
                borderRadius:
                    BorderRadius.all(
                  Radius.circular(16),
                ),
              ),
              child: ElevatedButton(
                onPressed:
                    _requestingPermissions
                        ? null
                        : _next,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.transparent,
                  foregroundColor:
                      Colors.white,
                  shadowColor:
                      Colors.transparent,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                ),
                child:
                    _requestingPermissions
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  Colors.white,
                            ),
                          )
                        : Text(
                            isLast
                                ? 'Allow & continue'
                                : 'Continue',
                            style:
                                const TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
              ),
            ),
          ),

          if (isPlaces) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed:
                  _requestingPermissions
                      ? null
                      : _skipCurrent,
              child: Text(
                'Skip for now',
                style: AppText.body(
                  size: 12,
                  weight:
                      FontWeight.w600,
                  color:
                      AppColors.textMid,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppText.body(
        size: 13,
        color: AppColors.textLow,
      ),
      prefixIcon: Icon(
        icon,
        color: AppColors.textLow,
      ),
      filled: true,
      fillColor:
          const Color(0xFF17122F),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide:
            const BorderSide(
          color:
              AppColors.glassBorder,
        ),
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide:
            const BorderSide(
          color:
              AppColors.glassBorder,
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide:
            const BorderSide(
          color:
              AppColors.emerald,
          width: 1.3,
        ),
      ),
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
    );
  }
}

// ================================================================
// SELECTED LOCATION
// ================================================================

class SelectedLocation {
  final LatLng location;
  final String address;
  final String city;

  const SelectedLocation({
    required this.location,
    required this.address,
    required this.city,
  });
}

// ================================================================
// OSM LOCATION PICKER
// ================================================================

class LocationPickerPage extends StatefulWidget {
  final String title;
  final String confirmText;

  const LocationPickerPage({
    super.key,
    required this.title,
    required this.confirmText,
  });

  @override
  State<LocationPickerPage> createState() =>
      _LocationPickerPageState();
}

class _LocationPickerPageState
    extends State<LocationPickerPage> {
  final MapController _mapController =
      MapController();

  final TextEditingController _searchController =
      TextEditingController();

  LatLng _selectedLocation =
      const LatLng(10.9601, 79.3780);

  String _selectedAddress = '';
  String _selectedCity = '';

  bool _loading = false;
  bool _searching = false;

  List<_SearchResult> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // CURRENT LOCATION
  // ============================================================

  Future<void> _loadCurrentLocation() async {
    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) return;

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
        return;
      }

      final position =
          await Geolocator.getCurrentPosition();

      if (!mounted) return;

      final location = LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _selectedLocation = location;
      });

      _mapController.move(
        location,
        16,
      );

      await _reverseGeocode(location);
    } catch (_) {
      // Keep the default map location.
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Future<void> _searchPlaces() async {
    final query =
        _searchController.text.trim();

    if (query.isEmpty) return;

    setState(() {
      _searching = true;
      _searchResults = [];
    });

    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': query,
          'format': 'json',
          'limit': '5',
          'addressdetails': '1',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent':
              'GeoRemind/1.0 Flutter Android app',
          'Accept':
              'application/json',
        },
      );

      if (response.statusCode != 200) {
        return;
      }

      final List<dynamic> data =
          jsonDecode(response.body);

      final results = data.map((item) {
        final lat =
            double.parse(item['lat'].toString());

        final lon =
            double.parse(item['lon'].toString());

        final display =
            item['display_name']
                    ?.toString() ??
                '';

        final address =
            item['address']
                    as Map<String, dynamic>? ??
                {};

        final city =
            address['city']?.toString() ??
            address['town']?.toString() ??
            address['village']?.toString() ??
            address['municipality']?.toString() ??
            '';

        return _SearchResult(
          location: LatLng(lat, lon),
          address: display,
          city: city,
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        _searchResults = results;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to search right now. Check your internet connection.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _searching = false;
        });
      }
    }
  }

  // ============================================================
  // SELECT SEARCH RESULT
  // ============================================================

  Future<void> _selectSearchResult(
    _SearchResult result,
  ) async {
    FocusScope.of(context).unfocus();

    setState(() {
      _selectedLocation = result.location;
      _selectedAddress = result.address;
      _selectedCity = result.city;
      _searchResults = [];
    });

    _mapController.move(
      result.location,
      17,
    );
  }

  // ============================================================
  // MAP TAP
  // ============================================================

  Future<void> _onMapTap(
    TapPosition tapPosition,
    LatLng point,
  ) async {
    setState(() {
      _selectedLocation = point;
      _loading = true;
    });

    await _reverseGeocode(point);

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }

  // ============================================================
  // REVERSE GEOCODE
  // ============================================================

  Future<void> _reverseGeocode(
    LatLng location,
  ) async {
    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/reverse',
        {
          'lat': location.latitude.toString(),
          'lon': location.longitude.toString(),
          'format': 'json',
          'addressdetails': '1',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent':
              'GeoRemind/1.0 Flutter Android app',
          'Accept':
              'application/json',
        },
      );

      if (response.statusCode != 200) return;

      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      final address =
          data['display_name']?.toString() ??
              '';

      final addressData =
          data['address']
                  as Map<String, dynamic>? ??
              {};

      final city =
          addressData['city']?.toString() ??
          addressData['town']?.toString() ??
          addressData['village']?.toString() ??
          addressData['municipality']?.toString() ??
          '';

      if (!mounted) return;

      setState(() {
        _selectedAddress = address;
        _selectedCity = city;
      });
    } catch (_) {
      // Address lookup is optional.
    }
  }

  // ============================================================
  // CONFIRM
  // ============================================================

  void _confirmLocation() {
    Navigator.of(context).pop(
      SelectedLocation(
        location: _selectedLocation,
        address: _selectedAddress.isEmpty
            ? '${_selectedLocation.latitude.toStringAsFixed(6)}, '
                '${_selectedLocation.longitude.toStringAsFixed(6)}'
            : _selectedAddress,
        city: _selectedCity,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor:
            AppColors.bgDeep,
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  _selectedLocation,
              initialZoom: 14,
              onTap: _onMapTap,
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
                    point:
                        _selectedLocation,
                    width: 55,
                    height: 55,
                    child: const Icon(
                      Icons.location_on,
                      color:
                          Colors.redAccent,
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
            top: 14,
            left: 14,
            right: 14,
            child: Column(
              children: [
                Material(
                  elevation: 8,
                  borderRadius:
                      BorderRadius.circular(16),
                  child: TextField(
                    controller:
                        _searchController,
                    textInputAction:
                        TextInputAction.search,
                    onSubmitted: (_) =>
                        _searchPlaces(),
                    decoration:
                        InputDecoration(
                      hintText:
                          'Search places...',
                      prefixIcon:
                          const Icon(
                        Icons.search_rounded,
                      ),
                      suffixIcon:
                          _searching
                              ? const Padding(
                                  padding:
                                      EdgeInsets.all(
                                    12,
                                  ),
                                  child:
                                      SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                    ),
                                  ),
                                )
                              : IconButton(
                                  onPressed:
                                      _searchPlaces,
                                  icon:
                                      const Icon(
                                    Icons
                                        .arrow_forward_rounded,
                                  ),
                                ),
                      filled: true,
                      fillColor:
                          Colors.white,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),
                    ),
                  ),
                ),

                if (_searchResults.isNotEmpty)
                  Container(
                    margin:
                        const EdgeInsets.only(
                      top: 6,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                    child: Column(
                      children:
                          _searchResults
                              .map(
                        (result) {
                          return ListTile(
                            dense: true,
                            leading:
                                const Icon(
                              Icons
                                  .location_on_outlined,
                            ),
                            title: Text(
                              result.address,
                              maxLines: 2,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.black,
                                fontSize: 12,
                              ),
                            ),
                            onTap: () =>
                                _selectSearchResult(
                              result,
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
              ],
            ),
          ),

          // ====================================================
          // CURRENT LOCATION BUTTON
          // ====================================================

          Positioned(
            right: 16,
            bottom: 145,
            child: FloatingActionButton(
              heroTag:
                  'current-location',
              backgroundColor:
                  Colors.white,
              foregroundColor:
                  AppColors.bgDeep,
              onPressed:
                  _loadCurrentLocation,
              child: const Icon(
                Icons.my_location_rounded,
              ),
            ),
          ),

          // ====================================================
          // BOTTOM CONFIRM PANEL
          // ====================================================

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding:
                    const EdgeInsets.fromLTRB(
                  18,
                  16,
                  18,
                  18,
                ),
                decoration:
                    const BoxDecoration(
                  color:
                      AppColors.bgDeep,
                  borderRadius:
                      BorderRadius.vertical(
                    top:
                        Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected location',
                      style:
                          AppText.body(
                        size: 12,
                        weight:
                            FontWeight.w700,
                        color:
                            AppColors.textMid,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      _loading
                          ? 'Finding address...'
                          : _selectedAddress
                                  .isEmpty
                              ? 'Tap the map or search for a place'
                              : _selectedAddress,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          AppText.body(
                        size: 12,
                        color:
                            Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 13,
                    ),
                    SizedBox(
                      width:
                          double.infinity,
                      height: 53,
                      child:
                          DecoratedBox(
                        decoration:
                            const BoxDecoration(
                          gradient:
                              AppColors
                                  .mainGradient,
                          borderRadius:
                              BorderRadius.all(
                            Radius.circular(
                              16,
                            ),
                          ),
                        ),
                        child:
                            ElevatedButton(
                          onPressed:
                              _confirmLocation,
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                Colors
                                    .transparent,
                            foregroundColor:
                                Colors.white,
                            shadowColor:
                                Colors
                                    .transparent,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                16,
                              ),
                            ),
                          ),
                          child: Text(
                            widget
                                .confirmText,
                            style:
                                const TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// SEARCH RESULT
// ================================================================

class _SearchResult {
  final LatLng location;
  final String address;
  final String city;

  const _SearchResult({
    required this.location,
    required this.address,
    required this.city,
  });
}
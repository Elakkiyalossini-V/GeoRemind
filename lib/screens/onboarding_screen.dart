import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/database_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {
  int _currentStep = 0;

  String _name = '';

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController
      _homeLocationController =
      TextEditingController();

  final List<String> _selectedPlaces = [];

  final List<Map<String, dynamic>> _placeOptions = [
    {
      'name': 'College',
      'icon': Icons.school,
    },
    {
      'name': 'Office',
      'icon': Icons.business_center,
    },
    {
      'name': 'Gym',
      'icon': Icons.fitness_center,
    },
    {
      'name': 'Supermarket',
      'icon': Icons.shopping_cart,
    },
    {
      'name': 'Other',
      'icon': Icons.location_on,
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _homeLocationController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    // STEP 1
    if (_currentStep == 0) {
      final enteredName =
          _nameController.text.trim();

      if (enteredName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please enter your name.',
            ),
          ),
        );
        return;
      }

      _name = enteredName;

      // Save the name in SQLite.
      await DatabaseService.saveUserName(
        _name,
      );
    }

    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      await _finishOnboarding();
    }
  }

  Future<void> _skip() async {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      await _finishOnboarding();
    }
  }
  Future<bool> _requestLocationPermission() async {
    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (!mounted) return false;

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Location is turned off'),
            content: const Text(
              'Please turn on Location services so GeoRemind can detect your location.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await Geolocator.openLocationSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          );
        },
      );

      return false;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return false;

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Location permission required'),
            content: const Text(
              'GeoRemind needs location permission. Please enable it from App Settings.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await Geolocator.openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          );
        },
      );

      return false;
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }
  Future<void> _finishOnboarding() async {
    // Mark onboarding as completed in SQLite.
    await DatabaseService.setOnboardingCompleted();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          userName: _name,
        ),
      ),
    );
  }

  void _togglePlace(String place) {
    setState(() {
      if (_selectedPlaces.contains(place)) {
        _selectedPlaces.remove(place);
      } else {
        _selectedPlaces.add(place);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  10,
                  24,
                  30,
                ),
                child: _buildStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        18,
        24,
        10,
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (_currentStep > 0)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                    });
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                  ),
                )
              else
                const SizedBox(width: 48),

              Expanded(
                child: Text(
                  'Step ${_currentStep + 1} of 4',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),

              const SizedBox(width: 48),
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / 4,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _buildNameStep();

      case 1:
        return _buildHomeStep();

      case 2:
        return _buildPlacesStep();

      case 3:
        return _buildPermissionsStep();

      default:
        return const SizedBox();
    }
  }

  // STEP 1
  Widget _buildNameStep() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 35),

        _buildIcon(
          Icons.person_outline,
        ),

        const SizedBox(height: 25),

        const Text(
          'What should we call you?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'This name will appear on your GeoRemind home screen.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 30),

        TextField(
          controller: _nameController,
          textCapitalization:
              TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Your name',
            hintText: 'Example: Elai',
            prefixIcon: const Icon(
              Icons.person_outline,
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(16),
            ),
          ),
        ),

        const SizedBox(height: 35),

        _continueButton(
          text: 'Continue',
          onPressed: _continue,
        ),
      ],
    );
  }

  // STEP 2
  Widget _buildHomeStep() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 35),

        _buildIcon(
          Icons.home_outlined,
        ),

        const SizedBox(height: 25),

        const Text(
          'Where do you live?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'Add your home location so GeoRemind can understand your usual location.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 30),

        TextField(
          controller:
              _homeLocationController,
          decoration: InputDecoration(
            labelText: 'Home location',
            hintText:
                'Enter your home location',
            prefixIcon: const Icon(
              Icons.location_on_outlined,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'OpenStreetMap location picker will be added later.',
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.map_outlined,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(16),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Optional for now. If you skip this, GeoRemind will ask for your home location when you create your first reminder.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 35),

        _continueButton(
          text: 'Continue',
          onPressed: _continue,
        ),

        const SizedBox(height: 8),

        _skipButton(
          text: 'Skip for now',
          onPressed: _skip,
        ),
      ],
    );
  }

  // STEP 3
  Widget _buildPlacesStep() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 35),

        _buildIcon(
          Icons.place_outlined,
        ),

        const SizedBox(height: 25),

        const Text(
          'Want to add places you visit often?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'Tap to add — you can always change these later.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 28),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              _placeOptions.map((place) {
            final String name =
                place['name'];

            final IconData icon =
                place['icon'];

            final bool selected =
                _selectedPlaces
                    .contains(name);

            return FilterChip(
              selected: selected,
              avatar: Icon(
                icon,
                size: 20,
              ),
              label: Text(name),
              onSelected: (_) {
                _togglePlace(name);
              },
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    'Place picker will be added later.',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons
                  .add_location_alt_outlined,
            ),
            label: const Text(
              'Add Place',
            ),
            style:
                OutlinedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 15,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
            ),
          ),
        ),

        const SizedBox(height: 25),

        _continueButton(
          text: 'Continue',
          onPressed: _continue,
        ),

        const SizedBox(height: 8),

        _skipButton(
          text: 'Skip for now',
          onPressed: _skip,
        ),
      ],
    );
  }

  // STEP 4
  Widget _buildPermissionsStep() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),

        _buildIcon(
          Icons.security_outlined,
        ),

        const SizedBox(height: 25),

        const Text(
          'A few permissions',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'GeoRemind needs these to detect when you arrive somewhere and talk to you naturally.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 30),

        _permissionCard(
          icon: Icons.location_on,
          title: 'Location',
          description:
              'Detects when you enter a saved place, even in the background.',
        ),

        const SizedBox(height: 14),

        _permissionCard(
          icon: Icons.notifications,
          title: 'Notifications',
          description:
              'Lets us alert you the moment a reminder triggers.',
        ),

        const SizedBox(height: 14),

        _permissionCard(
          icon: Icons.mic,
          title: 'Microphone',
          description:
              'Enables voice-based reminder creation.',
        ),

        const SizedBox(height: 30),

        _continueButton(
  text: 'Allow All',
  icon: Icons.check_circle_outline,
  onPressed: () async {
    final granted =
        await _requestLocationPermission();

    if (granted) {
      await _finishOnboarding();
    }
  },
),
      ],
    );
  }

  Widget _buildIcon(IconData icon) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Icon(
        icon,
        size: 34,
        color: Colors.indigo,
      ),
    );
  }

  Widget _continueButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon ?? Icons.arrow_forward,
        ),
        label: Text(text),
        style:
            ElevatedButton.styleFrom(
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
    );
  }

  Widget _skipButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  Widget _permissionCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: Colors.indigo,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        Colors.grey.shade600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'reminders_screen.dart';
import 'places_screen.dart';
import 'settings_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  late final List<Widget> _tabs;

  final _items = const [
    (
      icon: Icons.home_rounded,
      label: 'Home',
    ),
    (
      icon: Icons.auto_awesome_rounded,
      label: 'AI Chat',
    ),
    (
      icon: Icons.notifications_active_rounded,
      label: 'Reminders',
    ),
    (
      icon: Icons.location_on_rounded,
      label: 'Places',
    ),
    (
      icon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _tabs = [
      const HomeScreen(),
      const ChatScreen(),
      const RemindersScreen(),
      const PlacesScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,

      body: SafeArea(
        bottom: false,
        child: _tabs[_index],
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xE6140A2A),
          border: const Border(
            top: BorderSide(
              color: AppColors.glassBorder,
            ),
          ),
        ),
        padding: const EdgeInsets.only(
          bottom: 6,
          top: 6,
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _items.length,
              (i) {
                final item = _items[i];
                final active = i == _index;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _index = i;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 21,
                          color: active
                              ? AppColors.emerald
                              : AppColors.textLow,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: AppText.body(
                            size: 10.5,
                            weight: FontWeight.w500,
                            color: active
                                ? AppColors.emerald
                                : AppColors.textLow,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
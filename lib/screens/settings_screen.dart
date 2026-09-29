import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'settings_detail_screen.dart';
import 'analytics_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const TabHeader(eyebrow: 'Preferences', title: 'Settings'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.purple2,
              child: Text(appState.userName.substring(0, 1), style: AppText.display(size: 19, color: Colors.white)),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appState.userName, style: AppText.body(size: 16, weight: FontWeight.w700)),
                Text(appState.homeCity, style: AppText.body(size: 12, color: AppColors.textMid)),
              ],
            ),
          ]),
        ),
        const SizedBox(height: 6),
        _group(context, 'Account', [('Profile', Icons.info_outline_rounded)]),
        _group(context, 'Notifications', [('Notification preferences', Icons.notifications_outlined)]),
        _group(context, 'Location', [('Location permissions', Icons.location_on_outlined)]),
        _group(context, 'AI', [('AI personalization', Icons.bolt_rounded)]),
        _group(context, 'Voice', [('Voice assistant settings', Icons.mic_none_rounded)]),
        _group(context, 'Privacy', [
          ('Chat history', Icons.chat_bubble_outline_rounded),
          ('Location history', Icons.map_outlined),
          ('Activity learning', Icons.track_changes_rounded),
        ]),
        _group(context, 'Appearance', [('Light / Dark mode', Icons.dark_mode_outlined)]),
        _group(context, 'Data', [
          ('Delete chat history', Icons.delete_outline_rounded),
          ('Delete location history', Icons.delete_outline_rounded),
          ('Delete account', Icons.delete_outline_rounded),
        ]),
        _group(context, 'About', [('About GeoRemind', Icons.info_outline_rounded)]),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
          child: AppButton(
            label: 'View Analytics',
            icon: Icons.bolt_rounded,
            style: AppButtonStyle.secondary,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
          ),
        ),
      ],
    );
  }

  Widget _group(BuildContext context, String title, List<(String, IconData)> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(title),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: List.generate(items.length, (i) {
                final (label, icon) = items[i];
                return InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsDetailScreen(label: label))),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      border: i == items.length - 1 ? null : const Border(bottom: BorderSide(color: Color(0x0DFFFFFF))),
                    ),
                    child: Row(children: [
                      Icon(icon, size: 17, color: AppColors.textHi),
                      const SizedBox(width: 12),
                      Expanded(child: Text(label, style: AppText.body(size: 13.5))),
                      const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textMid),
                    ]),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

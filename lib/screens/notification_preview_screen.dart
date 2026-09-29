import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class NotificationPreviewScreen extends StatelessWidget {
  const NotificationPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Simulated Notification'),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(gradient: AppColors.mainGradient, borderRadius: BorderRadius.circular(6)),
                    ),
                    const SizedBox(width: 10),
                    Text('GeoRemind · now', style: AppText.body(size: 11.5, weight: FontWeight.w600, color: AppColors.textMid)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.location_on, size: 15, color: AppColors.textHi),
                    const SizedBox(width: 8),
                    Expanded(child: Text("You're near Reliance Smart", style: AppText.body(size: 13.5, weight: FontWeight.w700))),
                  ]),
                  const SizedBox(height: 4),
                  Text('🔔 Don\'t forget to buy groceries!', style: AppText.body(size: 13)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: AppButton(
                        label: 'Done',
                        style: AppButtonStyle.secondary,
                        onTap: () {
                          final r = appState.reminders.firstWhere((x) => x.id == 1, orElse: () => appState.reminders.first);
                          appState.completeReminder(r.id);
                          showAppToast(context, 'Marked as complete');
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        label: 'Snooze',
                        style: AppButtonStyle.secondary,
                        onTap: () => showAppToast(context, 'Snoozed 30 min'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        label: 'Open',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              "This simulates the real-world geofence-triggered notification a user receives on arrival. Wire it up with flutter_local_notifications + a geofencing plugin (e.g. geofence_service) for the real thing.",
              style: AppText.body(size: 11.5, color: AppColors.textLow),
            ),
          ],
        ),
      ),
    );
  }
}

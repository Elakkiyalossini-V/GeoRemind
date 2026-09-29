import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class SmartSuggestionScreen extends StatelessWidget {
  const SmartSuggestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Smart Suggestion'),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('🤖', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Text('I noticed a pattern', style: AppText.body(size: 15, weight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 10),
                  Text(
                    'You usually visit the supermarket on Saturday evenings and often create grocery reminders around that time.',
                    style: AppText.body(size: 13.5, color: AppColors.textMid, weight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text('Would you like me to create a grocery reminder for your next visit?',
                textAlign: TextAlign.center, style: AppText.body(size: 14, weight: FontWeight.w600)),
            const SizedBox(height: 16),
            AppButton(
              label: 'Create Reminder',
              onTap: () {
                appState.pending = PendingReminder(
                  task: 'Buy groceries',
                  icon: '🛒',
                  placeName: 'Reliance Smart',
                  placeAddr: 'Big Bazaar Street, Kumbakonam',
                  radius: 150,
                );
                appState.confirmPending();
                showAppToast(context, 'Reminder created');
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 10),
            AppButton(label: 'Not Now', style: AppButtonStyle.secondary, onTap: () => Navigator.of(context).pop()),
            const SizedBox(height: 10),
            AppButton(
              label: "Don't Suggest This Again",
              style: AppButtonStyle.ghost,
              onTap: () {
                showAppToast(context, "Won't suggest this again");
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 16),
            Text('Simulated example of GeoRemind\'s future ML-powered personalization engine.',
                textAlign: TextAlign.center, style: AppText.body(size: 11, color: AppColors.textLow)),
          ],
        ),
      ),
    );
  }
}

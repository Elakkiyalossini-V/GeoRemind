import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const TabHeader(eyebrow: 'Insights', title: 'Your Analytics'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Reminder Completion'),
                  Row(children: [
                    const ProgressRing(percent: 78),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Completed', style: AppText.body(size: 12.5, color: AppColors.textMid)),
                            Text('78%', style: AppText.mono(size: 13, weight: FontWeight.w600, color: AppColors.emerald)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Missed', style: AppText.body(size: 12.5, color: AppColors.textMid)),
                            Text('22%', style: AppText.mono(size: 13, weight: FontWeight.w600, color: AppColors.danger)),
                          ],
                        ),
                      ]),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionLabel('Most Active Locations'),
                  BarRow(label: 'College', percent: 86),
                  SizedBox(height: 10),
                  BarRow(label: 'Home', percent: 64),
                  SizedBox(height: 10),
                  BarRow(label: 'Supermarket', percent: 52),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: AppCard(
                  child: Column(children: [
                    Text('6:00 PM', style: AppText.mono(size: 20, weight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Most active time', style: AppText.body(size: 11, color: AppColors.textMid), textAlign: TextAlign.center),
                  ]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppCard(
                  child: Column(children: [
                    const Text('🛒', style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 4),
                    Text('Top category: Shopping', style: AppText.body(size: 11, color: AppColors.textMid), textAlign: TextAlign.center),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            Text('Sample data — wire this up to real events once geofence logging is in place.',
                style: AppText.body(size: 11, color: AppColors.textLow), textAlign: TextAlign.center),
          ]),
        ),
      ],
    );
  }
}

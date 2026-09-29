import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../models/models.dart';
import 'reminder_details_screen.dart';
import 'create_reminder_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final activeReminders = appState.reminders
            .where((r) => r.status == ReminderStatus.active)
            .toList();

        return ListView(
          padding: const EdgeInsets.only(bottom: 30),
          children: [
            // ------------------------------------------------------------
            // HEADER
            // ------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: AppText.body(
                            size: 13,
                            color: AppColors.textMid,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          appState.userName.isEmpty
                              ? 'Welcome'
                              : appState.userName,
                          style: AppText.display(size: 24),
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.purple2,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // ------------------------------------------------------------
            // LOCATION MONITORING CARD
            // ------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: GlassCard(
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.near_me_rounded,
                        color: AppColors.emerald,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location monitoring',
                            style: AppText.body(
                              size: 13.5,
                              weight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            activeReminders.isEmpty
                                ? 'No active reminders'
                                : '${activeReminders.length} active '
                                    '${activeReminders.length == 1 ? 'reminder' : 'reminders'}',
                            style: AppText.body(
                              size: 12,
                              color: AppColors.textMid,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activeReminders.isEmpty
                                ? 'Create a reminder to start monitoring'
                                : 'Monitoring your saved places',
                            style: AppText.body(
                              size: 11.5,
                              color: AppColors.textLow,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: activeReminders.isEmpty
                            ? AppColors.textLow
                            : AppColors.emerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ------------------------------------------------------------
            // UPCOMING REMINDERS
            // ------------------------------------------------------------
            SectionLabel('Upcoming reminders'),

            if (activeReminders.isEmpty)
              const EmptyState(
                icon: Icons.notifications_off_rounded,
                title: 'Nothing active',
                subtitle: 'Create a reminder to see it here.',
              )
            else
              ...activeReminders.map(
                (r) => ListRow(
                  leading: PinBadge(
                    emoji: r.icon,
                    size: 40,
                  ),
                  title: Text(
                    r.task,
                    style: AppText.body(
                      size: 14,
                      weight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 12,
                        color: AppColors.textMid,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${r.place} · ${r.when}',
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(
                            size: 12,
                            color: AppColors.textMid,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: const [
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.textMid,
                    ),
                  ],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReminderDetailsScreen(
                        reminderId: r.id,
                      ),
                    ),
                  ),
                ),
              ),

            // ------------------------------------------------------------
            // CREATE REMINDER
            // ------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: AppButton(
                label: 'Create a new reminder',
                icon: Icons.add_rounded,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CreateReminderScreen(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Text(
                  'Choose a place and get notified when it matters.',
                  textAlign: TextAlign.center,
                  style: AppText.body(
                    size: 11.5,
                    color: AppColors.textLow,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
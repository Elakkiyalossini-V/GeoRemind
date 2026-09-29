import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ReminderDetailsScreen extends StatelessWidget {
  final int reminderId;
  const ReminderDetailsScreen({super.key, required this.reminderId});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final r = appState.reminders.firstWhere((x) => x.id == reminderId, orElse: () => appState.reminders.first);
        return Scaffold(
          appBar: const AppTopBar(title: 'Reminder Details'),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
            children: [
              Row(children: [
                PinBadge(emoji: r.icon, size: 54),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.task, style: AppText.display(size: 19)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.glassFill2, borderRadius: BorderRadius.circular(7)),
                        child: Text(r.status.name.toUpperCase(), style: AppText.mono(size: 10.5, color: AppColors.textMid)),
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              AppCard(
                child: Column(children: [
                  DetailRow(icon: Icons.location_on_outlined, label: 'Location', value: r.place),
                  const SizedBox(height: 10),
                  const DetailRow(icon: Icons.my_location_rounded, label: 'Trigger type', value: 'Enter location'),
                  const SizedBox(height: 10),
                  DetailRow(icon: Icons.map_outlined, label: 'Radius', value: '${r.radius} m'),
                  const SizedBox(height: 10),
                  DetailRow(icon: Icons.schedule_rounded, label: 'Created', value: r.created),
                ]),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Test Notification',
                icon: Icons.notifications_active_outlined,
                style: AppButtonStyle.secondary,
                onTap: () => showAppToast(context, 'Test notification sent'),
              ),
              const SizedBox(height: 10),
              AppButton(
                label: 'Edit Reminder',
                icon: Icons.edit_outlined,
                style: AppButtonStyle.secondary,
                onTap: () => showAppToast(context, 'Editing reminder'),
              ),
              const SizedBox(height: 10),
              AppButton(
                label: 'Delete Reminder',
                icon: Icons.delete_outline_rounded,
                style: AppButtonStyle.danger,
                onTap: () {
                  appState.deleteReminder(r.id);
                  showAppToast(context, 'Reminder deleted');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'reminder_details_screen.dart';
import 'create_reminder_screen.dart';
import 'places_screen.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TabHeader(eyebrow: 'Manage', title: 'Reminders'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TabBar(
            controller: _tab,
            indicatorColor: AppColors.emerald,
            labelColor: AppColors.textHi,
            unselectedLabelColor: AppColors.textLow,
            labelStyle: AppText.body(size: 13, weight: FontWeight.w600),
            tabs: const [Tab(text: 'Reminders'), Tab(text: 'Places')],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: const [_RemindersList(), PlacesScreen(embedded: true)],
          ),
        ),
      ],
    );
  }
}

class _RemindersList extends StatelessWidget {
  const _RemindersList();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final filtered = appState.filteredReminders;
        return ListView(
          padding: const EdgeInsets.only(top: 14, bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: ReminderStatus.values
                    .map((f) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: AppChip(
                            label: f.name[0].toUpperCase() + f.name.substring(1),
                            active: appState.reminderFilter == f,
                            onTap: () => appState.setReminderFilter(f),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            if (filtered.isEmpty)
              const EmptyState(icon: Icons.notifications_off_rounded, title: 'Nothing here yet', subtitle: 'Reminders you create will show up in this tab.')
            else
              ...filtered.map((r) => ListRow(
                    leading: PinBadge(emoji: r.icon, size: 40),
                    title: Text(r.task, style: AppText.body(size: 14, weight: FontWeight.w600)),
                    subtitle: Row(children: [
                      const Icon(Icons.location_on, size: 12, color: AppColors.textMid),
                      const SizedBox(width: 4),
                      Expanded(child: Text('${r.place} · ${r.when} · Location based', style: AppText.body(size: 12, color: AppColors.textMid), overflow: TextOverflow.ellipsis)),
                    ]),
                    trailing: const [Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textMid)],
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReminderDetailsScreen(reminderId: r.id))),
                  )),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: AppButton(
                label: 'Create Reminder',
                icon: Icons.add_rounded,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateReminderScreen())),
              ),
            ),
          ],
        );
      },
    );
  }
}

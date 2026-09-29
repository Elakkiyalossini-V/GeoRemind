import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

const _emojiChoices = ['🛒', '📚', '👔', '💊', '🦷', '🏋️', '📦', '🚗', '💼', '📌'];

class CreateReminderScreen extends StatefulWidget {
  const CreateReminderScreen({super.key});

  @override
  State<CreateReminderScreen> createState() => _CreateReminderScreenState();
}

class _CreateReminderScreenState extends State<CreateReminderScreen> {
  final _taskController = TextEditingController();
  String _icon = '📌';
  Place? _place;
  double _radius = 120;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Create Reminder'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
        children: [
          Text('What should I remind you?', style: AppText.body(size: 12.5, color: AppColors.textMid)),
          const SizedBox(height: 8),
          TextField(
            controller: _taskController,
            style: AppText.body(size: 14.5),
            decoration: InputDecoration(
              hintText: 'e.g. Buy groceries',
              hintStyle: AppText.body(size: 14, color: AppColors.textLow),
              filled: true,
              fillColor: AppColors.surface2,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 18),
          Text('Icon', style: AppText.body(size: 12.5, color: AppColors.textMid)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _emojiChoices
                .map((e) => InkWell(
                      onTap: () => setState(() => _icon = e),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _icon == e ? AppColors.emerald.withOpacity(0.14) : AppColors.glassFill,
                          border: Border.all(color: _icon == e ? AppColors.emerald : AppColors.glassBorder),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 19)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 18),
          Text('Location', style: AppText.body(size: 12.5, color: AppColors.textMid)),
          const SizedBox(height: 8),
          ...appState.places.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => setState(() => _place = p),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _place?.id == p.id ? AppColors.emerald.withOpacity(0.1) : AppColors.glassFill,
                      border: Border.all(color: _place?.id == p.id ? AppColors.emerald.withOpacity(0.5) : AppColors.glassBorder),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(children: [
                      PinBadge(emoji: p.icon, size: 34),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: AppText.body(size: 13.5, weight: FontWeight.w600)),
                            Text(p.addr, style: AppText.body(size: 11.5, color: AppColors.textMid)),
                          ],
                        ),
                      ),
                      if (_place?.id == p.id) const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 18),
                    ]),
                  ),
                ),
              )),
          const SizedBox(height: 8),
          Text('Geofence radius: ${_radius.round()} m', style: AppText.body(size: 12.5, color: AppColors.textMid)),
          Slider(
            value: _radius,
            min: 50,
            max: 300,
            divisions: 25,
            activeColor: AppColors.emerald,
            inactiveColor: AppColors.glassFill2,
            onChanged: (v) => setState(() => _radius = v),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Save Reminder',
            icon: Icons.check_rounded,
            onTap: () {
              if (_taskController.text.trim().isEmpty || _place == null) {
                showAppToast(context, 'Add a task and pick a location first');
                return;
              }
              appState.pending = PendingReminder(
                task: _taskController.text.trim(),
                icon: _icon,
                placeName: _place!.name,
                placeAddr: _place!.addr,
                radius: _radius.round(),
              );
              appState.confirmPending();
              showAppToast(context, 'Reminder saved');
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

const _toggleLabels = [
  'Chat history',
  'Location history',
  'Activity learning',
  'AI personalization',
  'Notification preferences',
  'Voice assistant settings',
  'Light / Dark mode',
];

class SettingsDetailScreen extends StatefulWidget {
  final String label;
  const SettingsDetailScreen({super.key, required this.label});

  @override
  State<SettingsDetailScreen> createState() => _SettingsDetailScreenState();
}

class _SettingsDetailScreenState extends State<SettingsDetailScreen> {
  bool _enabled = true;
  bool _sync = false;

  @override
  Widget build(BuildContext context) {
    final isDanger = widget.label.startsWith('Delete');
    final isToggle = _toggleLabels.contains(widget.label);

    return Scaffold(
      appBar: AppTopBar(title: widget.label),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
        child: isDanger
            ? Column(children: [
                AppCard(
                  child: Text(
                    'This action is permanent and cannot be undone. Wire this up to a confirmation dialog and your backend before shipping.',
                    style: AppText.body(size: 13, color: AppColors.textMid),
                  ),
                ),
                const SizedBox(height: 14),
                AppButton(
                  label: widget.label,
                  icon: Icons.delete_outline_rounded,
                  style: AppButtonStyle.danger,
                  onTap: () {
                    showAppToast(context, '${widget.label} — simulated');
                    Navigator.of(context).pop();
                  },
                ),
              ])
            : isToggle
                ? Column(children: [
                    AppCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Enable ${widget.label.toLowerCase()}', style: AppText.body(size: 13.5)),
                          AppSwitch(value: _enabled, onChanged: (v) => setState(() => _enabled = v)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sync across devices', style: AppText.body(size: 13.5)),
                          AppSwitch(value: _sync, onChanged: (v) => setState(() => _sync = v)),
                        ],
                      ),
                    ),
                  ])
                : AppCard(
                    child: Text(
                      'GeoRemind — version 1.0\nAI-powered, location-aware personal reminder assistant.',
                      style: AppText.body(size: 13, color: AppColors.textMid),
                    ),
                  ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

enum _VoiceStage { listening, heard, understood }

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> with SingleTickerProviderStateMixin {
  _VoiceStage _stage = _VoiceStage.listening;
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();

  void _simulate() {
    setState(() => _stage = _VoiceStage.heard);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _stage = _VoiceStage.understood);
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Voice Assistant'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 88,
              height: 88,
              child: Stack(alignment: Alignment.center, children: [
                if (_stage == _VoiceStage.listening)
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, child) {
                      final t = _pulse.value;
                      return Opacity(
                        opacity: (1 - t) * 0.5,
                        child: Transform.scale(
                          scale: 0.7 + t * 1.2,
                          child: Container(decoration: const BoxDecoration(gradient: AppColors.mainGradient, shape: BoxShape.circle)),
                        ),
                      );
                    },
                  ),
                Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(gradient: AppColors.mainGradient, shape: BoxShape.circle),
                  child: const Icon(Icons.mic_rounded, color: Colors.white, size: 34),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            Text('How can I help?', style: AppText.display(size: 19)),
            const SizedBox(height: 20),
            if (_stage == _VoiceStage.listening) Text('Listening…', style: AppText.body(size: 13, color: AppColors.textMid)),
            if (_stage == _VoiceStage.heard)
              Text('"Remind me to submit my assignment when I reach college."', textAlign: TextAlign.center, style: AppText.body(size: 13.5)),
            if (_stage == _VoiceStage.understood) ...[
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('I UNDERSTOOD', style: AppText.mono(size: 10.5, color: AppColors.textLow)),
                    const SizedBox(height: 10),
                    const DetailRow(icon: Icons.task_alt_rounded, label: 'Task', value: 'Submit assignment'),
                    const SizedBox(height: 8),
                    const DetailRow(icon: Icons.location_on_outlined, label: 'Location', value: 'ABC College'),
                    const SizedBox(height: 8),
                    const DetailRow(icon: Icons.my_location_rounded, label: 'Trigger', value: 'Enter location'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AppButton(
                label: 'Confirm Reminder',
                icon: Icons.check_rounded,
                onTap: () {
                  appState.pending = PendingReminder(
                    task: 'Submit assignment',
                    icon: '📚',
                    placeName: 'ABC College',
                    placeAddr: 'Thanjavur Rd, Kumbakonam',
                    radius: 120,
                  );
                  appState.confirmPending();
                  showAppToast(context, 'Reminder saved');
                  Navigator.of(context).pop();
                },
              ),
            ],
            const SizedBox(height: 20),
            if (_stage == _VoiceStage.listening)
              SizedBox(
                width: 220,
                child: AppButton(label: 'Simulate Voice Input', onTap: _simulate),
              ),
          ],
        ),
      ),
    );
  }
}

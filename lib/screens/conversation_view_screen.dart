import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ConversationViewScreen extends StatelessWidget {
  final int convoId;
  const ConversationViewScreen({super.key, required this.convoId});

  @override
  Widget build(BuildContext context) {
    final c = appState.chatHistory.firstWhere((x) => x.id == convoId, orElse: () => appState.chatHistory.first);
    return Scaffold(
      appBar: AppTopBar(title: c.title, subtitle: c.day),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        children: [
          _bubble(true, c.preview),
          _bubble(false, "Got it — I will set that up for you."),
          _bubble(true, "Sounds good, thanks!"),
          _bubble(false, "Reminder saved. I will let you know when you arrive."),
          const SizedBox(height: 18),
          AppButton(
            label: 'Create Reminder from Conversation',
            onTap: () => showAppToast(context, 'New reminder created from this conversation'),
          ),
        ],
      ),
    );
  }

  Widget _bubble(bool user, String text) {
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          gradient: user ? AppColors.mainGradient : null,
          color: user ? null : AppColors.surface,
          border: user ? null : Border.all(color: AppColors.glassBorder),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text, style: AppText.body(size: 13.5)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'conversation_view_screen.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<dynamic>>{};
    for (final c in appState.chatHistory) {
      groups.putIfAbsent(c.day, () => []).add(c);
    }
    return Scaffold(
      appBar: const AppTopBar(title: 'Chat History'),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                border: Border.all(color: AppColors.glassBorder),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                const Icon(Icons.search_rounded, size: 16, color: AppColors.textLow),
                const SizedBox(width: 10),
                Text('Search conversations', style: AppText.body(size: 13, color: AppColors.textLow)),
              ]),
            ),
          ),
          for (final entry in groups.entries) ...[
            SectionLabel(entry.key),
            for (final c in entry.value)
              ListRow(
                leading: PinBadge(emoji: c.icon, size: 38),
                title: Text(c.title, style: AppText.body(size: 13.5, weight: FontWeight.w600)),
                subtitle: Text(c.preview, style: AppText.body(size: 12, color: AppColors.textMid)),
                trailing: const [Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textMid)],
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ConversationViewScreen(convoId: c.id))),
              ),
          ],
        ],
      ),
    );
  }
}

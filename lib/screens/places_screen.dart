import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'add_place_screen.dart';

class PlacesScreen extends StatelessWidget {
  final bool embedded;
  const PlacesScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final body = ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 24),
          children: [
            for (final p in appState.places)
              ListRow(
                leading: PinBadge(emoji: p.icon, size: 42),
                title: Text(p.name, style: AppText.body(size: 14, weight: FontWeight.w600)),
                subtitle: Text(p.addr, style: AppText.body(size: 12, color: AppColors.textMid)),
                trailing: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textMid),
                    onPressed: () => showAppToast(context, 'Editing ${p.name}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.textMid),
                    onPressed: () {
                      appState.removePlace(p.id);
                      showAppToast(context, 'Place removed');
                    },
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: AppButton(
                label: 'Add Place',
                icon: Icons.add_rounded,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddPlaceScreen())),
              ),
            ),
          ],
        );
      },
    );

    if (embedded) return body;

    return Scaffold(
      appBar: const AppTopBar(title: 'Saved Places'),
      body: body,
    );
  }
}

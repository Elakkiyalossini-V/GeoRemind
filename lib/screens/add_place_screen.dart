import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  String? _addr;
  final _nameController = TextEditingController();

  Widget _quickOption(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            border: Border.all(color: AppColors.glassBorder),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            Icon(icon, size: 18, color: AppColors.textHi),
            const SizedBox(width: 12),
            Text(label, style: AppText.body(size: 14)),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Add Place'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
        children: [
          _quickOption(Icons.search_rounded, 'Search for a place', () => setState(() => _addr = '12 Big Bazaar Street, Kumbakonam')),
          _quickOption(Icons.map_outlined, 'Choose on map', () => showAppToast(context, 'Opening map picker')),
          _quickOption(Icons.my_location_rounded, 'Use current location', () => setState(() => _addr = 'Current Location · Kumbakonam')),
          if (_addr != null) ...[
            const SizedBox(height: 6),
            AppCard(
              child: Row(children: [
                const PinBadge(emoji: '📍', size: 40),
                const SizedBox(width: 12),
                Expanded(child: Text(_addr!, style: AppText.body(size: 13.5))),
              ]),
            ),
            const SizedBox(height: 14),
            Text('Place name', style: AppText.body(size: 12, color: AppColors.textMid)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: AppText.body(size: 14.5),
              decoration: InputDecoration(
                hintText: 'e.g. Gym',
                hintStyle: AppText.body(size: 14, color: AppColors.textLow),
                filled: true,
                fillColor: AppColors.surface2,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 14),
            AppButton(
              label: 'Save Place',
              onTap: () {
                appState.addPlace(Place(
                  id: 'p${DateTime.now().millisecondsSinceEpoch}',
                  icon: '📍',
                  name: _nameController.text.trim().isEmpty ? 'Gym' : _nameController.text.trim(),
                  addr: _addr!,
                ));
                showAppToast(context, 'Place saved');
                Navigator.of(context).pop();
              },
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CreateReminderScreen extends StatefulWidget {
const CreateReminderScreen({super.key});

@override
State<CreateReminderScreen> createState() => _CreateReminderScreenState();
}

class _CreateReminderScreenState extends State<CreateReminderScreen> {
final TextEditingController _reminderController =
TextEditingController();

@override
void dispose() {
_reminderController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text(
'Create Reminder',
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
),


  body: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What do you want to remember?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'Tell GeoRemind what you want to remember.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 25),

        TextField(
          controller: _reminderController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Example: Buy milk',
            prefixIcon: const Icon(Icons.edit_note),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        const SizedBox(height: 25),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              if (_reminderController.text.trim().isEmpty) {
                return;
              }

              Navigator.pop(
                context,
                _reminderController.text.trim(),
);
            },
            icon: const Icon(Icons.check),
            label: const Text('Create Reminder'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    ),
  ),
);

}
}

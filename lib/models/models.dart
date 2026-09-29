enum ReminderStatus { active, completed, missed }

class Reminder {
  int id;
  String task;
  String icon;
  String place;
  String when;
  int radius;
  String created;
  ReminderStatus status;

  Reminder({
    required this.id,
    required this.task,
    required this.icon,
    required this.place,
    required this.when,
    required this.radius,
    required this.created,
    this.status = ReminderStatus.active,
  });
}

class Place {
  String id;
  String icon;
  String name;
  String addr;
  double? latitude;
  double? longitude;

  Place({
    required this.id,
    required this.icon,
    required this.name,
    required this.addr,
    this.latitude,
    this.longitude,
  });
}

class ChatEntry {
  int id;
  String icon;
  String title;
  String preview;
  String day;

  ChatEntry({required this.id, required this.icon, required this.title, required this.preview, required this.day});
}

/// A reminder that's been drafted (by voice, chat, or the manual flow) but
/// not yet saved — mirrors the prototype's `S.pending` object.
class PendingReminder {
  String task;
  String icon;
  String placeName;
  String placeAddr;
  int radius;

  PendingReminder({
    this.task = '',
    this.icon = '📌',
    this.placeName = '',
    this.placeAddr = '',
    this.radius = 120,
  });
}

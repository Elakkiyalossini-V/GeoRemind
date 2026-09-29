import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/database_service.dart';

class AppState extends ChangeNotifier {
  AppState._internal();

  static final AppState instance = AppState._internal();

  final DatabaseService _db = databaseService;

  // ============================================================
  // USER
  // ============================================================

  String userName = '';
  String homeCity = '';

  double? homeLatitude;
  double? homeLongitude;
  String homeAddress = '';

  // ============================================================
  // APP DATA
  // ============================================================

  final List<Reminder> reminders = [];
  final List<Place> places = [];
  final List<ChatEntry> chatHistory = [];

  PendingReminder pending = PendingReminder();

  ReminderStatus reminderFilter = ReminderStatus.active;

  int _nextReminderId = 1;

  bool _initialized = false;

  bool get isInitialized => _initialized;

  // ============================================================
  // INITIALIZE APP STATE
  // ============================================================

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _loadUserProfile();
      await _loadPlaces();
      await _loadReminders();
      await _loadChatHistory();

      _initialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('GeoRemind initialization error: $e');

      _initialized = true;
      notifyListeners();
    }
  }

  // ============================================================
  // LOAD USER
  // ============================================================

  Future<void> _loadUserProfile() async {
    final profile = await _db.getUserProfile();

    if (profile == null) {
      return;
    }

    userName = (profile['name'] as String?) ?? '';
    homeAddress = (profile['home_address'] as String?) ?? '';
    homeCity = (profile['home_city'] as String?) ?? '';

    homeLatitude =
        (profile['home_latitude'] as num?)?.toDouble();

    homeLongitude =
        (profile['home_longitude'] as num?)?.toDouble();
  }

  // ============================================================
  // LOAD PLACES
  // ============================================================

  Future<void> _loadPlaces() async {
    final savedPlaces = await _db.getPlaces();

    places
      ..clear()
      ..addAll(savedPlaces);
  }

  // ============================================================
  // LOAD REMINDERS
  // ============================================================

  Future<void> _loadReminders() async {
    final savedReminders = await _db.getReminders();

    reminders
      ..clear()
      ..addAll(savedReminders);

    if (reminders.isNotEmpty) {
      final largestId = reminders
          .map((r) => r.id)
          .reduce((a, b) => a > b ? a : b);

      _nextReminderId = largestId + 1;
    } else {
      _nextReminderId = 1;
    }
  }

  // ============================================================
  // LOAD CHAT HISTORY
  // ============================================================

  Future<void> _loadChatHistory() async {
    final savedHistory = await _db.getChatHistory();

    chatHistory
      ..clear()
      ..addAll(savedHistory);
  }

  // ============================================================
  // USER NAME
  // ============================================================

  Future<void> setUserName(String name) async {
    userName = name.trim();

    await _saveUserProfile();

    notifyListeners();
  }

  // ============================================================
  // HOME LOCATION
  // ============================================================

  Future<void> setHomeLocation({
    required String address,
    required double latitude,
    required double longitude,
    String city = '',
  }) async {
    homeAddress = address.trim();
    homeLatitude = latitude;
    homeLongitude = longitude;
    homeCity = city.trim();

    await _saveUserProfile();

    notifyListeners();
  }

  // ============================================================
  // SAVE USER PROFILE
  // ============================================================

  Future<void> _saveUserProfile() async {
    await _db.saveUserProfile(
      name: userName,
      homeAddress: homeAddress,
      homeLatitude: homeLatitude,
      homeLongitude: homeLongitude,
      homeCity: homeCity,
    );
  }

  // ============================================================
  // REMINDERS
  // ============================================================

  List<Reminder> get filteredReminders {
    return reminders
        .where((r) => r.status == reminderFilter)
        .toList();
  }

  void setReminderFilter(ReminderStatus filter) {
    reminderFilter = filter;
    notifyListeners();
  }

  // ============================================================
  // CREATE REMINDER FROM PENDING
  // ============================================================

  Future<void> confirmPending() async {
    final reminder = Reminder(
      id: _nextReminderId++,
      task: pending.task.trim().isEmpty
          ? 'New reminder'
          : pending.task.trim(),
      icon: pending.icon,
      place: pending.placeName.trim().isEmpty
          ? pending.placeAddr.trim()
          : pending.placeName.trim(),
      when: 'On arrival',
      radius: pending.radius,
      created: _formattedCurrentDate(),
      status: ReminderStatus.active,
    );

    reminders.insert(0, reminder);

    await _db.saveReminder(reminder);

    pending = PendingReminder();

    notifyListeners();
  }

  // ============================================================
  // ADD REMINDER DIRECTLY
  // ============================================================

  Future<void> addReminder(Reminder reminder) async {
    reminders.insert(0, reminder);

    if (reminder.id >= _nextReminderId) {
      _nextReminderId = reminder.id + 1;
    }

    await _db.saveReminder(reminder);

    notifyListeners();
  }

  // ============================================================
  // COMPLETE REMINDER
  // ============================================================

  Future<void> completeReminder(int id) async {
    final index = reminders.indexWhere(
      (r) => r.id == id,
    );

    if (index == -1) return;

    reminders[index].status = ReminderStatus.completed;

    await _db.updateReminderStatus(
      id,
      ReminderStatus.completed,
    );

    notifyListeners();
  }

  // ============================================================
  // MARK MISSED
  // ============================================================

  Future<void> missReminder(int id) async {
    final index = reminders.indexWhere(
      (r) => r.id == id,
    );

    if (index == -1) return;

    reminders[index].status = ReminderStatus.missed;

    await _db.updateReminderStatus(
      id,
      ReminderStatus.missed,
    );

    notifyListeners();
  }

  // ============================================================
  // DELETE REMINDER
  // ============================================================

  Future<void> deleteReminder(int id) async {
    reminders.removeWhere(
      (r) => r.id == id,
    );

    await _db.deleteReminder(id);

    notifyListeners();
  }

  // ============================================================
  // PLACES
  // ============================================================

  Future<void> addPlace(Place place) async {
    places.add(place);

    await _db.savePlace(place);

    notifyListeners();
  }

  Future<void> removePlace(String id) async {
    places.removeWhere(
      (place) => place.id == id,
    );

    await _db.deletePlace(id);

    notifyListeners();
  }

  // ============================================================
  // CHAT HISTORY
  // ============================================================

  Future<void> addChatEntry(ChatEntry entry) async {
    chatHistory.insert(0, entry);

    await _db.saveChatEntry(entry);

    notifyListeners();
  }

  // ============================================================
  // RESET USER DATA
  // ============================================================

  Future<void> clearUserData() async {
    await _db.clearAllData();

    userName = '';
    homeCity = '';
    homeAddress = '';

    homeLatitude = null;
    homeLongitude = null;

    reminders.clear();
    places.clear();
    chatHistory.clear();

    pending = PendingReminder();
    reminderFilter = ReminderStatus.active;

    _nextReminderId = 1;

    notifyListeners();
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formattedCurrentDate() {
    final now = DateTime.now();

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[now.month - 1]} '
        '${now.day}, '
        '${now.year}';
  }
}

final appState = AppState.instance;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm.dart';

class AlarmService extends ChangeNotifier {
  static AlarmService? _instance;
  static AlarmService get instance {
    _instance ??= AlarmService._internal();
    return _instance!;
  }

  AlarmService._internal() {
    _loadAlarms();
  }

  List<Alarm> _alarms = [];
  static const String _alarmsKey = 'alarms';

  List<Alarm> get alarms => _alarms.where((alarm) => alarm.isEnabled).toList();
  List<Alarm> get allAlarms => _alarms;

  Future<void> _loadAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alarmsJson = prefs.getStringList(_alarmsKey) ?? [];
      
      _alarms = alarmsJson
          .map((json) => Alarm.fromJson(jsonDecode(json)))
          .toList();
      
      // Migrate legacy default sound to the new bundled alarm sound
      const String newDefaultSound = 'assets/sounds/alarm-ambience.mp3';
      bool updated = false;
      _alarms = _alarms.map((alarm) {
        if (alarm.sound == 'default') {
          updated = true;
          return alarm.copyWith(sound: newDefaultSound);
        }
        return alarm;
      }).toList();
      if (updated) {
        await _saveAlarms();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading alarms: $e');
    }
  }

  Future<void> _saveAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alarmsJson = _alarms
          .map((alarm) => jsonEncode(alarm.toJson()))
          .toList();
      
      await prefs.setStringList(_alarmsKey, alarmsJson);
    } catch (e) {
      debugPrint('Error saving alarms: $e');
    }
  }

  Future<void> addAlarm(Alarm alarm) async {
    _alarms.add(alarm);
    await _saveAlarms();
    notifyListeners();
  }

  Future<void> updateAlarm(Alarm alarm) async {
    final index = _alarms.indexWhere((a) => a.id == alarm.id);
    if (index != -1) {
      _alarms[index] = alarm;
      await _saveAlarms();
      notifyListeners();
    }
  }

  Future<void> deleteAlarm(String alarmId) async {
    _alarms.removeWhere((alarm) => alarm.id == alarmId);
    await _saveAlarms();
    notifyListeners();
  }

  Future<void> toggleAlarm(String alarmId) async {
    final index = _alarms.indexWhere((a) => a.id == alarmId);
    if (index != -1) {
      final alarm = _alarms[index];
      _alarms[index] = alarm.copyWith(isEnabled: !alarm.isEnabled);
      await _saveAlarms();
      notifyListeners();
    }
  }

  Alarm? getAlarm(String alarmId) {
    try {
      return _alarms.firstWhere((alarm) => alarm.id == alarmId);
    } catch (e) {
      return null;
    }
  }

  List<Alarm> getAlarmsForDay(int dayOfWeek) {
    return _alarms.where((alarm) => 
      alarm.isEnabled && 
      (alarm.repeatDays.isEmpty || alarm.repeatDays.contains(dayOfWeek))
    ).toList();
  }

  List<Alarm> getTodayAlarms() {
    final now = DateTime.now();
    final today = now.weekday;
    return getAlarmsForDay(today);
  }

  bool hasActiveAlarms() {
    return _alarms.any((alarm) => alarm.isEnabled);
  }

  void clearAllAlarms() {
    _alarms.clear();
    _saveAlarms();
    notifyListeners();
  }

  // Generate unique alarm ID
  String generateAlarmId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Check if alarm should trigger now
  bool shouldTriggerAlarm(Alarm alarm) {
    final now = DateTime.now();
    final alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );

    // Check if it's time for the alarm
    if (alarm.repeatDays.isEmpty) {
      // One-time alarm
      return now.isAfter(alarmTime) && 
             now.difference(alarmTime).inMinutes < 1;
    } else {
      // Repeating alarm
      final today = now.weekday;
      if (alarm.repeatDays.contains(today)) {
        return now.isAfter(alarmTime) && 
               now.difference(alarmTime).inMinutes < 1;
      }
      return false;
    }
  }

  // Get next trigger time for an alarm
  DateTime? getNextTriggerTime(Alarm alarm) {
    final now = DateTime.now();
    final today = now.weekday;
    
    if (alarm.repeatDays.isEmpty) {
      // One-time alarm
      final alarmTime = DateTime(
        now.year,
        now.month,
        now.day,
        alarm.time.hour,
        alarm.time.minute,
      );
      
      if (now.isBefore(alarmTime)) {
        return alarmTime;
      } else {
        return null; // Already passed
      }
    } else {
      // Repeating alarm
      final nextAlarmDay = _getNextAlarmDay(alarm.repeatDays, today);
      if (nextAlarmDay != null) {
        final daysToAdd = (nextAlarmDay - today) % 7;
        final nextDate = now.add(Duration(days: daysToAdd));
        return DateTime(
          nextDate.year,
          nextDate.month,
          nextDate.day,
          alarm.time.hour,
          alarm.time.minute,
        );
      }
    }
    return null;
  }

  int? _getNextAlarmDay(List<int> repeatDays, int currentDay) {
    for (int i = 1; i <= 7; i++) {
      final day = ((currentDay + i - 1) % 7) + 1;
      if (repeatDays.contains(day)) {
        return day;
      }
    }
    return null;
  }

  // Check for due alarms and mark them as triggered to avoid duplicate rings
  List<Alarm> checkAndMarkDueAlarms() {
    final now = DateTime.now();
    final List<Alarm> dueAlarms = [];

    for (final alarm in _alarms) {
      if (!alarm.isEnabled) continue;
      if (shouldTriggerAlarm(alarm)) {
        final recentlyTriggered = alarm.lastTriggered != null &&
            now.difference(alarm.lastTriggered!).inMinutes < 1;
        if (!recentlyTriggered) {
          final updated = alarm.copyWith(lastTriggered: now);
          final index = _alarms.indexWhere((a) => a.id == alarm.id);
          if (index != -1) {
            _alarms[index] = updated;
          }
          dueAlarms.add(updated);
        }
      }
    }

    if (dueAlarms.isNotEmpty) {
      _saveAlarms();
      notifyListeners();
    }

    return dueAlarms;
  }
} 
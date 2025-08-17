import 'package:flutter/material.dart';

class Alarm {
  final String id;
  final TimeOfDay time;
  final String label;
  final bool isEnabled;
  final List<int> repeatDays; // 1=Monday, 2=Tuesday, etc., 0=No repeat
  final bool isVibrate;
  final String sound;
  final bool isSnoozeEnabled;
  final int snoozeDuration; // in minutes
  final DateTime? lastTriggered;
  final DateTime? nextTrigger;

  Alarm({
    required this.id,
    required this.time,
    this.label = 'Alarm',
    this.isEnabled = true,
    this.repeatDays = const [],
    this.isVibrate = true,
    this.sound = 'assets/sounds/alarm-ambience.mp3',
    this.isSnoozeEnabled = true,
    this.snoozeDuration = 5,
    this.lastTriggered,
    this.nextTrigger,
  });

  Alarm copyWith({
    String? id,
    TimeOfDay? time,
    String? label,
    bool? isEnabled,
    List<int>? repeatDays,
    bool? isVibrate,
    String? sound,
    bool? isSnoozeEnabled,
    int? snoozeDuration,
    DateTime? lastTriggered,
    DateTime? nextTrigger,
  }) {
    return Alarm(
      id: id ?? this.id,
      time: time ?? this.time,
      label: label ?? this.label,
      isEnabled: isEnabled ?? this.isEnabled,
      repeatDays: repeatDays ?? this.repeatDays,
      isVibrate: isVibrate ?? this.isVibrate,
      sound: sound ?? this.sound,
      isSnoozeEnabled: isSnoozeEnabled ?? this.isSnoozeEnabled,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
      lastTriggered: lastTriggered ?? this.lastTriggered,
      nextTrigger: nextTrigger ?? this.nextTrigger,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'label': label,
      'isEnabled': isEnabled,
      'repeatDays': repeatDays,
      'isVibrate': isVibrate,
      'sound': sound,
      'isSnoozeEnabled': isSnoozeEnabled,
      'snoozeDuration': snoozeDuration,
      'lastTriggered': lastTriggered?.toIso8601String(),
      'nextTrigger': nextTrigger?.toIso8601String(),
    };
  }

  factory Alarm.fromJson(Map<String, dynamic> json) {
    final timeParts = json['time'].split(':');
    final time = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    return Alarm(
      id: json['id'],
      time: time,
      label: json['label'],
      isEnabled: json['isEnabled'],
      repeatDays: List<int>.from(json['repeatDays']),
      isVibrate: json['isVibrate'],
      sound: json['sound'],
      isSnoozeEnabled: json['isSnoozeEnabled'],
      snoozeDuration: json['snoozeDuration'],
      lastTriggered: json['lastTriggered'] != null ? DateTime.parse(json['lastTriggered']) : null,
      nextTrigger: json['nextTrigger'] != null ? DateTime.parse(json['nextTrigger']) : null,
    );
  }

  String get timeString {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String get repeatString {
    if (repeatDays.isEmpty) return 'No repeat';
    if (repeatDays.length == 7) return 'Every day';
    if (repeatDays.length == 5 && !repeatDays.contains(6) && !repeatDays.contains(7)) return 'Weekdays';
    if (repeatDays.length == 2 && repeatDays.contains(6) && repeatDays.contains(7)) return 'Weekends';
    
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return repeatDays.map((day) => days[day - 1]).join(', ');
  }

  bool get isRepeating => repeatDays.isNotEmpty;
} 
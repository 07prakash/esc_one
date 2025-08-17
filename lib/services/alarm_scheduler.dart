import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/alarm.dart';
import 'alarm_service.dart';
import 'sound_service.dart';
import '../screens/alarm_ringing_screen.dart';
import '../utils/nav_key.dart';

/// Simple in-app scheduler that periodically checks due alarms
/// and plays their sound using [SoundService].
///
/// Note: This works only while the app is running in foreground.
class AlarmScheduler {
  AlarmScheduler._internal();
  static final AlarmScheduler _instance = AlarmScheduler._internal();
  static AlarmScheduler get instance => _instance;

  final AlarmService _alarmService = AlarmService.instance;
  final SoundService _soundService = SoundService.instance;

  Timer? _timer;
  bool _isRunning = false;

  void start({Duration interval = const Duration(seconds: 5)}) {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(interval, (_) => _tick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  Future<void> _tick() async {
    try {
      final List<Alarm> dueAlarms = _alarmService.checkAndMarkDueAlarms();
      if (dueAlarms.isNotEmpty) {
        final alarm = dueAlarms.first;
        await _soundService.playAlarm(alarm.sound);
        final context = AppNavigatorKey.instance.currentContext;
        if (context != null) {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: true,
              barrierDismissible: false,
              pageBuilder: (_, __, ___) => AlarmRingingScreen(alarm: alarm),
              transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('AlarmScheduler tick error: $e');
      }
    }
  }
}



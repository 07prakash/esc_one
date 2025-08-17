import 'package:flutter/material.dart';

import '../models/alarm.dart';
import '../services/alarm_service.dart';
import '../services/sound_service.dart';

class AlarmRingingScreen extends StatefulWidget {
  final Alarm alarm;
  const AlarmRingingScreen({super.key, required this.alarm});

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen> {
  final SoundService _soundService = SoundService.instance;
  final AlarmService _alarmService = AlarmService.instance;

  @override
  void initState() {
    super.initState();
    _soundService.playAlarm(widget.alarm.sound);
  }

  @override
  void dispose() {
    _soundService.stop();
    super.dispose();
  }

  void _dismiss() {
    final next = _alarmService.getNextTriggerTime(widget.alarm);
    final updated = widget.alarm.copyWith(
      isEnabled: next != null,
      nextTrigger: next,
    );
    _alarmService.updateAlarm(updated);
    Navigator.of(context).pop();
  }

  void _snooze() {
    final snoozeMinutes = widget.alarm.snoozeDuration;
    final snoozeUntil = DateTime.now().add(Duration(minutes: snoozeMinutes));
    final updated = widget.alarm.copyWith(nextTrigger: snoozeUntil);
    _alarmService.updateAlarm(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.alarm_rounded, size: 96, color: Colors.white),
                const SizedBox(height: 24),
                Text(
                  widget.alarm.label,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.alarm.time.hour.toString().padLeft(2, '0')}:${widget.alarm.time.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _dismiss,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: const Text(
                          'Dismiss',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.alarm.isSnoozeEnabled ? _snooze : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6366f1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.snooze_rounded),
                        label: Text(
                          widget.alarm.isSnoozeEnabled ? 'Snooze ${'${widget.alarm.snoozeDuration}m'}' : 'Snooze Off',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



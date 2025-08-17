import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class DetoxEnforcer extends ChangeNotifier {
  bool _isDetoxActive = false;
  DateTime? _detoxStartTime;
  Duration? _detoxDuration;

  // Progress tracking
  int _completedSessions = 0;
  int _failedSessions = 0;
  Duration _totalDetoxTime = Duration.zero;
  Duration _savedTime = Duration.zero;

  bool get isDetoxActive => _isDetoxActive;
  DateTime? get detoxStartTime => _detoxStartTime;
  Duration? get detoxDuration => _detoxDuration;
  
  // Progress getters
  int get completedSessions => _completedSessions;
  int get failedSessions => _failedSessions;
  Duration get totalDetoxTime => _totalDetoxTime;
  Duration get savedTime => _savedTime;
  
  // Initialize detox enforcer
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isDetoxActive = prefs.getBool(AppConstants.keyDetoxActive) ?? false;
    
    if (_isDetoxActive) {
      final startTimeMillis = prefs.getInt(AppConstants.keyDetoxStartTime);
      final durationSeconds = prefs.getInt(AppConstants.keyDetoxDuration);
      
      if (startTimeMillis != null && durationSeconds != null) {
        _detoxStartTime = DateTime.fromMillisecondsSinceEpoch(startTimeMillis);
        _detoxDuration = Duration(seconds: durationSeconds);
      }
      
      // Notify native code about detox state
      try {
        await platform.invokeMethod('setDetoxActive', true);
      } catch (e) {
        debugPrint('Failed to communicate with native code: $e');
      }
    }
    
    // Load progress data
    _completedSessions = prefs.getInt(AppConstants.keyCompletedSessions) ?? 0;
    _failedSessions = prefs.getInt(AppConstants.keyFailedSessions) ?? 0;
    _totalDetoxTime = Duration(seconds: prefs.getInt(AppConstants.keyTotalDetoxTime) ?? 0);
    _savedTime = Duration(seconds: prefs.getInt(AppConstants.keySavedTime) ?? 0);
    
    notifyListeners();
  }
  
  // Method channel for native communication
  static const platform = MethodChannel('com.example.esc_one/detox');
  
  // Start detox mode
  Future<void> startDetox(DateTime startTime, Duration duration) async {
    _isDetoxActive = true;
    _detoxStartTime = startTime;
    _detoxDuration = duration;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyDetoxActive, true);
    await prefs.setInt(AppConstants.keyDetoxStartTime, startTime.millisecondsSinceEpoch);
    await prefs.setInt(AppConstants.keyDetoxDuration, duration.inSeconds);
    
    // Notify native code about detox state
    try {
      await platform.invokeMethod('setDetoxActive', true);
    } catch (e) {
      debugPrint('Failed to communicate with native code: $e');
    }
    
    notifyListeners();
  }
  
  // End detox mode
  Future<void> endDetox() async {
    _isDetoxActive = false;
    _detoxStartTime = null;
    _detoxDuration = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyDetoxActive, false);
    await prefs.remove(AppConstants.keyDetoxStartTime);
    await prefs.remove(AppConstants.keyDetoxDuration);
    
    // Notify native code about detox state
    try {
      await platform.invokeMethod('setDetoxActive', false);
    } catch (e) {
      debugPrint('Failed to communicate with native code: $e');
    }
    
    notifyListeners();
  }
  
  // Complete detox session
  Future<void> completeSession() async {
    _completedSessions++;
    _totalDetoxTime += _detoxDuration ?? Duration.zero;
    _savedTime += _detoxDuration ?? Duration.zero;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyCompletedSessions, _completedSessions);
    await prefs.setInt(AppConstants.keyTotalDetoxTime, _totalDetoxTime.inSeconds);
    await prefs.setInt(AppConstants.keySavedTime, _savedTime.inSeconds);
    
    notifyListeners();
  }
  
  // Fail detox session
  Future<void> failSession() async {
    _failedSessions++;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyFailedSessions, _failedSessions);
    
    notifyListeners();
  }
  
  // Update detox duration (for extending sessions)
  Future<void> updateDetoxDuration(Duration newDuration) async {
    if (!_isDetoxActive) return;
    
    _detoxDuration = newDuration;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyDetoxDuration, newDuration.inSeconds);
    
    notifyListeners();
  }
  
  // Check if app is allowed during detox
  bool isAppAllowed(String packageName) {
    if (!_isDetoxActive) return true;
    
    return AppConstants.essentialApps.contains(packageName);
  }
  
  // Get remaining detox time
  Duration get remainingTime {
    if (!_isDetoxActive || _detoxStartTime == null || _detoxDuration == null) {
      return Duration.zero;
    }
    
    final now = DateTime.now();
    final elapsed = now.difference(_detoxStartTime!);
    final remaining = _detoxDuration! - elapsed;
    
    return remaining.isNegative ? Duration.zero : remaining;
  }
  
  // Check if detox is completed
  bool get isDetoxCompleted {
    return _isDetoxActive && remainingTime.isNegative;
  }
  
  // Calculate detox progress
  double get detoxProgress {
    if (!_isDetoxActive || _detoxStartTime == null || _detoxDuration == null) {
      return 0.0;
    }
    
    final now = DateTime.now();
    final elapsed = now.difference(_detoxStartTime!);
    final progress = elapsed.inSeconds / _detoxDuration!.inSeconds;
    
    return progress.clamp(0.0, 1.0);
  }
  
  // Get detox status message
  String get detoxStatusMessage {
    if (!_isDetoxActive) return 'No active detox';
    
    if (isDetoxCompleted) return 'Detox completed!';
    
    final remaining = remainingTime;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m remaining';
    } else {
      return '${minutes}m remaining';
    }
  }
} 
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/detox_session.dart';

class TimerService extends ChangeNotifier {
  Timer? _timer;
  DetoxSession? _currentSession;
  bool _isRunning = false;
  VoidCallback? _onTimerCompleted;
  
  DetoxSession? get currentSession => _currentSession;
  bool get isRunning => _isRunning;
  
  // Start timer for a detox session
  void startTimer(DetoxSession session, {VoidCallback? onCompleted}) {
    _currentSession = session;
    _isRunning = true;
    _onTimerCompleted = onCompleted;
    
    // Cancel existing timer if any
    _timer?.cancel();
    
    // Start periodic timer (update every second)
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSession != null && _currentSession!.isCompleted) {
        _stopTimer();
        _onTimerCompleted?.call();
        return;
      }
      notifyListeners();
    });
    
    notifyListeners();
  }
  
  // Stop the timer
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        isActive: false,
        endTime: DateTime.now(),
      );
    }
    
    notifyListeners();
  }
  
  // Stop timer manually
  void stopTimer() {
    _stopTimer();
  }
  
  // Pause timer (optional feature)
  void pauseTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    notifyListeners();
  }
  
  // Resume timer
  void resumeTimer() {
    if (_currentSession != null && !_currentSession!.isCompleted) {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_currentSession != null && _currentSession!.isCompleted) {
          _stopTimer();
          return;
        }
        notifyListeners();
      });
      notifyListeners();
    }
  }
  
  // Get remaining time
  Duration get remainingTime {
    if (_currentSession == null) return Duration.zero;
    return _currentSession!.remainingTime;
  }
  
  // Get progress percentage
  double get progress {
    if (_currentSession == null) return 0.0;
    return _currentSession!.progress;
  }
  
  // Check if session is completed
  bool get isCompleted {
    if (_currentSession == null) return false;
    return _currentSession!.isCompleted;
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
} 
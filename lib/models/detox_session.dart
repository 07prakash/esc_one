class DetoxSession {
  final DateTime startTime;
  final Duration duration;
  final bool isActive;
  final DateTime? endTime;
  
  DetoxSession({
    required this.startTime,
    required this.duration,
    this.isActive = true,
    this.endTime,
  });
  
  // Calculate remaining time
  Duration get remainingTime {
    if (!isActive) return Duration.zero;
    
    final now = DateTime.now();
    final elapsed = now.difference(startTime);
    final remaining = duration - elapsed;
    
    return remaining.isNegative ? Duration.zero : remaining;
  }
  
  // Check if session is completed
  bool get isCompleted {
    return !isActive || remainingTime.isNegative;
  }
  
  // Calculate progress percentage
  double get progress {
    if (duration.inSeconds == 0) return 0.0;
    
    final now = DateTime.now();
    final elapsed = now.difference(startTime);
    final progress = elapsed.inSeconds / duration.inSeconds;
    
    return progress.clamp(0.0, 1.0);
  }
  
  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.millisecondsSinceEpoch,
      'duration': duration.inSeconds,
      'isActive': isActive,
      'endTime': endTime?.millisecondsSinceEpoch,
    };
  }
  
  // Create from JSON
  factory DetoxSession.fromJson(Map<String, dynamic> json) {
    return DetoxSession(
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime']),
      duration: Duration(seconds: json['duration']),
      isActive: json['isActive'] ?? true,
      endTime: json['endTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['endTime'])
          : null,
    );
  }
  
  // Create a copy with updated values
  DetoxSession copyWith({
    DateTime? startTime,
    Duration? duration,
    bool? isActive,
    DateTime? endTime,
  }) {
    return DetoxSession(
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      isActive: isActive ?? this.isActive,
      endTime: endTime ?? this.endTime,
    );
  }
} 
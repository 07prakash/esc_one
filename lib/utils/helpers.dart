import 'dart:math';
import 'package:intl/intl.dart';
import 'constants.dart';

class AppHelpers {
  // Format duration for display
  static String formatDuration(Duration duration) {
    int days = duration.inDays;
    int hours = duration.inHours % 24;
    int minutes = duration.inMinutes % 60;
    
    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
  
  // Format time remaining
  static String formatTimeRemaining(Duration remaining) {
    if (remaining.isNegative) {
      return '00:00:00';
    }
    
    int hours = remaining.inHours;
    int minutes = remaining.inMinutes % 60;
    int seconds = remaining.inSeconds % 60;
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  // Get random motivational quote
  static String getRandomQuote() {
    final random = Random();
    return AppConstants.motivationalQuotes[random.nextInt(AppConstants.motivationalQuotes.length)];
  }
  
  // Format date for display
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  // Format time for display
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
  
  // Calculate percentage of detox completed
  static double calculateProgress(DateTime startTime, Duration totalDuration) {
    final now = DateTime.now();
    final elapsed = now.difference(startTime);
    final progress = elapsed.inSeconds / totalDuration.inSeconds;
    return progress.clamp(0.0, 1.0);
  }
  
  // Validate detox duration
  static bool isValidDetoxDuration(Duration duration) {
    final minDuration = Duration(minutes: AppConstants.minDetoxDurationMinutes);
    final maxDuration = Duration(days: AppConstants.maxDetoxDurationDays);
    
    return duration >= minDuration && duration <= maxDuration;
  }
  
  // Get detox status message
  static String getDetoxStatusMessage(Duration remaining) {
    if (remaining.isNegative) {
      return 'Detox completed!';
    }
    
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m remaining';
    } else {
      return '${minutes}m remaining';
    }
  }
} 
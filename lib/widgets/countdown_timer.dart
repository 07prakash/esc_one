import 'package:flutter/material.dart';

class CountdownTimer extends StatelessWidget {
  final Duration remainingTime;
  final double progress;
  
  const CountdownTimer({
    super.key,
    required this.remainingTime,
    required this.progress,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Modern progress indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(progress)),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Modern time display
          _buildTimerDisplay(remainingTime),
          
          const SizedBox(height: 16),
          
          // Status message in a styled container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              _getSimpleMessage(progress),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimerDisplay(Duration time) {
    final hours = time.inHours;
    final minutes = time.inMinutes % 60;
    final seconds = time.inSeconds % 60;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeSegment(hours.toString().padLeft(2, '0')),
        _buildTimeSeparator(),
        _buildTimeSegment(minutes.toString().padLeft(2, '0')),
        _buildTimeSeparator(),
        _buildTimeSegment(seconds.toString().padLeft(2, '0')),
      ],
    );
  }
  
  Widget _buildTimeSegment(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
  
  Widget _buildTimeSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ":",
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
  
  Color _getProgressColor(double progress) {
    if (progress >= 0.7) {
      return const Color(0xFF5CB85C); // Green success color
    } else if (progress >= 0.3) {
      return const Color(0xFF4A90E2); // Blue progress color
    } else {
      return const Color(0xFFF0AD4E); // Amber warning color
    }
  }
  
  String _getSimpleMessage(double progress) {
    if (progress > 0.8) {
      return "🎉 Almost there!";
    } else if (progress > 0.6) {
      return "💪 Great progress!";
    } else if (progress > 0.4) {
      return "🔥 Keep pushing!";
    } else if (progress > 0.2) {
      return "⚡ Stay strong!";
    } else {
      return "🚀 Just started!";
    }
  }
} 
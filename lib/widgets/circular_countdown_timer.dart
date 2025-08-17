import 'package:flutter/material.dart';

class CircularCountdownTimer extends StatelessWidget {
  final Duration remainingTime;
  final double progress;
  final double size;

  const CircularCountdownTimer({
    super.key,
    required this.remainingTime,
    required this.progress,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress circle
          SizedBox(
            width: size - 20,
            height: size - 20,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.9),
              ),
              strokeCap: StrokeCap.round,
            ),
          ),
          
          // Inner circle with gradient
          Container(
            width: size - 40,
            height: size - 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.05),
                ],
                center: Alignment.topLeft,
                radius: 1.0,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          
          // Time display
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main time
              Text(
                _formatTime(remainingTime),
                style: TextStyle(
                  fontSize: size * 0.20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Motivational text
              Text(
                _getProgressText(),
                style: TextStyle(
                  fontSize: size * 0.06,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getProgressText() {
    final progress = this.progress;
    if (progress > 0.8) return '🎉 Almost done!';
    if (progress > 0.6) return '💪 Good progress!';
    if (progress > 0.4) return '🔥 Keep pushing!';
    if (progress > 0.2) return '⚡ Stay strong!';
    return '🚀 Just started!';
  }

  String _formatTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } else if (minutes > 0) {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${seconds.toString().padLeft(2, '0')}s';
    }
  }
  

} 
import 'package:flutter/material.dart';
import '../widgets/countdown_timer.dart';
import '../services/detox_enforcer.dart';
import '../services/timer_service.dart';
import '../models/detox_session.dart';
import '../widgets/detox_completion_dialog.dart';
import 'timer_setup_screen.dart';
import 'motivational_quote_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late DetoxEnforcer _detoxEnforcer;
  late TimerService _timerService;
  
  @override
  void initState() {
    super.initState();
    _detoxEnforcer = DetoxEnforcer();
    _timerService = TimerService();
    _initializeTimer();
  }

  Future<void> _initializeTimer() async {
    await _detoxEnforcer.initialize();
    
    if (_detoxEnforcer.isDetoxActive && 
        _detoxEnforcer.detoxStartTime != null && 
        _detoxEnforcer.detoxDuration != null) {
      final session = DetoxSession(
        startTime: _detoxEnforcer.detoxStartTime!,
        duration: _detoxEnforcer.detoxDuration!,
      );
      _timerService.startTimer(session, onCompleted: _onDetoxCompleted);
    }
  }
  
  void _onDetoxCompleted() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => DetoxCompletionDialog(
          onExitDetox: _exitDetox,
        ),
      );
    }
  }
  
  void _exitDetox() async {
    await _detoxEnforcer.completeSession();
    await _detoxEnforcer.endDetox();
    
    if (mounted) {
      // Navigate to timer setup screen to start a new session
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const TimerSetupScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Text(
            'Settings',
           style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 36), // Balance the row
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Check if detox is completed and show dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_detoxEnforcer.isDetoxCompleted && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => DetoxCompletionDialog(
            onExitDetox: _exitDetox,
          ),
        );
      }
    });
    
    return PopScope(
      canPop: true,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6366f1),
                Color(0xFF8b5cf6),
              ],
            ),
          ),
          child: SafeArea(
            child: ListenableBuilder(
              listenable: _detoxEnforcer,
              builder: (context, child) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _buildProgressSection(),
                            const SizedBox(height: 24),
                            _buildTimerSection(),
                            const SizedBox(height: 24),
                            if (_detoxEnforcer.isDetoxActive && !_detoxEnforcer.isDetoxCompleted) ...[
                              _buildEarlyExitButton(),
                              const SizedBox(height: 24),
                            ],
                            _buildAppInfoSection(),
                            const SizedBox(height: 24),
                            _buildQuickLinksSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Your Progress',
               style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildModernProgressCard(
                  'Completed',
                  '${_detoxEnforcer.completedSessions}',
                  Icons.check_circle_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernProgressCard(
                  'Total Time',
                  _formatTotalTime(_detoxEnforcer.totalDetoxTime),
                  Icons.timer_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildModernProgressCard(
                  'Success Rate',
                  '${_calculateSuccessRate()}%',
                  Icons.trending_up_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernProgressCard(
                  'Saved Time',
                  _formatSavedTime(_detoxEnforcer.savedTime),
                  Icons.schedule_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernProgressCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Detox Timer',
               style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ListenableBuilder(
            listenable: _timerService,
            builder: (context, child) {
              return CountdownTimer(
                remainingTime: _timerService.remainingTime,
                progress: _timerService.progress,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEarlyExitButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1f2937),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: Text(
                'End Detox Session',
               style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Are you sure you want to end your current detox session?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      "Ending your detox early incurs a ₹50 break penalty. This is based on psychological research showing accountability boosts success. It's not a punishment, but a reminder of your commitment. Each successful detox strengthens your focus and mental clarity. \"You chose this for a reason.\" Stay strong!",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _exitDetox();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.8),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'End Session',
                 style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withOpacity(0.8),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.exit_to_app_rounded),
            const SizedBox(width: 12),
            Text(
              'Request Early Exit',
           style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Digital Detox',
           style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Version: 1.0.0',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A digital detox app to help you stay focused and reduce phone addiction.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinksSection() {
    return Column(
      children: [
        _buildLinkCard(
          'Digital Detox Benefits',
          Icons.lightbulb_rounded,
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const MotivationalQuoteScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildLinkCard(
          'Privacy Policy',
          Icons.privacy_tip_rounded,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Privacy Policy - Coming Soon'),
                backgroundColor: Colors.white.withOpacity(0.9),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLinkCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }



  String _formatTotalTime(Duration? duration) {
    if (duration == null) return '0h 0m';
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  String _formatSavedTime(Duration? duration) {
    if (duration == null) return '0h 0m';
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  int _calculateSuccessRate() {
    final totalSessions = _detoxEnforcer.completedSessions + _detoxEnforcer.failedSessions;
    if (totalSessions == 0) return 0;
    return ((_detoxEnforcer.completedSessions / totalSessions) * 100).round();
  }
} 
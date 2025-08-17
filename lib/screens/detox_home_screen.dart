import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../widgets/digital_clock.dart';
import '../widgets/circular_countdown_timer.dart';
import '../services/detox_enforcer.dart';
import '../services/timer_service.dart';
import '../models/detox_session.dart';
import '../widgets/detox_completion_dialog.dart';
import 'settings_screen.dart';
import 'alarm_screen.dart';
import 'timer_setup_screen.dart';

class DetoxHomeScreen extends StatefulWidget {
  const DetoxHomeScreen({super.key});

  @override
  State<DetoxHomeScreen> createState() => _DetoxHomeScreenState();
}

class _DetoxHomeScreenState extends State<DetoxHomeScreen>
    with TickerProviderStateMixin {
  late DetoxEnforcer _detoxEnforcer;
  late TimerService _timerService;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _detoxEnforcer = DetoxEnforcer();
    _timerService = TimerService();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    // Keep screen awake during detox
    WakelockPlus.enable();
    
    // Prevent app from being closed during detox
    _preventAppExit();
    
    // Add a listener to activity lifecycle events
    _setupActivityLifecycleListener();
    
    _initializeDetox().then((_) {
      // Apply immersive mode after initialization to ensure we know detox status
      _applyImmersiveMode();
    });
    
    // Start animations
    _fadeController.forward();
  }
  
  void _setupActivityLifecycleListener() {
    // Listen for app lifecycle changes to reapply immersive mode
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.resumed.toString() && 
          mounted && 
          _detoxEnforcer.isDetoxActive) {
        // When app is resumed, immediately reapply immersive mode
        _applyImmersiveMode();
      }
      return null;
    });
  }
  
  void _preventAppExit() {
    // Handle app exit attempts
    SystemChannels.platform.setMethodCallHandler((call) async {
      if (call.method == 'SystemNavigator.pop') {
        // Show dialog explaining that they can't exit during detox
        if (mounted) {
          _showExitPreventionDialog();
        }
        // Prevent app from closing
        return false;
      }
      return null;
    });
  }
  
  void _showExitPreventionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1f2937),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        title: Text(
          'Cannot Exit App',
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
              'You cannot exit the app while a detox session is active.',
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
                "To end your detox early, go to Settings and tap 'Request Early Exit'. Remember that ending early incurs a ₹50 break penalty.",
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
              'Stay Focused',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Go to Settings',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _initializeDetox() async {
    await _detoxEnforcer.initialize();
    
    if (_detoxEnforcer.isDetoxActive && _detoxEnforcer.detoxStartTime != null && _detoxEnforcer.detoxDuration != null) {
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
    
    // Restore system UI when exiting detox
    _restoreSystemUI();
    
    if (mounted) {
      // Navigate to timer setup screen to start a new session
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const TimerSetupScreen()),
        (route) => false,
      );
    }
  }
  
  @override
  void dispose() {
    WakelockPlus.disable();
    _fadeController.dispose();
    
    // Only restore system UI if detox is not active anymore
    if (!_detoxEnforcer.isDetoxActive) {
      _restoreSystemUI();
    }
    
    super.dispose();
  }
  
  void _restoreSystemUI() {
    // Restore system UI when leaving detox screen
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    
    // Unlock orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    // Reset system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: null,
      systemNavigationBarColor: null,
      systemNavigationBarDividerColor: null,
    ));
  }
  
  // Timer for continuous enforcement
  static const Duration _enforcementInterval = Duration(milliseconds: 100);
  
  void _applyImmersiveMode() {
    if (_detoxEnforcer.isDetoxActive) {
      // Apply immersive sticky mode to hide system navigation buttons
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [],
      );
      
      // Lock orientation to portrait
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      
      // Set system UI flags for maximum immersion
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ));
      
      // Add additional protection against system navigation
      SystemChannels.navigation.invokeMethod<void>('systemNavigationBarHidden', true);
      
      // Prevent screenshot and screen recording
      SystemChannels.platform.invokeMethod<void>('SystemChrome.setSystemUIChangeCallback', true);
      
      // Set up continuous enforcement to prevent navigation
      Future.delayed(_enforcementInterval, () {
        if (mounted && _detoxEnforcer.isDetoxActive) {
          _applyImmersiveMode(); // Recursive call for continuous enforcement
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Reapply immersive mode on each build to ensure it stays active
    if (_detoxEnforcer.isDetoxActive) {
      _applyImmersiveMode();
    }
    
    // Prevent going back during active detox unless temporarily allowed
    return PopScope(
      canPop: false, // Removed isTemporarilyAllowed
      onPopInvoked: (bool didPop) {
        if (didPop) return; // Removed isTemporarilyAllowed
        // Show dialog explaining that they can't go back during detox
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1f2937),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: Text(
              'Detox In Progress',
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
                  'You cannot go back while a detox session is active.',
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
                    "To end your detox early, go to Settings and tap 'Request Early Exit'. Remember that ending early incurs a ₹50 break penalty.",
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
                  'Stay Focused',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Go to Settings',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF6366f1),
                Color(0xFF8b5cf6),
              ],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildSimpleHeader(),
                      
                      const SizedBox(height: 24),
                      
                      // Main Timer
                      _buildMainTimer(),
                      
                      const SizedBox(height: 24),
                      
                      // Progress
                      _buildSimpleProgress(),
                      
                      const SizedBox(height: 24),
                      
                      // Actions
                      _buildSimpleActions(),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_top_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Digital Detox',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.settings_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTimer() {
    return Column(
      children: [
        // Status badge and time
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Detox Active',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 40),
        
        // Large Timer
        ListenableBuilder(
          listenable: _timerService,
          builder: (context, child) {
            return CircularCountdownTimer(
              remainingTime: _timerService.remainingTime,
              progress: _timerService.progress,
              size: 200,
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        // Current time
        const DigitalClock(),
      ],
    );
  }

  Widget _buildSimpleProgress() {
    return ListenableBuilder(
      listenable: _timerService,
      builder: (context, child) {
        final progressPercent = (_timerService.progress * 100).toInt();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$progressPercent%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _timerService.progress,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimpleActions() {
    return Container(
      padding: const EdgeInsets.all(16),
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
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                'Alarm',
                Icons.alarm_rounded,
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AlarmScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
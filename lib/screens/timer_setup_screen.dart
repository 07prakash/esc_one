import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../services/detox_enforcer.dart';
import '../services/timer_service.dart';
import '../models/detox_session.dart';
import 'detox_home_screen.dart';

class TimerSetupScreen extends StatefulWidget {
  const TimerSetupScreen({super.key});

  @override
  State<TimerSetupScreen> createState() => _TimerSetupScreenState();
}

class _TimerSetupScreenState extends State<TimerSetupScreen> with TickerProviderStateMixin {
  int _selectedDays = 0;
  int _selectedHours = 0;
  int _selectedMinutes = 30;
  bool _isStarting = false;
  
  late DetoxEnforcer _detoxEnforcer;
  late TimerService _timerService;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Preset durations for quick selection
  final List<Map<String, dynamic>> _presetDurations = [
    {'label': '30 Min', 'duration': const Duration(minutes: 30), 'icon': Icons.timer_outlined},
    {'label': '1 Hour', 'duration': const Duration(hours: 1), 'icon': Icons.access_time},
    {'label': '2 Hours', 'duration': const Duration(hours: 2), 'icon': Icons.schedule},
    {'label': '4 Hours', 'duration': const Duration(hours: 4), 'icon': Icons.timer_3},
    {'label': '8 Hours', 'duration': const Duration(hours: 8), 'icon': Icons.bedtime},
    {'label': '1 Day', 'duration': const Duration(days: 1), 'icon': Icons.calendar_today},
    {'label': '3 Days', 'duration': const Duration(days: 3), 'icon': Icons.date_range},
    {'label': '1 Week', 'duration': const Duration(days: 7), 'icon': Icons.calendar_month},
  ];
  
  @override
  void initState() {
    super.initState();
    _detoxEnforcer = DetoxEnforcer();
    _timerService = TimerService();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Duration get _selectedDuration {
    return Duration(
      days: _selectedDays,
      hours: _selectedHours,
      minutes: _selectedMinutes,
    );
  }
  
  void _selectPresetDuration(Duration duration) {
    setState(() {
      _selectedDays = duration.inDays;
      _selectedHours = duration.inHours % 24;
      _selectedMinutes = duration.inMinutes % 60;
    });
  }
  
  bool _isPresetSelected(Duration duration) {
    return _selectedDuration == duration;
  }
  
  Future<void> _startDetox() async {
    if (!AppHelpers.isValidDetoxDuration(_selectedDuration)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid duration (30 minutes to 7 days)'),
          backgroundColor: AppConstants.warningColor,
        ),
      );
      return;
    }
    
    setState(() {
      _isStarting = true;
    });
    
    try {
      final startTime = DateTime.now();
      final session = DetoxSession(
        startTime: startTime,
        duration: _selectedDuration,
      );
      
      // Start detox mode
      await _detoxEnforcer.startDetox(startTime, _selectedDuration);
      
      // Start timer
      _timerService.startTimer(session);
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DetoxHomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting detox: $e'),
            backgroundColor: AppConstants.warningColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isStarting = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFF),
              Color(0xFFEEF4FF),
              Color(0xFFF0F7FF),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.largePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    _buildHeaderSection(),
                    
                    const SizedBox(height: AppConstants.extraLargePadding),
                    
                    // Quick Preset Options
                    _buildPresetSection(),
                    
                    const SizedBox(height: AppConstants.extraLargePadding),
                    
                    // Custom Time Picker Row
                    _buildCustomTimeSection(),
                    
                    const SizedBox(height: AppConstants.extraLargePadding),
                    
                    // Duration Preview Card
                    _buildDurationPreview(),
                    
                    const SizedBox(height: AppConstants.extraLargePadding),
                    
                    // Motivational Section
                    _buildMotivationalSection(),
                    
                    const SizedBox(height: AppConstants.extraLargePadding),
                    
                    // Start Button
                    _buildStartButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set Your Detox',
         style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppConstants.textDark,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          'Choose how long you want to stay focused',
         style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppConstants.textMedium,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildPresetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Options',
         style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppConstants.textDark,
          ),
        ),
        const SizedBox(height: AppConstants.padding),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _presetDurations.length,
            itemBuilder: (context, index) {
              final preset = _presetDurations[index];
              final isSelected = _isPresetSelected(preset['duration']);
              
              return Padding(
                padding: EdgeInsets.only(
                  right: index < _presetDurations.length - 1 ? AppConstants.padding : 0,
                ),
                child: _buildPresetCard(
                  label: preset['label'],
                  icon: preset['icon'],
                  duration: preset['duration'],
                  isSelected: isSelected,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPresetCard({
    required String label,
    required IconData icon,
    required Duration duration,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _selectPresetDuration(duration),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        padding: const EdgeInsets.all(AppConstants.padding),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? AppConstants.primaryGradient
              : null,
          color: isSelected 
              ? null 
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? Colors.transparent 
                : AppConstants.stoneGray.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppConstants.softBlue.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 15 : 8,
              spreadRadius: isSelected ? 2 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.white : AppConstants.softBlue,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppConstants.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Duration',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppConstants.textDark,
          ),
        ),
        const SizedBox(height: AppConstants.padding),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _buildModernTimePicker(
                label: 'Days',
                value: _selectedDays,
                maxValue: 7,
                onChanged: (value) {
                  setState(() {
                    _selectedDays = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModernTimePicker(
                label: 'Hours',
                value: _selectedHours,
                maxValue: 23,
                onChanged: (value) {
                  setState(() {
                    _selectedHours = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModernTimePicker(
                label: 'Minutes',
                value: _selectedMinutes,
                maxValue: 59,
                onChanged: (value) {
                  setState(() {
                    _selectedMinutes = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernTimePicker({
    required String label,
    required int value,
    required int maxValue,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
           style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppConstants.textMedium,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              _buildTimeButton(
                icon: Icons.keyboard_arrow_up,
                onPressed: value < maxValue ? () => onChanged(value + 1) : null,
                enabled: value < maxValue,
              ),
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppConstants.softBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    value.toString().padLeft(2, '0'),
                   style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildTimeButton(
                icon: Icons.keyboard_arrow_down,
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
                enabled: value > 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 28,
        decoration: BoxDecoration(
          color: enabled 
              ? AppConstants.softBlue.withValues(alpha: 0.15)
              : AppConstants.stoneGray.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled 
              ? AppConstants.softBlue
              : AppConstants.textMedium,
        ),
      ),
    );
  }

  Widget _buildDurationPreview() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.softBlue.withValues(alpha: 0.1),
            AppConstants.mutedGreen.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppConstants.softBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppConstants.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.timer_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppConstants.largePadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Duration',
                 style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.textMedium,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppHelpers.formatDuration(_selectedDuration),
                 style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: AppConstants.mutedGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppConstants.mutedGreen.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppConstants.mutedGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: AppConstants.mutedGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: AppConstants.largePadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Focus Tip',
                 style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.mutedGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start with shorter sessions and gradually increase duration as you build focus habits.',
                       style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppConstants.textMedium,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: AppConstants.primaryGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppConstants.softBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isStarting ? null : _startDetox,
          borderRadius: BorderRadius.circular(30),
          child: Center(
            child: _isStarting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Start Detox',
                       style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
} 
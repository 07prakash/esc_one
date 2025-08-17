import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/detox_enforcer.dart';
import 'rounded_button.dart';

class DetoxCompletionDialog extends StatelessWidget {
  final VoidCallback onExitDetox;
  
  const DetoxCompletionDialog({
    super.key,
    required this.onExitDetox,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.extraLargePadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
          gradient: AppConstants.successGradient,
          boxShadow: AppConstants.mediumShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon with vibrant design
            Container(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppConstants.mediumShadow, // More visible shadow
              ),
              child: const Icon(
                Icons.celebration_outlined,
                size: 56,
                color: AppConstants.successColor, // Vibrant success color
              ),
            ),
            
            const SizedBox(height: AppConstants.extraLargePadding),
            
            // Title with vibrant messaging
            Text(
              'Digital Freedom Achieved! 🎉',
              style: AppConstants.headingStyle.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppConstants.padding),
            
            // Vibrant message
            Text(
              'Today, you chose clarity over chaos. Your future self is grateful for this moment of discipline.',
              style: AppConstants.bodyLargeStyle.copyWith(
                fontSize: 18,
                color: Colors.white,
                height: 1.5,
                fontWeight: FontWeight.w700, // Increased weight
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppConstants.extraLargePadding),
            
            // Buttons with new design strategy
            Column(
              children: [
                // Exit Detox Button - Primary action
                RoundedButton(
                  text: 'Exit Detox',
                  icon: Icons.exit_to_app,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onExitDetox();
                  },
                  isMotivational: true,
                  width: double.infinity,
                ),
                
                const SizedBox(height: AppConstants.padding),
                
                // Extend Detox Button - Secondary action
                RoundedButton(
                  text: 'Extend Detox',
                  icon: Icons.timer,
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showExtendDetoxDialog(context);
                  },
                  isOutlined: true,
                  width: double.infinity,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showExtendDetoxDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.extraLargePadding),
          decoration: BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
            boxShadow: AppConstants.mediumShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with vibrant icon
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: AppConstants.softBlue, // Updated to use new vibrant color
                    size: 32,
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Text(
                    'Extend Your Detox',
                    style: AppConstants.titleStyle.copyWith(
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppConstants.largePadding),
              
              // Gentle message
              Text(
                'How long would you like to extend your detox session?',
                style: AppConstants.bodyStyle.copyWith(
                  color: AppConstants.textSecondaryColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppConstants.extraLargePadding),
              
              // Time Options with calming design
              Column(
                children: [
                  _buildTimeOption(context, '30 minutes', const Duration(minutes: 30)),
                  const SizedBox(height: AppConstants.smallPadding),
                  _buildTimeOption(context, '1 hour', const Duration(hours: 1)),
                  const SizedBox(height: AppConstants.smallPadding),
                  _buildTimeOption(context, '2 hours', const Duration(hours: 2)),
                  const SizedBox(height: AppConstants.smallPadding),
                  _buildTimeOption(context, '4 hours', const Duration(hours: 4)),
                ],
              ),
              
              const SizedBox(height: AppConstants.largePadding),
              
              // Cancel button
              RoundedButton(
                text: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
                isOutlined: true,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeOption(BuildContext context, String label, Duration duration) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: RoundedButton(
        text: label,
        onPressed: () async {
          Navigator.of(context).pop();
          final detoxEnforcer = DetoxEnforcer();
          await detoxEnforcer.initialize();
          
          // Extend the current session
          if (detoxEnforcer.isDetoxActive && detoxEnforcer.detoxDuration != null) {
            final newDuration = detoxEnforcer.detoxDuration! + duration;
            await detoxEnforcer.updateDetoxDuration(newDuration);
            
            // Show success message
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Detox extended by ${_formatDuration(duration)}'),
                  backgroundColor: AppConstants.successColor,
                ),
              );
            }
          }
        },
        isSecondary: true,
        width: double.infinity,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    }
  }
} 
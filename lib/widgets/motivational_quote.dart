import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class MotivationalQuote extends StatelessWidget {
  final String? customQuote;
  final bool isOnboarding;
  final bool isFasting;
  final bool isPenalty;
  final bool isCompletion;
  final bool isFailure;
  
  const MotivationalQuote({
    super.key,
    this.customQuote,
    this.isOnboarding = false,
    this.isFasting = false,
    this.isPenalty = false,
    this.isCompletion = false,
    this.isFailure = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: _getBorderColor(),
          width: 2, // Increased border width
        ),
        boxShadow: AppConstants.mediumShadow, // More visible shadow
      ),
      child: Column(
        children: [
          Icon(
            _getIcon(),
            color: _getIconColor(),
            size: 36, // Increased icon size
          ),
          const SizedBox(height: AppConstants.padding),
          Text(
            _getQuote(),
            style: AppConstants.bodyLargeStyle.copyWith(
              color: AppConstants.textPrimaryColor,
              height: 1.5,
              fontWeight: FontWeight.w700, // Increased weight
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  String _getQuote() {
    if (customQuote != null) return customQuote!;
    
    if (isOnboarding) {
      return AppConstants.onboardingQuotes[
        DateTime.now().millisecond % AppConstants.onboardingQuotes.length
      ];
    }
    
    if (isFasting) {
      return AppConstants.fastingQuotes[
        DateTime.now().millisecond % AppConstants.fastingQuotes.length
      ];
    }
    
    if (isPenalty) {
      return AppConstants.breakPenaltyQuotes[
        DateTime.now().millisecond % AppConstants.breakPenaltyQuotes.length
      ];
    }
    
    if (isCompletion) {
      return AppConstants.completionQuotes[
        DateTime.now().millisecond % AppConstants.completionQuotes.length
      ];
    }
    
    if (isFailure) {
      return AppConstants.failureQuotes[
        DateTime.now().millisecond % AppConstants.failureQuotes.length
      ];
    }
    
    // Default to legacy quotes for backward compatibility
    return AppHelpers.getRandomQuote();
  }
  
  IconData _getIcon() {
    if (isOnboarding) return Icons.psychology_outlined;
    if (isFasting) return Icons.timer_outlined;
    if (isPenalty) return Icons.warning_amber_outlined;
    if (isCompletion) return Icons.celebration_outlined;
    if (isFailure) return Icons.favorite_outline;
    return Icons.lightbulb_outline;
  }
  
  Color _getIconColor() {
    if (isOnboarding) return AppConstants.softBlue;
    if (isFasting) return AppConstants.softBlue;
    if (isPenalty) return AppConstants.errorColor;
    if (isCompletion) return AppConstants.successColor;
    if (isFailure) return AppConstants.warningColor;
    return AppConstants.softBlue;
  }
  
  Color _getBorderColor() {
    if (isOnboarding) return AppConstants.softBlue;
    if (isFasting) return AppConstants.softBlue;
    if (isPenalty) return AppConstants.errorColor;
    if (isCompletion) return AppConstants.successColor;
    if (isFailure) return AppConstants.warningColor;
    return AppConstants.softBlue;
  }
} 
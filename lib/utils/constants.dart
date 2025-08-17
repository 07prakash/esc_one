import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Dtox';
  static const String appVersion = '1.0.0';
  
  // 🎨 Digital Detox Color Palette - Vibrant & Visible
  
  // Primary Colors (Calming but Visible)
  static const Color softBlue = Color(0xFF4A90E2); // Vibrant calming blue
  static const Color warmBeige = Color(0xFFF5E6D3); // Warm grounding beige
  static const Color mutedGreen = Color(0xFF7FB069); // Visible calming green
  static const Color stoneGray = Color(0xFFD4D4D4); // Clean neutral gray
  
  // Text Colors (High Contrast & Visible)
  static const Color textDark = Color(0xFF1A1A1A); // Deep dark for maximum readability
  static const Color textMedium = Color(0xFF4A4A4A); // Medium gray for secondary text
  static const Color textLight = Color(0xFF6B6B6B); // Light gray for tertiary text
  
  // Legacy color mappings for backward compatibility
  static const Color primaryColor = softBlue;
  static const Color primaryLightColor = Color(0xFF6BA3E8); // Lighter vibrant blue
  static const Color primaryDarkColor = Color(0xFF3A7BC8); // Darker vibrant blue
  
  static const Color secondaryColor = warmBeige;
  static const Color secondaryLightColor = Color(0xFFF8EDE0); // Lighter warm beige
  
  static const Color accentColor = mutedGreen; // Visible green accent
  static const Color accentLightColor = Color(0xFF8FBC7A); // Lighter visible green
  
  // Success: Visible green
  static const Color successColor = Color(0xFF5CB85C); // Bright success green
  static const Color successLightColor = Color(0xFF7BC87B); // Lighter success green
  
  // Warning: Visible amber
  static const Color warningColor = Color(0xFFF0AD4E); // Bright warning amber
  static const Color warningLightColor = Color(0xFFF4C271); // Lighter warning amber
  
  // Error: Visible red
  static const Color errorColor = Color(0xFFD9534F); // Bright error red
  static const Color errorLightColor = Color(0xFFE57373); // Lighter error red
  
  // Background Colors - Clean and visible
  static const Color backgroundColor = Color(0xFFFAFAFA); // Clean off-white
  static const Color surfaceColor = Color(0xFFFFFFFF); // Pure white
  static const Color cardColor = Color(0xFFF8F8F8); // Light gray
  static const Color cardHoverColor = Color(0xFFF0F0F0); // Hover state
  
  // Text Colors - High contrast for visibility
  static const Color textPrimaryColor = textDark; // Deep dark for maximum readability
  static const Color textSecondaryColor = textMedium; // Medium gray
  static const Color textTertiaryColor = textLight; // Light gray
  static const Color textInverseColor = Color(0xFFFFFFFF); // White text
  
  // Special Colors for Digital Detox - All visible
  static const Color focusColor = softBlue; // Vibrant blue for focus
  static const Color mindfulnessColor = mutedGreen; // Visible green for mindfulness
  static const Color calmColor = softBlue; // Vibrant blue for calmness
  static const Color energyColor = warningColor; // Bright amber for energy
  static const Color meditationColor = Color(0xFF9B59B6); // Visible purple for meditation
  
  // Enhanced Spacing System
  static const double xsPadding = 4.0;
  static const double smallPadding = 8.0;
  static const double padding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  static const double xxlPadding = 48.0;
  
  // Simple Border Radius System
  static const double borderRadius = 8.0; // Smaller, simpler radius
  static const double largeBorderRadius = 12.0;
  static const double extraLargeBorderRadius = 16.0;
  static const double pillBorderRadius = 50.0;
  
  // Minimal Shadows - Very subtle
  static const List<BoxShadow> subtleShadow = [
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];
  
  static const List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> largeShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 12,
      offset: Offset(0, 3),
    ),
  ];
  
  // Payment
  static const int earlyExitPenalty = 50; // in rupees
  
  // Detox Duration Limits
  static const int minDetoxDurationMinutes = 15;
  static const int maxDetoxDurationDays = 7;
  
  // Essential Apps List
  static const List<String> essentialApps = [
    'com.android.mms',
    'com.android.calendar',
    'com.google.android.apps.maps',
    'com.android.camera',
    'com.android.settings',
    'com.android.contacts',
  ];
  
  // 📝 Simple Motivational Sentences for Digital Detox App Screens
  static const List<String> onboardingQuotes = [
    "Take a break from your phone.",
    "Focus on what matters most.",
    "Start your digital detox journey.",
  ];
  
  static const List<String> fastingQuotes = [
    "Stay focused on your goal.",
    "You're doing great.",
    "Keep going.",
  ];
  
  static const List<String> breakPenaltyQuotes = [
    "Breaking early costs ₹50.",
    "Stay strong, complete your detox.",
  ];
  
  static const List<String> completionQuotes = [
    "Well done! You completed your detox.",
    "Great job staying focused.",
  ];
  
  static const List<String> failureQuotes = [
    "It's okay. Try again.",
    "Every attempt is progress.",
  ];
  
  // Legacy motivational quotes for backward compatibility
  static const List<String> motivationalQuotes = [
    "Focus on being present.",
    "Take one step at a time.",
    "Small progress is still progress.",
    "Be mindful of your choices.",
    "Stay consistent with your goals.",
    "You are capable of amazing things.",
    "Focus on what you can control.",
    "The mind is everything. What you think you become.",
    "Quality over quantity.",
    "Be present. Be mindful. Be intentional.",
    "Your habits shape your future.",
    "Every moment is a fresh beginning.",
    "The journey of a thousand miles begins with one step.",
    "You have the power to change your life.",
    "Consistency beats perfection.",
  ];
  
  // SharedPreferences Keys
  static const String keyDetoxDuration = 'detox_duration';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyCompletedSessions = 'completed_sessions';
  static const String keyFailedSessions = 'failed_sessions';
  static const String keyTotalDetoxTime = 'total_detox_time';
  static const String keySavedTime = 'saved_time';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyDetoxActive = 'detox_active';
  static const String keyDetoxStartTime = 'detox_start_time';
  
  // Simple Typography - Using system fonts for simplicity
  static TextStyle get headingStyle => TextStyle(
    fontSize: 32, // Increased from 28
    fontWeight: FontWeight.w600, // Increased weight
    color: textPrimaryColor,
    height: 1.2,
  );
  
  static TextStyle get subheadingStyle => TextStyle(
    fontSize: 26, // Increased from 22
    fontWeight: FontWeight.w600, // Increased weight
    color: textPrimaryColor,
    height: 1.3,
  );
  
  static TextStyle get titleStyle => TextStyle(
    fontSize: 22, // Increased from 18
    fontWeight: FontWeight.w600, // Increased weight
    color: textPrimaryColor,
    height: 1.4,
  );
  
  static TextStyle get bodyStyle => TextStyle(
    fontSize: 18, // Increased from 16
    fontWeight: FontWeight.w500, // Increased weight
    color: textPrimaryColor,
    height: 1.5,
  );
  
  static TextStyle get bodyLargeStyle => TextStyle(
    fontSize: 20, // Increased from 18
    fontWeight: FontWeight.w500, // Increased weight
    color: textPrimaryColor,
    height: 1.5,
  );
  
  static TextStyle get captionStyle => TextStyle(
    fontSize: 16, // Increased from 14
    fontWeight: FontWeight.w500, // Increased weight
    color: textSecondaryColor,
    height: 1.4,
  );
  
  static TextStyle get buttonStyle => TextStyle(
    fontSize: 18, // Increased from 16
    fontWeight: FontWeight.w600, // Increased weight
    height: 1.2,
  );
  
  static TextStyle get displayStyle => TextStyle(
    fontSize: 48, // Increased from 42
    fontWeight: FontWeight.w600, // Increased weight
    color: textPrimaryColor,
    height: 1.1,
  );
  
  // Vibrant Gradients - No transparency
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [softBlue, Color(0xFF6BA3E8)],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successColor, successLightColor],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient calmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [softBlue, Color(0xFF6BA3E8)],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient energyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warningColor, warningLightColor],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient meditationGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [meditationColor, Color(0xFFB07CC6)],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundColor, Color(0xFFF5F5F5)],
    stops: [0.0, 1.0],
  );
  
  // Animation Durations - Minimal or none
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 200);
  static const Duration slowAnimation = Duration(milliseconds: 300);
  
  // Border Styles
  static const BorderRadius defaultBorderRadius = BorderRadius.all(Radius.circular(borderRadius));
  static const BorderRadius largeBorderRadiusStyle = BorderRadius.all(Radius.circular(largeBorderRadius));
  static const BorderRadius pillBorderRadiusStyle = BorderRadius.all(Radius.circular(pillBorderRadius));
} 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/constants.dart';
import 'navigation_handler.dart';
import 'services/alarm_scheduler.dart';
import 'utils/nav_key.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Keep default GoogleFonts behavior (runtime fetching). If offline, consider removing GoogleFonts usage.
  
  // Check if detox is active
  final prefs = await SharedPreferences.getInstance();
  final isDetoxActive = prefs.getBool('isDetoxActive') ?? false;
  
  // If detox is active, prevent app from being closed
  if (isDetoxActive) {
    SystemChannels.platform.setMethodCallHandler((call) async {
      if (call.method == 'SystemNavigator.pop') {
        // Prevent app from closing
        return false;
      }
      return null;
    });
    
    // Set up additional protections against app exit
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
    
    // Lock orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }
  
  runApp(const DtoxApp());
  // Start in-app alarm scheduler (foreground only)
  AlarmScheduler.instance.start();
}

class DtoxApp extends StatelessWidget {
  const DtoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      navigatorKey: AppNavigatorKey.instance,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          brightness: Brightness.light,
          surface: AppConstants.surfaceColor,
          onSurface: AppConstants.textPrimaryColor,
        ),
        // Use system fonts to avoid network dependency
        
        // Enhanced AppBar Theme
        appBarTheme: AppBarTheme(
          backgroundColor: AppConstants.surfaceColor,
          foregroundColor: AppConstants.textPrimaryColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          titleTextStyle: AppConstants.titleStyle,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(AppConstants.borderRadius),
            ),
          ),
        ),
        
        // Enhanced Card Theme
        cardTheme: CardThemeData(
          color: AppConstants.surfaceColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: AppConstants.padding,
            vertical: AppConstants.smallPadding,
          ),
        ),
        
        // Enhanced Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: AppConstants.textInverseColor,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.largePadding,
              vertical: AppConstants.padding,
            ),
            textStyle: AppConstants.buttonStyle,
            minimumSize: const Size(double.infinity, 56),
          ),
        ),
        
        // Enhanced Outlined Button Theme
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppConstants.primaryColor,
            side: BorderSide(color: AppConstants.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.largePadding,
              vertical: AppConstants.padding,
            ),
            textStyle: AppConstants.buttonStyle,
            minimumSize: const Size(double.infinity, 56),
          ),
        ),
        
        // Enhanced Text Button Theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppConstants.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.padding,
              vertical: AppConstants.smallPadding,
            ),
            textStyle: AppConstants.buttonStyle,
          ),
        ),
        
        // Enhanced Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppConstants.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            borderSide: BorderSide(color: AppConstants.errorColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.padding,
            vertical: AppConstants.padding,
          ),
          hintStyle: AppConstants.bodyStyle.copyWith(
            color: AppConstants.textSecondaryColor,
          ),
        ),
        
        // Enhanced Bottom Navigation Bar Theme
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppConstants.surfaceColor,
          selectedItemColor: AppConstants.primaryColor,
          unselectedItemColor: AppConstants.textSecondaryColor,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: AppConstants.captionStyle.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppConstants.captionStyle,
        ),
        
        // Enhanced Floating Action Button Theme
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: AppConstants.textInverseColor,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
          ),
        ),
        
        // Enhanced Divider Theme
        dividerTheme: DividerThemeData(
          color: AppConstants.cardColor,
          thickness: 1,
          space: 1,
        ),
        
        // Enhanced Chip Theme
        chipTheme: ChipThemeData(
          backgroundColor: AppConstants.cardColor,
          selectedColor: AppConstants.primaryColor,
          disabledColor: AppConstants.textTertiaryColor,
          labelStyle: AppConstants.captionStyle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.pillBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.padding,
            vertical: AppConstants.smallPadding,
          ),
        ),
      ),
      home: const NavigationHandler(),
    );
  }
}

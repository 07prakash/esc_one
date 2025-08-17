import 'package:flutter/foundation.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/constants.dart';
import 'photo_storage_service.dart';

class AppLauncherService {
  // Launch messages app
  static Future<void> launchMessages() async {
    try {
      // Try to launch the messages app
      final intent = AndroidIntent(
        action: 'android.intent.action.SENDTO',
        data: 'sms:',
      );
      await intent.launch();
    } catch (e) {
      if (kDebugMode) {
        print('Error launching messages app: $e');
      }
    }
  }
  
  // Launch calendar app
  static Future<void> launchCalendar() async {
    try {
      // Try Google Calendar first
      final intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: 'android.intent.category.LAUNCHER',
        package: 'com.google.android.calendar',
        componentName: 'com.google.android.calendar/com.android.calendar.AllInOneActivity',
      );
      await intent.launch();
    } catch (e) {
      try {
        // Fallback to generic calendar intent
        final intent = AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: 'content://com.android.calendar/time',
        );
        await intent.launch();
      } catch (e2) {
        if (kDebugMode) {
          print('Error launching calendar app: $e2');
        }
      }
    }
  }
  
  // Launch maps app (Google Maps)
  static Future<void> launchMaps() async {
    try {
      // Try Google Maps first
      final intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: 'android.intent.category.LAUNCHER',
        package: 'com.google.android.apps.maps',
        componentName: 'com.google.android.apps.maps/com.google.android.maps.MapsActivity',
      );
      await intent.launch();
    } catch (e) {
      try {
        // Fallback to generic maps intent
        final intent = AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: 'geo:0,0',
        );
        await intent.launch();
      } catch (e2) {
        if (kDebugMode) {
          print('Error launching maps app: $e2');
        }
      }
    }
  }
  
  // Launch camera app and save photos internally
  static Future<void> launchCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Capture photo using camera
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Good quality
        maxWidth: 1920, // Max width
        maxHeight: 1080, // Max height
      );
      
      if (photo != null) {
        // Save photo to internal storage using PhotoStorageService
        final File photoFile = File(photo.path);
        final String? savedPath = await PhotoStorageService.savePhoto(photoFile);
        
        if (savedPath != null) {
          if (kDebugMode) {
            print('Photo successfully saved to internal storage: $savedPath');
          }
        } else {
          if (kDebugMode) {
            print('Failed to save photo to internal storage');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error capturing photo: $e');
      }
      // Fallback to launching camera app directly
      try {
        final intent = AndroidIntent(
          action: 'android.media.action.IMAGE_CAPTURE',
        );
        await intent.launch();
      } catch (e2) {
        if (kDebugMode) {
          print('Error launching camera app: $e2');
        }
      }
    }
  }
  
  // Launch app by package name
  static Future<void> launchApp(String packageName) async {
    try {
      final intent = AndroidIntent(
        action: 'action_view',
        package: packageName,
      );
      await intent.launch();
    } catch (e) {
      if (kDebugMode) {
        print('Error launching app $packageName: $e');
      }
    }
  }
  
  // Check if app is installed
  static Future<bool> isAppInstalled(String packageName) async {
    try {
      final intent = AndroidIntent(
        action: 'action_view',
        package: packageName,
      );
      // Try to launch and immediately close to check if app exists
      await intent.launch();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Get available essential apps
  static Future<List<String>> getAvailableEssentialApps() async {
    final availableApps = <String>[];
    
    for (final packageName in AppConstants.essentialApps) {
      if (await isAppInstalled(packageName)) {
        availableApps.add(packageName);
      }
    }
    
    return availableApps;
  }
} 
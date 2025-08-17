import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class PhotoStorageService {
  static const String _photosDirName = 'photos';
  
  // Get the photos directory path
  static Future<String> get _photosDirPath async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/$_photosDirName';
  }
  
  // Save photo to internal storage
  static Future<String?> savePhoto(File photoFile) async {
    try {
      final String photosDir = await _photosDirPath;
      final Directory photosDirectory = Directory(photosDir);
      
      // Create photos directory if it doesn't exist
      if (!await photosDirectory.exists()) {
        await photosDirectory.create(recursive: true);
      }
      
      // Generate unique filename with timestamp
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = 'photo_$timestamp.jpg';
      final String filePath = '$photosDir/$fileName';
      
      // Copy the photo to internal storage
      final File savedFile = await photoFile.copy(filePath);
      
      if (kDebugMode) {
        print('Photo saved to: ${savedFile.path}');
      }
      
      return savedFile.path;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving photo: $e');
      }
      return null;
    }
  }
  
  // Get all saved photos
  static Future<List<File>> getSavedPhotos() async {
    try {
      final String photosDir = await _photosDirPath;
      final Directory photosDirectory = Directory(photosDir);
      
      if (!await photosDirectory.exists()) {
        return [];
      }
      
      final List<FileSystemEntity> entities = await photosDirectory.list().toList();
      final List<File> photos = [];
      
      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.jpg')) {
          photos.add(entity);
        }
      }
      
      // Sort by modification time (newest first)
      photos.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      
      return photos;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting saved photos: $e');
      }
      return [];
    }
  }
  
  // Delete a specific photo
  static Future<bool> deletePhoto(String photoPath) async {
    try {
      final File photoFile = File(photoPath);
      if (await photoFile.exists()) {
        await photoFile.delete();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting photo: $e');
      }
      return false;
    }
  }
  
  // Clear all saved photos
  static Future<bool> clearAllPhotos() async {
    try {
      final String photosDir = await _photosDirPath;
      final Directory photosDirectory = Directory(photosDir);
      
      if (await photosDirectory.exists()) {
        await photosDirectory.delete(recursive: true);
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing photos: $e');
      }
      return false;
    }
  }
  
  // Get storage info
  static Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final String photosDir = await _photosDirPath;
      final Directory photosDirectory = Directory(photosDir);
      
      if (!await photosDirectory.exists()) {
        return {
          'totalPhotos': 0,
          'totalSize': 0,
          'directoryPath': photosDir,
        };
      }
      
      final List<File> photos = await getSavedPhotos();
      int totalSize = 0;
      
      for (final photo in photos) {
        totalSize += await photo.length();
      }
      
      return {
        'totalPhotos': photos.length,
        'totalSize': totalSize,
        'directoryPath': photosDir,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting storage info: $e');
      }
      return {
        'totalPhotos': 0,
        'totalSize': 0,
        'directoryPath': '',
      };
    }
  }
} 
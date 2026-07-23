import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restora_mobile/models/check_in_model.dart';

class CheckInStorageService {
  static const String _storageKey = 'local_check_ins_queue';

  /// Save a new check-in to local device storage
  Future<bool> saveCheckIn(CheckInModel record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<CheckInModel> existingList = await getCheckIns();

      // Append new record
      existingList.add(record);

      // Encode list to JSON string
      final String encodedData = json.encode(
        existingList.map((e) => e.toJson()).toList(),
      );

      final success = await prefs.setString(_storageKey, encodedData);
      debugPrint('Local Check-In Saved: ${record.createdAt.toIso8601String()}');
      return success;
    } catch (e) {
      debugPrint('Error saving check-in locally: $e');
      return false;
    }
  }

  /// Retrieve all locally stored check-ins
  Future<List<CheckInModel>> getCheckIns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> decodedList = json.decode(jsonString);
      return decodedList
          .map((item) => CheckInModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error reading local check-ins: $e');
      return [];
    }
  }

  /// Clear stored items (useful after syncing to PostgreSQL backend)
  Future<bool> clearLocalQueue() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_storageKey);
  }
}

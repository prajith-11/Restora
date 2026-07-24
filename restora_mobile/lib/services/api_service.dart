import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    } else if (Platform.isAndroid) {
      return 'http://192.168.29.234:8080';
    } else {
      return 'http://localhost:8080';
    }
  }

  Future<List<dynamic>> fetchLogs({String? email}) async {
    try {
      final uri =
          email != null && email.isNotEmpty
              ? Uri.parse('$baseUrl/api/logs?email=$email')
              : Uri.parse('$baseUrl/api/logs');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load logs: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching logs: $e');
      return [];
    }
  }

  Future<bool> sendCheckIn({
    required String email,
    required String transcript, // Changed from 'notes' to match backend field
    required List<String> painZones,
    File? audioFile,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/logs/checkin');

      // OPTION A: If an audio file is present, use MultipartRequest
      if (audioFile != null && await audioFile.exists()) {
        final request = http.MultipartRequest('POST', uri);

        // 1. Text parameters matching Spring @RequestParam fields
        request.fields['email'] = email;
        request.fields['transcript'] =
            transcript; // FIXED: matches paramTranscript

        // 2. Selected zones parameter matching Spring @RequestParam fields
        if (painZones.isNotEmpty) {
          request.fields['selectedZones'] = painZones.join(
            ",",
          ); // FIXED: matches paramPainZones
        }

        // 3. Audio file attachment
        request.files.add(
          await http.MultipartFile.fromPath('audioFile', audioFile.path),
        );

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 201 || response.statusCode == 200) {
          print('Backend sync successful: ${response.body}');
          return true;
        } else {
          print('Backend error (${response.statusCode}): ${response.body}');
          return false;
        }
      }
      // OPTION B: Text-only Check-in (Standard Clean JSON POST)
      else {
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'transcript': transcript, // FIXED: keys match controller map reader
            'selectedZones':
                painZones, // FIXED: keys match controller map reader
          }),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          print('Backend sync successful: ${response.body}');
          return true;
        } else {
          print('Backend error (${response.statusCode}): ${response.body}');
          return false;
        }
      }
    } catch (e) {
      print('Network error connecting to backend: $e');
      return false;
    }
  }
}

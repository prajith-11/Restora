import 'dart:convert';

class CheckInModel {
  final String? localId; // UUID or timestamp string for offline indexing
  final int patientId; // Maps to check_ins.patient_id
  final String? voiceRecordingUrl; // Maps to check_ins.voice_recording_url
  final String transcript; // Maps to check_ins.transcript
  final int? painScore; // Maps to check_ins.pain_score (1-10)
  final bool medicationTaken; // Maps to check_ins.medication_taken
  final int? sleepRating; // Maps to check_ins.sleep_rating (1-5)
  final List<String> selectedZones; // Maps to pain_locations.zone_id
  final DateTime createdAt; // Maps to check_ins.created_at

  CheckInModel({
    this.localId,
    required this.patientId,
    this.voiceRecordingUrl,
    required this.transcript,
    this.painScore,
    this.medicationTaken = false,
    this.sleepRating,
    required this.selectedZones,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Map to JSON matching PostgreSQL column names
  Map<String, dynamic> toJson() {
    return {
      'local_id': localId,
      'patient_id': patientId,
      'voice_recording_url': voiceRecordingUrl,
      'transcript': transcript,
      'pain_score': painScore,
      'medication_taken': medicationTaken,
      'sleep_rating': sleepRating,
      'selected_zones': selectedZones,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Reconstruct model from local storage JSON
  factory CheckInModel.fromJson(Map<String, dynamic> json) {
    return CheckInModel(
      localId: json['local_id'] as String?,
      patientId: json['patient_id'] as int? ?? 1,
      voiceRecordingUrl: json['voice_recording_url'] as String?,
      transcript: json['transcript'] as String? ?? '',
      painScore: json['pain_score'] as int?,
      medicationTaken: json['medication_taken'] as bool? ?? false,
      sleepRating: json['sleep_rating'] as int?,
      selectedZones: List<String>.from(json['selected_zones'] ?? []),
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
    );
  }

  String toRawJson() => json.encode(toJson());
  factory CheckInModel.fromRawJson(String str) =>
      CheckInModel.fromJson(json.decode(str));
}

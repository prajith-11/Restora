import 'package:flutter/material.dart';
import 'package:restora_mobile/models/check_in_state.dart';
import 'package:restora_mobile/models/check_in_model.dart';
import 'package:restora_mobile/services/api_service.dart';
import 'package:restora_mobile/services/check_in_storage_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  MicState _micState = MicState.idle;
  final List<String> _selectedZones = [];
  final _notesController = TextEditingController();

  // Local storage service instance
  final _storageService = CheckInStorageService();

  // Speech-to-text instance & availability flag
  late stt.SpeechToText _speech;
  bool _speechInitialized = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  @override
  void dispose() {
    _speech.stop();
    _notesController.dispose();
    super.dispose();
  }

  /// Initialize OS speech engine and request mic permissions
  Future<void> _initSpeech() async {
    _speechInitialized = await _speech.initialize(
      onStatus: (status) {
        debugPrint('STT Status: $status');
        if ((status == 'done' || status == 'notListening') &&
            _micState == MicState.recording) {
          if (mounted) {
            setState(() => _micState = MicState.idle);
          }
        }
      },
      onError: (error) {
        debugPrint('STT Error: ${error.errorMsg}');
        if (mounted) {
          setState(() => _micState = MicState.idle);
        }
      },
    );
    if (mounted) setState(() {});
  }

  void _toggleZone(String zoneId) {
    setState(() {
      if (_selectedZones.contains(zoneId)) {
        _selectedZones.remove(zoneId);
      } else {
        _selectedZones.add(zoneId);
      }
    });
  }

  void _handleMicTap() async {
    if (_micState == MicState.recording) {
      await _speech.stop();
      if (mounted) {
        setState(() => _micState = MicState.idle);
      }
      return;
    }

    if (_micState == MicState.idle && _speechInitialized) {
      setState(() => _micState = MicState.recording);

      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;

          setState(() {
            _notesController.text = result.recognizedWords;
            _notesController.selection = TextSelection.fromPosition(
              TextPosition(offset: _notesController.text.length),
            );
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
      );
    }
  }

  /// Handles creating and saving the CheckInModel locally and syncing to Spring Boot backend
  Future<void> _submitCheckIn() async {
    final checkInRecord = CheckInModel(
      localId: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: 1, // Default patient ID
      transcript: _notesController.text,
      selectedZones: List.from(_selectedZones),
    );

    debugPrint('--- SAVING LOCAL CHECK-IN ---');
    debugPrint('JSON Payload: ${checkInRecord.toRawJson()}');
    debugPrint('-----------------------------');

    final localSuccess = await _storageService.saveCheckIn(checkInRecord);

    bool apiSuccess = false;
    if (localSuccess) {
      debugPrint("---SYNCING TO BACKEND---");
      apiSuccess = await ApiService().sendCheckIn(
        email: 'patient@example.com', // Ensure this email exists in your DB
        transcript:
            _notesController.text, // FIXED: matching backend parameter name
        painZones: _selectedZones.toList(),
      );
    }

    if (mounted) {
      if (localSuccess) {
        final message =
            apiSuccess
                ? 'Check-in saved and synced!'
                : 'Check-in saved locally (Backend offline)';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: apiSuccess ? Colors.teal : Colors.orange.shade700,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save check-in locally.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Check-In')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Describe your knee mobility, extension, or any stiffness you feel today.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _handleMicTap,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor:
                      _micState == MicState.recording
                          ? Colors.red.shade100
                          : Colors.teal.shade100,
                  child:
                      _micState == MicState.processing
                          ? const CircularProgressIndicator()
                          : Icon(
                            _micState == MicState.recording
                                ? Icons.stop
                                : Icons.mic,
                            size: 48,
                            color:
                                _micState == MicState.recording
                                    ? Colors.red
                                    : Colors.teal,
                          ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _micState == MicState.recording
                      ? 'Recording... Tap to stop'
                      : 'Tap mic to speak',
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Or type your notes here instead...',
                border: OutlineInputBorder(),
              ),
            ),
            const Divider(height: 40),

            const Text(
              'Select locations where pain is present:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilterChip(
                  label: const Text('Left Knee'),
                  selected: _selectedZones.contains('KNEE_LEFT'),
                  selectedColor: Colors.teal.shade200,
                  onSelected: (_) => _toggleZone('KNEE_LEFT'),
                ),
                FilterChip(
                  label: const Text('Right Knee'),
                  selected: _selectedZones.contains('KNEE_RIGHT'),
                  selectedColor: Colors.teal.shade200,
                  onSelected: (_) => _toggleZone('KNEE_RIGHT'),
                ),
              ],
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal,
              ),
              onPressed: _submitCheckIn,
              child: const Text(
                'Submit Check-In',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

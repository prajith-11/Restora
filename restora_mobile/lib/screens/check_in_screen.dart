import 'package:flutter/material.dart';
// Fixed: Explicit package import ensures the compiler flags this model correctly across all platforms
import 'package:restora_mobile/models/check_in_state.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  MicState _micState = MicState.idle;
  final List<String> _selectedZones = [];
  final _notesController = TextEditingController();

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
    if (_micState == MicState.idle) {
      setState(() => _micState = MicState.recording);
    } else if (_micState == MicState.recording) {
      setState(() => _micState = MicState.processing);
      // Simulate backend compression buffer delay
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _micState = MicState.idle);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice log compiled successfully!')),
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
            // Voice Loop Segment
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

            // Body Mapping Segment
            const Text(
              'Select locations where pain is present:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Row(
              // Fixed: Swapped incorrect spaceEvenList out for standard spaceEvenly alignment layout
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

            // Submit Segment
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal,
              ),
              onPressed: () {
                // Assert payload schema to debug console
                print('--- PAYLOAD DISPATCH MOCK ---');
                print(
                  'Audio Path Mocked: /data/user/0/restora/cache/mock_log.m4a',
                );
                print('Text Field Notes: ${_notesController.text}');
                print('Selected Zone IDs: $_selectedZones');
                print('----------------------------');

                Navigator.pop(context, true);
              },
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

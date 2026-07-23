import 'package:flutter/material.dart';
import 'package:restora_mobile/models/check_in_model.dart';
import 'package:restora_mobile/services/check_in_storage_service.dart';
import 'package:restora_mobile/screens/check_in_history.dart';
import 'package:restora_mobile/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CheckInStorageService _storageService = CheckInStorageService();

  late Future<List<CheckInModel>> _checkInsFuture;
  bool _alreadyLoggedToday = false;

  @override
  void initState() {
    super.initState();
    _checkInsFuture = _fetchAndEvaluateLogs();
  }

  /// Fetches logs from storage and updates the state cleanly
  Future<List<CheckInModel>> _fetchAndEvaluateLogs() async {
    final logs = await _storageService.getCheckIns();

    if (logs.isNotEmpty) {
      // Commented out only for debugging purposes. If in use uncomment

      // final latestLog = logs.last;
      // final now = DateTime.now();

      // final isToday =
      //     latestLog.createdAt.year == now.year &&
      //     latestLog.createdAt.month == now.month &&
      //     latestLog.createdAt.day == now.day;

      if (mounted) {
        setState(() {
          // _alreadyLoggedToday = isToday;
          // Temporarily set as false, only during the developing phase.
          _alreadyLoggedToday = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _alreadyLoggedToday = false;
        });
      }
    }

    return logs;
  }

  void _refreshDashboard() {
    setState(() {
      _checkInsFuture = _fetchAndEvaluateLogs();
    });
  }

  /// Fetches logs from storage and determines if a check-in occurred today
  void _loadDashboardData() {
    setState(() {
      _checkInsFuture = _storageService.getCheckIns().then((logs) {
        if (logs.isNotEmpty) {
          final latestLog = logs.last;
          final now = DateTime.now();

          // Check if latest log was submitted today (same year, month, and day)
          final isToday =
              latestLog.createdAt.year == now.year &&
              latestLog.createdAt.month == now.month &&
              latestLog.createdAt.day == now.day;

          if (mounted) {
            setState(() {
              _alreadyLoggedToday = isToday;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _alreadyLoggedToday = false;
            });
          }
        }
        return logs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restora Recovery'),
        backgroundColor: Colors.teal.shade100,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Text(
                'Patient Portal',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            const ListTile(leading: Icon(Icons.person), title: Text('Profile')),
            const ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () async {
                Navigator.pop(context); // Close drawer
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CheckInHistoryScreen(),
                  ),
                );
                _loadDashboardData(); // Refresh state after coming back
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Banner
            const Card(
              color: Colors.teal,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                key: Key('status_card'),
                child: Text(
                  'Day 3 of Recovery',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Dynamic Last Log Summary Card
            FutureBuilder<List<CheckInModel>>(
              future: _checkInsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                final logs = snapshot.data ?? [];
                final latestLog = logs.isNotEmpty ? logs.last : null;

                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Last Log Summary',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (latestLog != null) ...[
                          Text(
                            latestLog.transcript.isNotEmpty
                                ? latestLog.transcript
                                : 'No verbal notes provided.',
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 10),
                          if (latestLog.selectedZones.isNotEmpty)
                            Wrap(
                              spacing: 6,
                              children:
                                  latestLog.selectedZones
                                      .map(
                                        (zone) => Chip(
                                          label: Text(
                                            zone,
                                            style: const TextStyle(
                                              fontSize: 11,
                                            ),
                                          ),
                                          backgroundColor: Colors.teal.shade50,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      )
                                      .toList(),
                            )
                          else
                            const Text(
                              'No pain zones selected',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ] else ...[
                          const Text(
                            'No check-ins recorded yet. Tap "Log Today" to complete your first entry!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),

            const Spacer(),

            // Log Today Action Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor:
                    _alreadyLoggedToday ? Colors.grey : Colors.teal,
              ),
              // This onPressed is commented out only for dev purposes!!
              // onPressed:
              //     _alreadyLoggedToday
              //         ? null
              //         : () async {
              //           final result = await Navigator.pushNamed(
              //             context,
              //             '/checkin',
              //           );
              //           if (result == true) {
              //             _loadDashboardData(); // Refresh summary & lock button
              //           }
              //         },
              onPressed: () async {
                final result = await Navigator.pushNamed(context, '/checkin');
                if (result == true) {
                  _refreshDashboard(); // Reloads logs for infinite testing
                }
              },
              child: Text(
                _alreadyLoggedToday ? 'Already Logged Today' : 'Log Today',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

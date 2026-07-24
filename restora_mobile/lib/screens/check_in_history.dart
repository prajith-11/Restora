import 'package:flutter/material.dart';
import 'package:restora_mobile/models/check_in_model.dart';
import 'package:restora_mobile/services/api_service.dart';
import 'package:restora_mobile/services/check_in_storage_service.dart';
import 'package:restora_mobile/screens/check_in_screen.dart';

class CheckInHistoryScreen extends StatefulWidget {
  const CheckInHistoryScreen({super.key});

  @override
  State<CheckInHistoryScreen> createState() => _CheckInHistoryScreenState();
}

class _CheckInHistoryScreenState extends State<CheckInHistoryScreen> {
  final CheckInStorageService _storageService = CheckInStorageService();
  final ApiService _apiService = ApiService();

  late Future<List<CheckInModel>> _checkInsFuture;
  bool _isOfflineMode = false;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  /// Reloads logs from the backend or local cache
  void _refreshHistory() {
    setState(() {
      _checkInsFuture = _loadCheckIns();
    });
  }

  /// Fetches from Spring Boot backend first; falls back to local storage if offline
  Future<List<CheckInModel>> _loadCheckIns() async {
    try {
      // 1. Fetch raw response from API
      final rawLogs = await _apiService.fetchLogs();

      // 2. Map dynamic items into CheckInModel objects
      final List<CheckInModel> remoteLogs =
          rawLogs
              .map(
                (json) => CheckInModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();

      // 3. Save mapped list locally
      await _storageService.saveCheckInsLocally(remoteLogs);

      if (mounted) {
        setState(() => _isOfflineMode = false);
      }
      return remoteLogs;
    } catch (e) {
      debugPrint('Backend unreachable ($e). Loading cached local logs.');

      if (mounted) {
        setState(() => _isOfflineMode = true);
      }
      return await _storageService.getCheckIns();
    }
  }

  /// Formats DateTime into "MMM dd, yyyy" (e.g., "Oct 24, 2024")
  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  /// Formats DateTime into 12-hour "hh:mm AM/PM"
  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-In History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh History',
            onPressed: _refreshHistory,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CheckInScreen()),
          );
          if (result == true) {
            _refreshHistory();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Offline Banner Notification
          if (_isOfflineMode)
            Container(
              color: Colors.amber.shade800,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Offline mode: Showing saved local records',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),

          // Main List View
          Expanded(
            child: FutureBuilder<List<CheckInModel>>(
              future: _checkInsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Error loading history: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final logs = snapshot.data ?? [];

                if (logs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No check-ins saved yet.\nTap the + button below to add one!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final reversedLogs = logs.reversed.toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reversedLogs.length,
                  itemBuilder: (context, index) {
                    final log = reversedLogs[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Transcript on Left, Timestamp Stack on Right
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    log.transcript.isNotEmpty
                                        ? log.transcript
                                        : 'No transcript recorded.',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatDate(log.createdAt),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatTime(log.createdAt),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Selected Pain Zones Chips
                            if (log.selectedZones.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children:
                                    log.selectedZones
                                        .map(
                                          (zone) => Chip(
                                            label: Text(
                                              zone,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            backgroundColor:
                                                Colors.teal.shade50,
                                            visualDensity:
                                                VisualDensity.compact,
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
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

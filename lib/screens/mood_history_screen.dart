import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../services/firestore_service.dart';

class MoodHistoryScreen extends StatefulWidget {
  const MoodHistoryScreen({super.key});

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> {
  final _firestoreService = FirestoreService();
  List<MoodEntry> _moodHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMoodHistory();
  }

  Future<void> _loadMoodHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final history = await _firestoreService.getMoodHistory(user.uid, 7);
        if (mounted) {
          setState(() {
            _moodHistory = history;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error loading history: $e')));
        }
      }
    }
  }

  Future<void> _editNote(MoodEntry entry) async {
    final noteController = TextEditingController(text: entry.note ?? '');

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Note'),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter your note...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                try {
                  await _firestoreService.updateMoodNote(
                    user.uid,
                    entry.timestamp,
                    noteController.text.trim(),
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Note updated successfully!'),
                      ),
                    );
                  }
                  _loadMoodHistory(); // Reload to show updated note
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating note: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_moodHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No mood history yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start logging your moods to see them here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMoodHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _moodHistory.length,
        itemBuilder: (context, index) {
          final entry = _moodHistory[index];
          final dateFormat = DateFormat('MMM dd, yyyy');
          final dayFormat = DateFormat('EEEE');

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: MoodEntry.getMoodColor(entry.mood),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    MoodEntry.getMoodEmoji(entry.mood),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              title: Text(
                dayFormat.format(entry.timestamp),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateFormat.format(entry.timestamp)),
                  if (entry.note != null && entry.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        entry.note!,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.mood.name.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: MoodEntry.getMoodColor(entry.mood),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editNote(entry),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

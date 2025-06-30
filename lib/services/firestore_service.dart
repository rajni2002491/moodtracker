import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mood_entry.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add mood entry for a specific date
  Future<void> addMoodEntry(MoodEntry entry) async {
    final dateString = _formatDate(entry.timestamp);
    await _firestore
        .collection('users')
        .doc(entry.userId)
        .collection('moods')
        .doc(dateString)
        .set(entry.toMap());
  }

  // Check if mood entry exists for a specific date
  Future<bool> moodEntryExists(String userId, DateTime date) async {
    final dateString = _formatDate(date);
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('moods')
        .doc(dateString)
        .get();
    return doc.exists;
  }

  // Get mood entry for a specific date
  Future<MoodEntry?> getMoodEntry(String userId, DateTime date) async {
    final dateString = _formatDate(date);
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('moods')
        .doc(dateString)
        .get();

    if (doc.exists) {
      return MoodEntry.fromFirestore(doc);
    }
    return null;
  }

  // Get mood entries for the last 7 days
  Future<List<MoodEntry>> getMoodHistory(String userId, int days) async {
    final now = DateTime.now();
    final List<MoodEntry> entries = [];

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final entry = await getMoodEntry(userId, date);
      if (entry != null) {
        entries.add(entry);
      }
    }

    return entries;
  }

  // Update note for a specific date
  Future<void> updateMoodNote(String userId, DateTime date, String note) async {
    final dateString = _formatDate(date);
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('moods')
        .doc(dateString)
        .update({'note': note});
  }

  // Get all mood entries for insights
  Future<List<MoodEntry>> getAllMoodEntries(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('moods')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => MoodEntry.fromFirestore(doc)).toList();
  }

  // Format date to YYYY-MM-DD string
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

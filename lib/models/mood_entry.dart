import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum MoodType { happy, sad, angry, neutral }

class MoodEntry {
  final String id;
  final MoodType mood;
  final String? note;
  final DateTime timestamp;
  final String userId;

  MoodEntry({
    required this.id,
    required this.mood,
    this.note,
    required this.timestamp,
    required this.userId,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'mood': mood.name,
      'note': note,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
    };
  }

  // Create from Firestore document
  factory MoodEntry.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MoodEntry(
      id: doc.id,
      mood: MoodType.values.firstWhere(
        (e) => e.name == data['mood'],
        orElse: () => MoodType.neutral,
      ),
      note: data['note'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userId: data['userId'],
    );
  }

  // Create a copy with updated note
  MoodEntry copyWith({String? note}) {
    return MoodEntry(
      id: id,
      mood: mood,
      note: note ?? this.note,
      timestamp: timestamp,
      userId: userId,
    );
  }

  // Get color for mood
  static Color getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return Colors.yellow;
      case MoodType.sad:
        return Colors.blue;
      case MoodType.angry:
        return Colors.red;
      case MoodType.neutral:
        return Colors.grey;
    }
  }

  // Get emoji for mood
  static String getMoodEmoji(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return '😊';
      case MoodType.sad:
        return '😢';
      case MoodType.angry:
        return '😠';
      case MoodType.neutral:
        return '😐';
    }
  }
}

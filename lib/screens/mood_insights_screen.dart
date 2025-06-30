import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mood_entry.dart';
import '../services/firestore_service.dart';

class MoodInsightsScreen extends StatefulWidget {
  const MoodInsightsScreen({super.key});

  @override
  State<MoodInsightsScreen> createState() => _MoodInsightsScreenState();
}

class _MoodInsightsScreenState extends State<MoodInsightsScreen> {
  final _firestoreService = FirestoreService();
  List<MoodEntry> _allMoodEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMoodData();
  }

  Future<void> _loadMoodData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final entries = await _firestoreService.getAllMoodEntries(user.uid);
        setState(() {
          _allMoodEntries = entries;
          _isLoading = false;
        });
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error loading insights: $e')));
        }
      }
    }
  }

  MoodType _getMostFrequentMood() {
    if (_allMoodEntries.isEmpty) return MoodType.neutral;

    final moodCounts = <MoodType, int>{};
    for (final entry in _allMoodEntries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    return moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  double _getHappyPercentage() {
    if (_allMoodEntries.isEmpty) return 0.0;

    final happyCount = _allMoodEntries
        .where((entry) => entry.mood == MoodType.happy)
        .length;

    return (happyCount / _allMoodEntries.length) * 100;
  }

  int _getLongestStreak() {
    if (_allMoodEntries.isEmpty) return 0;

    // Sort entries by date
    final sortedEntries = List<MoodEntry>.from(_allMoodEntries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    int currentStreak = 1;
    int longestStreak = 1;
    MoodType? currentMood;

    for (int i = 0; i < sortedEntries.length; i++) {
      if (currentMood == null) {
        currentMood = sortedEntries[i].mood;
      } else if (sortedEntries[i].mood == currentMood) {
        currentStreak++;
        longestStreak = currentStreak > longestStreak
            ? currentStreak
            : longestStreak;
      } else {
        currentStreak = 1;
        currentMood = sortedEntries[i].mood;
      }
    }

    return longestStreak;
  }

  Widget _buildInsightCard(String title, Widget content, Color color) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allMoodEntries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No insights available yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start logging your moods to see insights',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final mostFrequentMood = _getMostFrequentMood();
    final happyPercentage = _getHappyPercentage();
    final longestStreak = _getLongestStreak();

    return RefreshIndicator(
      onRefresh: _loadMoodData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.analytics, size: 48, color: Colors.blue),
                    const SizedBox(height: 8),
                    Text(
                      'Your Mood Insights',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Based on ${_allMoodEntries.length} mood entries',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildInsightCard(
              'Most Frequent Mood',
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    MoodEntry.getMoodEmoji(mostFrequentMood),
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mostFrequentMood.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Your most common mood',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
              MoodEntry.getMoodColor(mostFrequentMood),
            ),
            const SizedBox(height: 16),
            _buildInsightCard(
              'Happy Days',
              Column(
                children: [
                  Text(
                    '${happyPercentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const Text(
                    'of your days were happy',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildInsightCard(
              'Longest Streak',
              Column(
                children: [
                  Text(
                    '$longestStreak',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const Text(
                    'consecutive days with the same mood',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildInsightCard(
              'Mood Distribution',
              Column(
                children: MoodType.values.map((mood) {
                  final count = _allMoodEntries
                      .where((entry) => entry.mood == mood)
                      .length;
                  final percentage = _allMoodEntries.isEmpty
                      ? 0.0
                      : (count / _allMoodEntries.length) * 100;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          MoodEntry.getMoodEmoji(mood),
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${mood.name.toUpperCase()}: ${percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          '($count)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}

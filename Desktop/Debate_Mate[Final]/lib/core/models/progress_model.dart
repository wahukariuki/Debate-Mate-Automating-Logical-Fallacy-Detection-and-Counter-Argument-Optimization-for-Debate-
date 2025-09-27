import 'package:cloud_firestore/cloud_firestore.dart';

/// Progress history entry model
class ProgressHistoryEntry {
  final DateTime date;
  final int sessionsCount;
  final double improvementScore;
  final String? notes;

  const ProgressHistoryEntry({
    required this.date,
    required this.sessionsCount,
    required this.improvementScore,
    this.notes,
  });

  /// Create ProgressHistoryEntry from Map
  factory ProgressHistoryEntry.fromMap(Map<String, dynamic> data) {
    return ProgressHistoryEntry(
      date: (data['date'] as Timestamp).toDate(),
      sessionsCount: data['sessionsCount'] ?? 0,
      improvementScore: (data['improvementScore'] ?? 0.0).toDouble(),
      notes: data['notes'],
    );
  }

  /// Convert ProgressHistoryEntry to Map
  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'sessionsCount': sessionsCount,
      'improvementScore': improvementScore,
      'notes': notes,
    };
  }

  @override
  String toString() {
    return 'ProgressHistoryEntry(date: $date, sessions: $sessionsCount, score: $improvementScore)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProgressHistoryEntry &&
        other.date == date &&
        other.sessionsCount == sessionsCount &&
        other.improvementScore == improvementScore;
  }

  @override
  int get hashCode {
    return date.hashCode ^ sessionsCount.hashCode ^ improvementScore.hashCode;
  }
}

/// User Progress model representing user's debate practice progress
/// Contains session counts, improvement scores, and history
class ProgressModel {
  final String id;
  final String userId;
  final int sessionsCount;
  final double improvementScore; // 0.0 to 1.0
  final List<ProgressHistoryEntry> history;
  final DateTime lastUpdated;
  final Map<String, dynamic>? achievements;

  const ProgressModel({
    required this.id,
    required this.userId,
    required this.sessionsCount,
    required this.improvementScore,
    required this.history,
    required this.lastUpdated,
    this.achievements,
  });

  /// Create ProgressModel from Firestore document
  factory ProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final historyList = (data['history'] as List<dynamic>?)
        ?.map((entry) => ProgressHistoryEntry.fromMap(Map<String, dynamic>.from(entry)))
        .toList() ?? <ProgressHistoryEntry>[];

    return ProgressModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      sessionsCount: data['sessionsCount'] ?? 0,
      improvementScore: (data['improvementScore'] ?? 0.0).toDouble(),
      history: historyList,
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      achievements: data['achievements'] != null ? Map<String, dynamic>.from(data['achievements']) : null,
    );
  }

  /// Convert ProgressModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'sessionsCount': sessionsCount,
      'improvementScore': improvementScore,
      'history': history.map((entry) => entry.toMap()).toList(),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'achievements': achievements,
    };
  }

  /// Create a copy of ProgressModel with updated fields
  ProgressModel copyWith({
    String? id,
    String? userId,
    int? sessionsCount,
    double? improvementScore,
    List<ProgressHistoryEntry>? history,
    DateTime? lastUpdated,
    Map<String, dynamic>? achievements,
  }) {
    return ProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionsCount: sessionsCount ?? this.sessionsCount,
      improvementScore: improvementScore ?? this.improvementScore,
      history: history ?? this.history,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      achievements: achievements ?? this.achievements,
    );
  }

  /// Get improvement score percentage
  double get improvementPercentage => (improvementScore * 100).roundToDouble();

  /// Get progress level
  String get progressLevel {
    if (improvementScore >= 0.9) return 'Expert';
    if (improvementScore >= 0.8) return 'Advanced';
    if (improvementScore >= 0.6) return 'Intermediate';
    if (improvementScore >= 0.4) return 'Beginner';
    return 'Novice';
  }

  /// Get progress color for UI
  String get progressColor {
    if (improvementScore >= 0.8) return 'green';
    if (improvementScore >= 0.6) return 'blue';
    if (improvementScore >= 0.4) return 'orange';
    return 'red';
  }

  /// Check if user has made progress
  bool get hasProgress => improvementScore > 0.0;

  /// Get recent history (last 7 entries)
  List<ProgressHistoryEntry> get recentHistory {
    final sortedHistory = List<ProgressHistoryEntry>.from(history);
    sortedHistory.sort((a, b) => b.date.compareTo(a.date));
    return sortedHistory.take(7).toList();
  }

  /// Get weekly progress trend
  double get weeklyTrend {
    if (history.length < 2) return 0.0;
    
    final recent = recentHistory.take(7).toList();
    if (recent.length < 2) return 0.0;
    
    final latest = recent.first.improvementScore;
    final previous = recent.last.improvementScore;
    
    return latest - previous;
  }

  /// Check if progress is improving
  bool get isImproving => weeklyTrend > 0.0;

  /// Get achievement count
  int get achievementCount => achievements?.length ?? 0;

  /// Check if user has achievements
  bool get hasAchievements => achievementCount > 0;

  @override
  String toString() {
    return 'ProgressModel(id: $id, userId: $userId, sessions: $sessionsCount, score: $improvementScore, level: $progressLevel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProgressModel &&
        other.id == id &&
        other.userId == userId &&
        other.sessionsCount == sessionsCount &&
        other.improvementScore == improvementScore;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        sessionsCount.hashCode ^
        improvementScore.hashCode;
  }
}





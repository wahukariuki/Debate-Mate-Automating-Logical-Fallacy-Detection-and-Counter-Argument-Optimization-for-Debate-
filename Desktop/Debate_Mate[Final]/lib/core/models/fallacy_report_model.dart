import 'package:cloud_firestore/cloud_firestore.dart';

/// Fallacy model representing a detected logical fallacy
class FallacyModel {
  final String type;
  final String description;
  final int startIndex;
  final int endIndex;
  final double confidence;
  final String? suggestion;

  const FallacyModel({
    required this.type,
    required this.description,
    required this.startIndex,
    required this.endIndex,
    required this.confidence,
    this.suggestion,
  });

  /// Create FallacyModel from Map
  factory FallacyModel.fromMap(Map<String, dynamic> data) {
    return FallacyModel(
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      startIndex: data['startIndex'] ?? 0,
      endIndex: data['endIndex'] ?? 0,
      confidence: (data['confidence'] ?? 0.0).toDouble(),
      suggestion: data['suggestion'],
    );
  }

  /// Convert FallacyModel to Map
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'description': description,
      'startIndex': startIndex,
      'endIndex': endIndex,
      'confidence': confidence,
      'suggestion': suggestion,
    };
  }

  @override
  String toString() {
    return 'FallacyModel(type: $type, confidence: $confidence, startIndex: $startIndex, endIndex: $endIndex)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FallacyModel &&
        other.type == type &&
        other.startIndex == startIndex &&
        other.endIndex == endIndex;
  }

  @override
  int get hashCode {
    return type.hashCode ^ startIndex.hashCode ^ endIndex.hashCode;
  }
}

/// Fallacy Report model representing analysis results for an argument
/// Contains detected fallacies and overall score
class FallacyReportModel {
  final String id;
  final String argumentId;
  final List<FallacyModel> fallacies;
  final double score; // 0.0 to 1.0 (higher is better)
  final DateTime timestamp;
  final String status; // 'processing', 'completed', 'failed'
  final String? errorMessage;

  const FallacyReportModel({
    required this.id,
    required this.argumentId,
    required this.fallacies,
    required this.score,
    required this.timestamp,
    required this.status,
    this.errorMessage,
  });

  /// Create FallacyReportModel from Firestore document
  factory FallacyReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final fallaciesList = (data['fallacies'] as List<dynamic>?)
        ?.map((fallacy) => FallacyModel.fromMap(Map<String, dynamic>.from(fallacy)))
        .toList() ?? <FallacyModel>[];

    return FallacyReportModel(
      id: doc.id,
      argumentId: data['argumentId'] ?? '',
      fallacies: fallaciesList,
      score: (data['score'] ?? 0.0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      status: data['status'] ?? 'processing',
      errorMessage: data['errorMessage'],
    );
  }

  /// Convert FallacyReportModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'argumentId': argumentId,
      'fallacies': fallacies.map((fallacy) => fallacy.toMap()).toList(),
      'score': score,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
      'errorMessage': errorMessage,
    };
  }

  /// Create a copy of FallacyReportModel with updated fields
  FallacyReportModel copyWith({
    String? id,
    String? argumentId,
    List<FallacyModel>? fallacies,
    double? score,
    DateTime? timestamp,
    String? status,
    String? errorMessage,
  }) {
    return FallacyReportModel(
      id: id ?? this.id,
      argumentId: argumentId ?? this.argumentId,
      fallacies: fallacies ?? this.fallacies,
      score: score ?? this.score,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Check if report is processing
  bool get isProcessing => status == 'processing';

  /// Check if report is completed
  bool get isCompleted => status == 'completed';

  /// Check if report failed
  bool get isFailed => status == 'failed';

  /// Get fallacy count
  int get fallacyCount => fallacies.length;

  /// Check if argument has any fallacies
  bool get hasFallacies => fallacies.isNotEmpty;

  /// Get score percentage
  double get scorePercentage => (score * 100).roundToDouble();

  /// Get score grade
  String get scoreGrade {
    if (score >= 0.9) return 'Excellent';
    if (score >= 0.8) return 'Good';
    if (score >= 0.7) return 'Fair';
    if (score >= 0.6) return 'Poor';
    return 'Very Poor';
  }

  @override
  String toString() {
    return 'FallacyReportModel(id: $id, argumentId: $argumentId, fallacies: ${fallacies.length}, score: $score, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FallacyReportModel &&
        other.id == id &&
        other.argumentId == argumentId &&
        other.score == score &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        argumentId.hashCode ^
        score.hashCode ^
        status.hashCode;
  }
}





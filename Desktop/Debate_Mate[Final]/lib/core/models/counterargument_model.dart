import 'package:cloud_firestore/cloud_firestore.dart';

/// Optimization model representing improvements to an argument
class OptimizationModel {
  final String type;
  final String description;
  final String suggestion;
  final double impact; // 0.0 to 1.0 (higher impact)

  const OptimizationModel({
    required this.type,
    required this.description,
    required this.suggestion,
    required this.impact,
  });

  /// Create OptimizationModel from Map
  factory OptimizationModel.fromMap(Map<String, dynamic> data) {
    return OptimizationModel(
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      suggestion: data['suggestion'] ?? '',
      impact: (data['impact'] ?? 0.0).toDouble(),
    );
  }

  /// Convert OptimizationModel to Map
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'description': description,
      'suggestion': suggestion,
      'impact': impact,
    };
  }

  @override
  String toString() {
    return 'OptimizationModel(type: $type, impact: $impact)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OptimizationModel &&
        other.type == type &&
        other.impact == impact;
  }

  @override
  int get hashCode {
    return type.hashCode ^ impact.hashCode;
  }
}

/// Counterargument model representing AI-generated counterarguments
/// Contains counterargument content and optimization suggestions
class CounterargumentModel {
  final String id;
  final String argumentId;
  final String content;
  final List<OptimizationModel> optimizations;
  final double rating; // 0.0 to 5.0 (user rating)
  final DateTime timestamp;
  final String status; // 'generating', 'completed', 'failed'
  final String? errorMessage;

  const CounterargumentModel({
    required this.id,
    required this.argumentId,
    required this.content,
    required this.optimizations,
    required this.rating,
    required this.timestamp,
    required this.status,
    this.errorMessage,
  });

  /// Create CounterargumentModel from Firestore document
  factory CounterargumentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final optimizationsList = (data['optimizations'] as List<dynamic>?)
        ?.map((opt) => OptimizationModel.fromMap(Map<String, dynamic>.from(opt)))
        .toList() ?? <OptimizationModel>[];

    return CounterargumentModel(
      id: doc.id,
      argumentId: data['argumentId'] ?? '',
      content: data['content'] ?? '',
      optimizations: optimizationsList,
      rating: (data['rating'] ?? 0.0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      status: data['status'] ?? 'generating',
      errorMessage: data['errorMessage'],
    );
  }

  /// Convert CounterargumentModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'argumentId': argumentId,
      'content': content,
      'optimizations': optimizations.map((opt) => opt.toMap()).toList(),
      'rating': rating,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
      'errorMessage': errorMessage,
    };
  }

  /// Create a copy of CounterargumentModel with updated fields
  CounterargumentModel copyWith({
    String? id,
    String? argumentId,
    String? content,
    List<OptimizationModel>? optimizations,
    double? rating,
    DateTime? timestamp,
    String? status,
    String? errorMessage,
  }) {
    return CounterargumentModel(
      id: id ?? this.id,
      argumentId: argumentId ?? this.argumentId,
      content: content ?? this.content,
      optimizations: optimizations ?? this.optimizations,
      rating: rating ?? this.rating,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Check if counterargument is generating
  bool get isGenerating => status == 'generating';

  /// Check if counterargument is completed
  bool get isCompleted => status == 'completed';

  /// Check if counterargument failed
  bool get isFailed => status == 'failed';

  /// Get optimization count
  int get optimizationCount => optimizations.length;

  /// Check if counterargument has optimizations
  bool get hasOptimizations => optimizations.isNotEmpty;

  /// Get average optimization impact
  double get averageImpact {
    if (optimizations.isEmpty) return 0.0;
    return optimizations.map((opt) => opt.impact).reduce((a, b) => a + b) / optimizations.length;
  }

  /// Get rating stars (for UI display)
  int get ratingStars => rating.round();

  /// Check if counterargument is highly rated
  bool get isHighlyRated => rating >= 4.0;

  @override
  String toString() {
    return 'CounterargumentModel(id: $id, argumentId: $argumentId, content: ${content.substring(0, content.length > 50 ? 50 : content.length)}..., rating: $rating, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CounterargumentModel &&
        other.id == id &&
        other.argumentId == argumentId &&
        other.content == content &&
        other.rating == rating;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        argumentId.hashCode ^
        content.hashCode ^
        rating.hashCode;
  }
}





import 'package:cloud_firestore/cloud_firestore.dart';

/// Argument model representing a debate argument
/// Contains argument information including content, type, and status
class ArgumentModel {
  final String id;
  final String userId;
  final DateTime timestamp;
  final String content;
  final String type; // 'pro', 'con', 'neutral'
  final String status; // 'pending', 'analyzed', 'completed'
  final String? topic;
  final Map<String, dynamic>? metadata;

  const ArgumentModel({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.content,
    required this.type,
    required this.status,
    this.topic,
    this.metadata,
  });

  /// Create ArgumentModel from Firestore document
  factory ArgumentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ArgumentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      content: data['content'] ?? '',
      type: data['type'] ?? 'neutral',
      status: data['status'] ?? 'pending',
      topic: data['topic'],
      metadata: data['metadata'] != null ? Map<String, dynamic>.from(data['metadata']) : null,
    );
  }

  /// Convert ArgumentModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
      'content': content,
      'type': type,
      'status': status,
      'topic': topic,
      'metadata': metadata,
    };
  }

  /// Create a copy of ArgumentModel with updated fields
  ArgumentModel copyWith({
    String? id,
    String? userId,
    DateTime? timestamp,
    String? content,
    String? type,
    String? status,
    String? topic,
    Map<String, dynamic>? metadata,
  }) {
    return ArgumentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      topic: topic ?? this.topic,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if argument is pro
  bool get isPro => type == 'pro';

  /// Check if argument is con
  bool get isCon => type == 'con';

  /// Check if argument is neutral
  bool get isNeutral => type == 'neutral';

  /// Check if argument is pending analysis
  bool get isPending => status == 'pending';

  /// Check if argument is analyzed
  bool get isAnalyzed => status == 'analyzed';

  /// Check if argument is completed
  bool get isCompleted => status == 'completed';

  @override
  String toString() {
    return 'ArgumentModel(id: $id, userId: $userId, content: ${content.substring(0, content.length > 50 ? 50 : content.length)}..., type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArgumentModel &&
        other.id == id &&
        other.userId == userId &&
        other.content == content &&
        other.type == type &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        content.hashCode ^
        type.hashCode ^
        status.hashCode;
  }
}






import '../../../core/models/fallacy_report_model.dart';
import '../../../core/models/counterargument_model.dart';

/// Chat message model for the dashboard
class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final ChatMessageType messageType;
  final FallacyReportModel? fallacyReport;
  final CounterargumentModel? counterarguments;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    required this.messageType,
    this.fallacyReport,
    this.counterarguments,
  });

  factory ChatMessage.fromJson(String json) {
    // This is a simplified implementation
    // In a real app, you'd use proper JSON parsing
    final parts = json.split('|');
    return ChatMessage(
      id: parts[0],
      content: parts[1],
      isUser: parts[2] == 'true',
      timestamp: DateTime.parse(parts[3]),
      messageType: ChatMessageType.values.firstWhere(
        (type) => type.toString().split('.').last == parts[4],
        orElse: () => ChatMessageType.userInput,
      ),
    );
  }

  String toJson() {
    return '$id|$content|$isUser|${timestamp.toIso8601String()}|${messageType.toString().split('.').last}';
  }
}

/// Chat message type enum
enum ChatMessageType {
  welcome,
  userInput,
  aiResponse,
  error,
}

/// Progress data model
class ProgressData {
  final DateTime date;
  final double score;
  final int fallaciesDetected;
  final int optimizationsGenerated;

  const ProgressData({
    required this.date,
    required this.score,
    required this.fallaciesDetected,
    required this.optimizationsGenerated,
  });
}

/// Export format enum
enum ExportFormat {
  pdf,
  text,
}

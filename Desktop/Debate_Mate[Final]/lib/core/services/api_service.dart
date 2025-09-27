// import 'dart:convert';
// import 'package:http/http.dart' as http;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:logger/logger.dart';

import '../models/argument_model.dart';
import '../models/fallacy_report_model.dart';
import '../models/counterargument_model.dart';
import '../models/progress_model.dart';

/// API service for handling all backend communications
/// Includes CRUD operations and NLP processing calls
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final Logger _logger = Logger();

  /// Helper method to create ArgumentModel from API response data
  ArgumentModel _createArgumentFromData(Map<String, dynamic> data) {
    return ArgumentModel(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      timestamp: data['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'])
          : DateTime.now(),
      content: data['content'] ?? '',
      type: data['type'] ?? 'neutral',
      status: data['status'] ?? 'pending',
      topic: data['topic'],
      metadata: data['metadata'] ?? {},
    );
  }

  /// Helper method to create FallacyReportModel from API response data
  FallacyReportModel _createFallacyReportFromData(Map<String, dynamic> data) {
    return FallacyReportModel(
      id: data['id'] ?? '',
      argumentId: data['argumentId'] ?? '',
      fallacies: (data['fallacies'] as List<dynamic>?)
          ?.map((fallacy) => FallacyModel.fromMap(Map<String, dynamic>.from(fallacy)))
          .toList() ?? [],
      score: (data['score'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'processing',
      timestamp: data['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'])
          : DateTime.now(),
      errorMessage: data['errorMessage'],
    );
  }

  /// Helper method to create CounterargumentModel from API response data
  CounterargumentModel _createCounterargumentFromData(Map<String, dynamic> data) {
    return CounterargumentModel(
      id: data['id'] ?? '',
      argumentId: data['argumentId'] ?? '',
      content: data['content'] ?? '',
      optimizations: (data['optimizations'] as List<dynamic>?)
          ?.map((opt) => OptimizationModel.fromMap(Map<String, dynamic>.from(opt)))
          .toList() ?? [],
      rating: (data['rating'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'generating',
      timestamp: data['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'])
          : DateTime.now(),
      errorMessage: data['errorMessage'],
    );
  }

  /// Helper method to create ProgressModel from API response data
  ProgressModel _createUserProgressFromData(Map<String, dynamic> data) {
    return ProgressModel(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      sessionsCount: data['sessionsCount'] ?? 0,
      improvementScore: (data['improvementScore'] ?? 0.0).toDouble(),
      history: (data['history'] as List<dynamic>?)
          ?.map((entry) => ProgressHistoryEntry.fromMap(Map<String, dynamic>.from(entry)))
          .toList() ?? [],
      lastUpdated: data['lastUpdated'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['lastUpdated'])
          : DateTime.now(),
      achievements: data['achievements'],
    );
  }

  // Base URL for Cloud Functions (will be set based on environment)
  // String get _baseUrl => 'https://us-central1-debatematef.cloudfunctions.net';

  /// Submit argument for analysis
  Future<ArgumentModel> submitArgument({
    required String userId,
    required String content,
    required String type,
    String? topic,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _logger.i('Submitting argument for analysis');
      
      final HttpsCallable callable = _functions.httpsCallable('submitArgument');
      final HttpsCallableResult result = await callable.call({
        'userId': userId,
        'content': content,
        'type': type,
        'topic': topic,
        'metadata': metadata,
      });

      if (result.data['success'] == true) {
        final argumentData = Map<String, dynamic>.from(result.data['argument']);
        _logger.i('Argument submitted successfully: ${argumentData['id']}');
        return _createArgumentFromData(argumentData);
      } else {
        throw Exception(result.data['error'] ?? 'Failed to submit argument');
      }
    } catch (e) {
      _logger.e('Error submitting argument: $e');
      throw Exception('Failed to submit argument: $e');
    }
  }

  /// Get arguments for a user
  Future<List<ArgumentModel>> getArguments({
    required String userId,
    String? status,
    String? type,
    int? limit,
  }) async {
    try {
      _logger.i('Fetching arguments for user: $userId');
      
      final HttpsCallable callable = _functions.httpsCallable('getArguments');
      final HttpsCallableResult result = await callable.call({
        'userId': userId,
        'status': status,
        'type': type,
        'limit': limit,
      });

      if (result.data['success'] == true) {
        final argumentsList = (result.data['arguments'] as List<dynamic>)
            .map((arg) => _createArgumentFromData(Map<String, dynamic>.from(arg)))
            .toList();
        
        _logger.i('Fetched ${argumentsList.length} arguments');
        return argumentsList;
      } else {
        throw Exception(result.data['error'] ?? 'Failed to fetch arguments');
      }
    } catch (e) {
      _logger.e('Error fetching arguments: $e');
      throw Exception('Failed to fetch arguments: $e');
    }
  }

  /// Update argument
  Future<ArgumentModel> updateArgument({
    required String argumentId,
    required String userId,
    String? content,
    String? type,
    String? status,
    String? topic,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _logger.i('Updating argument: $argumentId');
      
      final HttpsCallable callable = _functions.httpsCallable('updateArgument');
      final HttpsCallableResult result = await callable.call({
        'argumentId': argumentId,
        'userId': userId,
        'content': content,
        'type': type,
        'status': status,
        'topic': topic,
        'metadata': metadata,
      });

      if (result.data['success'] == true) {
        final argumentData = Map<String, dynamic>.from(result.data['argument']);
        _logger.i('Argument updated successfully');
        return _createArgumentFromData(argumentData);
      } else {
        throw Exception(result.data['error'] ?? 'Failed to update argument');
      }
    } catch (e) {
      _logger.e('Error updating argument: $e');
      throw Exception('Failed to update argument: $e');
    }
  }

  /// Delete argument
  Future<void> deleteArgument({
    required String argumentId,
    required String userId,
  }) async {
    try {
      _logger.i('Deleting argument: $argumentId');
      
      final HttpsCallable callable = _functions.httpsCallable('deleteArgument');
      final HttpsCallableResult result = await callable.call({
        'argumentId': argumentId,
        'userId': userId,
      });

      if (result.data['success'] == true) {
        _logger.i('Argument deleted successfully');
      } else {
        throw Exception(result.data['error'] ?? 'Failed to delete argument');
      }
    } catch (e) {
      _logger.e('Error deleting argument: $e');
      throw Exception('Failed to delete argument: $e');
    }
  }

  /// Analyze argument for fallacies
  Future<FallacyReportModel> analyzeFallacies({
    required String argumentId,
    required String content,
  }) async {
    try {
      _logger.i('Analyzing fallacies for argument: $argumentId');
      
      final HttpsCallable callable = _functions.httpsCallable('analyzeFallacies');
      final HttpsCallableResult result = await callable.call({
        'argumentId': argumentId,
        'content': content,
      });

      if (result.data['success'] == true) {
        final reportData = Map<String, dynamic>.from(result.data['report']);
        _logger.i('Fallacy analysis completed');
        return _createFallacyReportFromData(reportData);
      } else {
        throw Exception(result.data['error'] ?? 'Failed to analyze fallacies');
      }
    } catch (e) {
      _logger.e('Error analyzing fallacies: $e');
      throw Exception('Failed to analyze fallacies: $e');
    }
  }

  /// Generate counterarguments
  Future<CounterargumentModel> generateCounterarguments({
    required String argumentId,
    required String content,
    required String type,
  }) async {
    try {
      _logger.i('Generating counterarguments for argument: $argumentId');
      
      final HttpsCallable callable = _functions.httpsCallable('generateCounterarguments');
      final HttpsCallableResult result = await callable.call({
        'argumentId': argumentId,
        'content': content,
        'type': type,
      });

      if (result.data['success'] == true) {
        final counterData = Map<String, dynamic>.from(result.data['counterargument']);
        _logger.i('Counterarguments generated successfully');
        return _createCounterargumentFromData(counterData);
      } else {
        throw Exception(result.data['error'] ?? 'Failed to generate counterarguments');
      }
    } catch (e) {
      _logger.e('Error generating counterarguments: $e');
      throw Exception('Failed to generate counterarguments: $e');
    }
  }

  /// Rate counterargument
  Future<CounterargumentModel> rateCounterargument({
    required String counterargumentId,
    required double rating,
  }) async {
    try {
      _logger.i('Rating counterargument: $counterargumentId');
      
      final HttpsCallable callable = _functions.httpsCallable('rateCounterargument');
      final HttpsCallableResult result = await callable.call({
        'counterargumentId': counterargumentId,
        'rating': rating,
      });

      if (result.data['success'] == true) {
        final counterData = Map<String, dynamic>.from(result.data['counterargument']);
        _logger.i('Counterargument rated successfully');
        return _createCounterargumentFromData(counterData);
      } else {
        throw Exception(result.data['error'] ?? 'Failed to rate counterargument');
      }
    } catch (e) {
      _logger.e('Error rating counterargument: $e');
      throw Exception('Failed to rate counterargument: $e');
    }
  }

  /// Get user progress
  Future<ProgressModel> getUserProgress({
    required String userId,
  }) async {
    try {
      _logger.i('Fetching user progress: $userId');
      
      final HttpsCallable callable = _functions.httpsCallable('getUserProgress');
      final HttpsCallableResult result = await callable.call({
        'userId': userId,
      });

      if (result.data['success'] == true) {
        final progressData = Map<String, dynamic>.from(result.data['progress']);
        _logger.i('User progress fetched successfully');
        return _createUserProgressFromData(progressData);
      } else {
        throw Exception(result.data['error'] ?? 'Failed to fetch user progress');
      }
    } catch (e) {
      _logger.e('Error fetching user progress: $e');
      throw Exception('Failed to fetch user progress: $e');
    }
  }

  /// Update user progress
  Future<ProgressModel> updateUserProgress({
    required String userId,
    required int sessionsCount,
    required double improvementScore,
    String? notes,
  }) async {
    try {
      _logger.i('Updating user progress: $userId');
      
      final HttpsCallable callable = _functions.httpsCallable('updateUserProgress');
      final HttpsCallableResult result = await callable.call({
        'userId': userId,
        'sessionsCount': sessionsCount,
        'improvementScore': improvementScore,
        'notes': notes,
      });

      if (result.data['success'] == true) {
        final progressData = Map<String, dynamic>.from(result.data['progress']);
        _logger.i('User progress updated successfully');
        return _createUserProgressFromData(progressData);
      } else {
        throw Exception(result.data['error'] ?? 'Failed to update user progress');
      }
    } catch (e) {
      _logger.e('Error updating user progress: $e');
      throw Exception('Failed to update user progress: $e');
    }
  }

  /// Get all users (Admin only)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      _logger.i('Fetching all users (Admin)');
      
      final HttpsCallable callable = _functions.httpsCallable('getAllUsers');
      final HttpsCallableResult result = await callable.call();

      if (result.data['success'] == true) {
        final usersList = (result.data['users'] as List<dynamic>)
            .map((user) => Map<String, dynamic>.from(user))
            .toList();
        
        _logger.i('Fetched ${usersList.length} users');
        return usersList;
      } else {
        throw Exception(result.data['error'] ?? 'Failed to fetch users');
      }
    } catch (e) {
      _logger.e('Error fetching users: $e');
      throw Exception('Failed to fetch users: $e');
    }
  }

  /// Update user role (Admin only)
  Future<void> updateUserRole({
    required String userId,
    required String role,
  }) async {
    try {
      _logger.i('Updating user role: $userId to $role');
      
      final HttpsCallable callable = _functions.httpsCallable('updateUserRole');
      final HttpsCallableResult result = await callable.call({
        'userId': userId,
        'role': role,
      });

      if (result.data['success'] == true) {
        _logger.i('User role updated successfully');
      } else {
        throw Exception(result.data['error'] ?? 'Failed to update user role');
      }
    } catch (e) {
      _logger.e('Error updating user role: $e');
      throw Exception('Failed to update user role: $e');
    }
  }

  /// Get platform statistics (Admin only)
  Future<Map<String, dynamic>> getPlatformStats() async {
    try {
      _logger.i('Fetching platform statistics');
      
      final HttpsCallable callable = _functions.httpsCallable('getPlatformStats');
      final HttpsCallableResult result = await callable.call();

      if (result.data['success'] == true) {
        final stats = Map<String, dynamic>.from(result.data['stats']);
        _logger.i('Platform statistics fetched successfully');
        return stats;
      } else {
        throw Exception(result.data['error'] ?? 'Failed to fetch platform statistics');
      }
    } catch (e) {
      _logger.e('Error fetching platform statistics: $e');
      throw Exception('Failed to fetch platform statistics: $e');
    }
  }
}


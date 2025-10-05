import 'package:cloud_functions/cloud_functions.dart';
import 'package:logger/logger.dart';

import '../models/counterargument_model.dart';
import '../models/fallacy_report_model.dart';
import 'api_service.dart';

/// Enhanced API service for real-time debate analysis
class EnhancedApiService {
  static final EnhancedApiService _instance = EnhancedApiService._internal();
  factory EnhancedApiService() => _instance;
  EnhancedApiService._internal();

  final ApiService _apiService = ApiService();
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final Logger _logger = Logger();

  /// Submit argument and get immediate analysis
  Future<Map<String, dynamic>> submitArgumentWithAnalysis({
    required String userId,
    required String content,
    required String type,
    String? topic,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _logger.i('Submitting argument with immediate analysis');
      
      // Submit argument first
      final argument = await _apiService.submitArgument(
        userId: userId,
        content: content,
        type: type,
        topic: topic,
        metadata: metadata,
      );

      // Get analysis results
      final fallacyReport = await _apiService.analyzeFallacies(
        argumentId: argument.id,
        content: content,
      );

      final counterarguments = await _apiService.generateCounterarguments(
        argumentId: argument.id,
        content: content,
        type: type,
      );

      return {
        'argument': argument,
        'fallacyReport': fallacyReport,
        'counterarguments': counterarguments,
      };
    } catch (e) {
      _logger.e('Error submitting argument with analysis: $e');
      throw Exception('Failed to submit argument with analysis: $e');
    }
  }

  /// Real-time fallacy detection with streaming results
  Stream<FallacyReportModel> streamFallacyAnalysis({
    required String argumentId,
    required String content,
  }) async* {
    try {
      _logger.i('Starting streaming fallacy analysis for argument: $argumentId');
      
      // Initial processing state
      yield FallacyReportModel(
        id: 'temp_$argumentId',
        argumentId: argumentId,
        fallacies: [],
        score: 0.0,
        timestamp: DateTime.now(),
        status: 'processing',
      );

      // Simulate streaming analysis
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Yield partial results
      yield FallacyReportModel(
        id: 'temp_$argumentId',
        argumentId: argumentId,
        fallacies: [],
        score: 0.3,
        timestamp: DateTime.now(),
        status: 'processing',
      );

      await Future.delayed(const Duration(milliseconds: 1000));

      // Get final results
      final finalReport = await _apiService.analyzeFallacies(
        argumentId: argumentId,
        content: content,
      );

      yield finalReport;
    } catch (e) {
      _logger.e('Error in streaming fallacy analysis: $e');
      yield FallacyReportModel(
        id: 'error_$argumentId',
        argumentId: argumentId,
        fallacies: [],
        score: 0.0,
        timestamp: DateTime.now(),
        status: 'failed',
        errorMessage: e.toString(),
      );
    }
  }

  /// Real-time counter-argument generation with streaming
  Stream<CounterargumentModel> streamCounterargumentGeneration({
    required String argumentId,
    required String content,
    required String type,
  }) async* {
    try {
      _logger.i('Starting streaming counterargument generation for argument: $argumentId');
      
      // Initial generating state
      yield CounterargumentModel(
        id: 'temp_$argumentId',
        argumentId: argumentId,
        content: '',
        optimizations: [],
        rating: 0.0,
        timestamp: DateTime.now(),
        status: 'generating',
      );

      // Simulate streaming generation
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Yield partial content
      yield CounterargumentModel(
        id: 'temp_$argumentId',
        argumentId: argumentId,
        content: 'Analyzing your argument structure...',
        optimizations: [],
        rating: 0.0,
        timestamp: DateTime.now(),
        status: 'generating',
      );

      await Future.delayed(const Duration(milliseconds: 1200));

      // Get final results
      final finalCounterarguments = await _apiService.generateCounterarguments(
        argumentId: argumentId,
        content: content,
        type: type,
      );

      yield finalCounterarguments;
    } catch (e) {
      _logger.e('Error in streaming counterargument generation: $e');
      yield CounterargumentModel(
        id: 'error_$argumentId',
        argumentId: argumentId,
        content: '',
        optimizations: [],
        rating: 0.0,
        timestamp: DateTime.now(),
        status: 'failed',
        errorMessage: e.toString(),
      );
    }
  }

  /// Get debate session statistics
  Future<Map<String, dynamic>> getDebateSessionStats({
    required String userId,
    int days = 30,
  }) async {
    try {
      _logger.i('Getting debate session stats for user: $userId');
      
      final HttpsCallable callable = _functions.httpsCallable('getDebateSessionStats');
      final HttpsCallableResult result = await callable.call({
        'userId': userId,
        'days': days,
      });

      if (result.data['success'] == true) {
        _logger.i('Debate session stats retrieved successfully');
        return Map<String, dynamic>.from(result.data['stats']);
      } else {
        throw Exception(result.data['error'] ?? 'Failed to get debate session stats');
      }
    } catch (e) {
      _logger.e('Error getting debate session stats: $e');
      throw Exception('Failed to get debate session stats: $e');
    }
  }

  /// Get argument strength analysis
  Future<Map<String, dynamic>> analyzeArgumentStrength({
    required String content,
    required String type,
  }) async {
    try {
      _logger.i('Analyzing argument strength');
      
      final HttpsCallable callable = _functions.httpsCallable('analyzeArgumentStrength');
      final HttpsCallableResult result = await callable.call({
        'content': content,
        'type': type,
      });

      if (result.data['success'] == true) {
        _logger.i('Argument strength analysis completed');
        return Map<String, dynamic>.from(result.data['analysis']);
      } else {
        throw Exception(result.data['error'] ?? 'Failed to analyze argument strength');
      }
    } catch (e) {
      _logger.e('Error analyzing argument strength: $e');
      throw Exception('Failed to analyze argument strength: $e');
    }
  }

  /// Get personalized feedback based on user's debate history
  Future<Map<String, dynamic>> getPersonalizedFeedback({
    required String userId,
    required String content,
  }) async {
    try {
      _logger.i('Getting personalized feedback for user: $userId');
      
      final HttpsCallable callable = _functions.httpsCallable('getPersonalizedFeedback');
      final HttpsCallableResult result = await callable.call({
        'userId': userId,
        'content': content,
      });

      if (result.data['success'] == true) {
        _logger.i('Personalized feedback generated successfully');
        return Map<String, dynamic>.from(result.data['feedback']);
      } else {
        throw Exception(result.data['error'] ?? 'Failed to get personalized feedback');
      }
    } catch (e) {
      _logger.e('Error getting personalized feedback: $e');
      throw Exception('Failed to get personalized feedback: $e');
    }
  }

  /// Save debate session for later analysis
  Future<void> saveDebateSession({
    required String userId,
    required List<Map<String, dynamic>> messages,
    required Map<String, dynamic> sessionData,
  }) async {
    try {
      _logger.i('Saving debate session for user: $userId');
      
      final HttpsCallable callable = _functions.httpsCallable('saveDebateSession');
      final HttpsCallableResult result = await callable.call({
        'userId': userId,
        'messages': messages,
        'sessionData': sessionData,
      });

      if (result.data['success'] == true) {
        _logger.i('Debate session saved successfully');
      } else {
        throw Exception(result.data['error'] ?? 'Failed to save debate session');
      }
    } catch (e) {
      _logger.e('Error saving debate session: $e');
      throw Exception('Failed to save debate session: $e');
    }
  }

  /// Get debate practice suggestions
  Future<List<Map<String, dynamic>>> getPracticeSuggestions({
    required String userId,
    required String skillLevel,
    int count = 5,
  }) async {
    try {
      _logger.i('Getting practice suggestions for user: $userId');
      
      final HttpsCallable callable = _functions.httpsCallable('getPracticeSuggestions');
      final HttpsCallableResult result = await callable.call({
        'userId': userId,
        'skillLevel': skillLevel,
        'count': count,
      });

      if (result.data['success'] == true) {
        _logger.i('Practice suggestions retrieved successfully');
        return List<Map<String, dynamic>>.from(result.data['suggestions']);
      } else {
        throw Exception(result.data['error'] ?? 'Failed to get practice suggestions');
      }
    } catch (e) {
      _logger.e('Error getting practice suggestions: $e');
      throw Exception('Failed to get practice suggestions: $e');
    }
  }

  /// Rate AI feedback for machine learning improvement
  Future<void> rateAIFeedback({
    required String sessionId,
    required String feedbackId,
    required double rating,
    String? comment,
  }) async {
    try {
      _logger.i('Rating AI feedback: $feedbackId');
      
      final HttpsCallable callable = _functions.httpsCallable('rateAIFeedback');
      final HttpsCallableResult result = await callable.call({
        'sessionId': sessionId,
        'feedbackId': feedbackId,
        'rating': rating,
        'comment': comment,
      });

      if (result.data['success'] == true) {
        _logger.i('AI feedback rated successfully');
      } else {
        throw Exception(result.data['error'] ?? 'Failed to rate AI feedback');
      }
    } catch (e) {
      _logger.e('Error rating AI feedback: $e');
      throw Exception('Failed to rate AI feedback: $e');
    }
  }

  /// Get trending debate topics
  Future<List<Map<String, dynamic>>> getTrendingTopics({
    int count = 10,
  }) async {
    try {
      _logger.i('Getting trending debate topics');
      
      final HttpsCallable callable = _functions.httpsCallable('getTrendingTopics');
      final HttpsCallableResult result = await callable.call({
        'count': count,
      });

      if (result.data['success'] == true) {
        _logger.i('Trending topics retrieved successfully');
        return List<Map<String, dynamic>>.from(result.data['topics']);
      } else {
        throw Exception(result.data['error'] ?? 'Failed to get trending topics');
      }
    } catch (e) {
      _logger.e('Error getting trending topics: $e');
      throw Exception('Failed to get trending topics: $e');
    }
  }

  /// Analyze debate performance over time
  Future<Map<String, dynamic>> analyzePerformanceTrends({
    required String userId,
    int months = 6,
  }) async {
    try {
      _logger.i('Analyzing performance trends for user: $userId');
      
      final HttpsCallable callable = _functions.httpsCallable('analyzePerformanceTrends');
      final HttpsCallableResult result = await callable.call({
        'userId': userId,
        'months': months,
      });

      if (result.data['success'] == true) {
        _logger.i('Performance trends analysis completed');
        return Map<String, dynamic>.from(result.data['trends']);
      } else {
        throw Exception(result.data['error'] ?? 'Failed to analyze performance trends');
      }
    } catch (e) {
      _logger.e('Error analyzing performance trends: $e');
      throw Exception('Failed to analyze performance trends: $e');
    }
  }
}

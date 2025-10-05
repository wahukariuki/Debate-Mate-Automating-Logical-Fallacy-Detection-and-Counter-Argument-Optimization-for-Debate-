import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'firebase_admin_service.dart';

/// Admin service for managing admin dashboard data and operations
/// Now uses Firebase for real data instead of mock data
class AdminService {
  static const String _baseUrl = 'https://api.debatemate.com'; // Replace with actual API URL
  static final Logger _logger = Logger();
  
  final http.Client _httpClient = http.Client();
  final FirebaseAdminService _firebaseService = FirebaseAdminService();
  String? _authToken;

  /// Set authentication token for API calls
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Get headers for API requests
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  // ===== DASHBOARD OVERVIEW =====

  /// Get dashboard overview metrics from Firebase
  Future<Map<String, dynamic>> getDashboardMetrics() async {
    try {
      // Try Firebase first
      return await _firebaseService.getDashboardMetrics();
    } catch (e) {
      _logger.e('Error fetching dashboard metrics from Firebase: $e');
      // Fallback to mock data for development
      return _getMockDashboardMetrics();
    }
  }

  /// Get recent activity feed from Firebase
  Future<List<Map<String, dynamic>>> getRecentActivity() async {
    try {
      // Try Firebase first
      return await _firebaseService.getRecentActivity();
    } catch (e) {
      _logger.e('Error fetching recent activity from Firebase: $e');
      // Fallback to mock data for development
      return _getMockRecentActivity();
    }
  }

  /// Get fallacy statistics for pie chart from Firebase
  Future<List<Map<String, dynamic>>> getFallacyStats() async {
    try {
      // Try Firebase first
      return await _firebaseService.getFallacyStats();
    } catch (e) {
      _logger.e('Error fetching fallacy stats from Firebase: $e');
      // Fallback to mock data for development
      return _getMockFallacyStats();
    }
  }

  // ===== USER MANAGEMENT =====

  /// Get all users with pagination and filtering
  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 20,
    String? search,
    String? role,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      // Try Firebase first
      return await _firebaseService.getUsers(
        page: page,
        limit: limit,
        search: search,
        role: role,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
    } catch (e) {
      _logger.e('Error fetching users from Firebase: $e');
      // Fallback to mock data for development
      return _getMockUsersData();
    }
  }

  /// Get user details by ID from Firebase
  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    try {
      // Try Firebase first
      return await _firebaseService.getUserDetails(userId);
    } catch (e) {
      _logger.e('Error fetching user details from Firebase: $e');
      // Fallback to mock data for development
      return _getMockUserDetails(userId);
    }
  }

  /// Update user role in Firebase
  Future<bool> updateUserRole(String userId, String role) async {
    try {
      // Try Firebase first
      return await _firebaseService.updateUserRole(userId, role);
    } catch (e) {
      _logger.e('Error updating user role in Firebase: $e');
      return false;
    }
  }

  /// Suspend/unsuspend user in Firebase
  Future<bool> toggleUserStatus(String userId, bool isSuspended) async {
    try {
      // Try Firebase first
      return await _firebaseService.toggleUserStatus(userId, isSuspended);
    } catch (e) {
      _logger.e('Error toggling user status in Firebase: $e');
      return false;
    }
  }

  /// Export users to CSV
  Future<String> exportUsers() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/api/admin/users/export'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to export users: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error exporting users: $e');
      throw e;
    }
  }

  // ===== CONTENT MODERATION =====

  /// Get arguments queue for moderation
  Future<Map<String, dynamic>> getArgumentsQueue({
    int page = 1,
    int limit = 20,
    String? status,
    String? sortBy,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (sortBy != null) queryParams['sortBy'] = sortBy;

      final uri = Uri.parse('$_baseUrl/api/admin/arguments/queue').replace(
        queryParameters: queryParams,
      );

      final response = await _httpClient.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load arguments queue: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching arguments queue: $e');
      return _getMockArgumentsQueue();
    }
  }

  /// Moderate argument (approve/reject/flag)
  Future<bool> moderateArgument(String argumentId, String action, {String? reason}) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/api/admin/arguments/$argumentId/moderate'),
        headers: _headers,
        body: json.encode({
          'action': action,
          'reason': reason,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Error moderating argument: $e');
      return false;
    }
  }

  /// Upload dataset for model training
  Future<bool> uploadDataset(String filePath, String description) async {
    try {
      // This would typically use multipart/form-data for file upload
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/api/admin/datasets/upload'),
        headers: _headers,
        body: json.encode({
          'filePath': filePath,
          'description': description,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Error uploading dataset: $e');
      return false;
    }
  }

  // ===== ANALYTICS AND REPORTING =====

  /// Get analytics data with filters
  Future<Map<String, dynamic>> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? userGroup,
    String? metric,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      if (userGroup != null) queryParams['userGroup'] = userGroup;
      if (metric != null) queryParams['metric'] = metric;

      final uri = Uri.parse('$_baseUrl/api/admin/analytics').replace(
        queryParameters: queryParams,
      );

      final response = await _httpClient.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load analytics: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching analytics: $e');
      return _getMockAnalytics();
    }
  }

  /// Generate report (PDF/CSV)
  Future<String> generateReport(String reportType, Map<String, dynamic> parameters) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/api/admin/reports/generate'),
        headers: _headers,
        body: json.encode({
          'type': reportType,
          'parameters': parameters,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['downloadUrl'];
      } else {
        throw Exception('Failed to generate report: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error generating report: $e');
      throw e;
    }
  }

  // ===== SYSTEM AND MODEL MANAGEMENT =====

  /// Get system health status
  Future<Map<String, dynamic>> getSystemHealth() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/api/admin/system/health'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load system health: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching system health: $e');
      return _getMockSystemHealth();
    }
  }

  /// Get model performance metrics
  Future<Map<String, dynamic>> getModelMetrics() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/api/admin/models/metrics'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load model metrics: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching model metrics: $e');
      return _getMockModelMetrics();
    }
  }

  /// Toggle feature flag
  Future<bool> toggleFeature(String featureName, bool enabled) async {
    try {
      final response = await _httpClient.put(
        Uri.parse('$_baseUrl/api/admin/features/$featureName'),
        headers: _headers,
        body: json.encode({'enabled': enabled}),
      );

      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Error toggling feature: $e');
      return false;
    }
  }

  /// Deploy model update
  Future<bool> deployModelUpdate(String modelVersion) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/api/admin/models/deploy'),
        headers: _headers,
        body: json.encode({'version': modelVersion}),
      );

      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Error deploying model update: $e');
      return false;
    }
  }

  // ===== MOCK DATA FOR DEVELOPMENT =====

  Map<String, dynamic> _getMockDashboardMetrics() {
    return {
      'totalUsers': 1234,
      'activeUsers': 567,
      'totalArguments': 3456,
      'pendingModeration': 23,
      'totalFallacies': 1234,
      'avgFallaciesPerArgument': 2.3,
      'systemUptime': '99.9%',
      'modelAccuracy': 94.2,
    };
  }

  List<Map<String, dynamic>> _getMockRecentActivity() {
    return [
      {
        'id': '1',
        'type': 'argument_submitted',
        'user': 'john.doe@example.com',
        'description': 'Submitted new argument about climate change',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
        'status': 'pending',
      },
      {
        'id': '2',
        'type': 'fallacy_detected',
        'user': 'jane.smith@example.com',
        'description': 'Detected strawman fallacy in argument',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 12)),
        'status': 'processed',
      },
      {
        'id': '3',
        'type': 'user_registered',
        'user': 'new.user@example.com',
        'description': 'New user registered',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 25)),
        'status': 'completed',
      },
      {
        'id': '4',
        'type': 'model_update',
        'user': 'system',
        'description': 'NLP model updated to version 2.1',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'status': 'completed',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockFallacyStats() {
    return [
      {'type': 'Strawman', 'count': 234, 'percentage': 28.5, 'color': 0xFFE57373},
      {'type': 'Ad Hominem', 'count': 189, 'percentage': 23.0, 'color': 0xFF64B5F6},
      {'type': 'False Dilemma', 'count': 156, 'percentage': 19.0, 'color': 0xFF81C784},
      {'type': 'Appeal to Authority', 'count': 123, 'percentage': 15.0, 'color': 0xFFFFB74D},
      {'type': 'Slippery Slope', 'count': 87, 'percentage': 10.6, 'color': 0xFFBA68C8},
      {'type': 'Other', 'count': 31, 'percentage': 3.8, 'color': 0xFF90A4AE},
    ];
  }

  Map<String, dynamic> _getMockUsersData() {
    return {
      'users': [
        {
          'uid': 'user1',
          'email': 'john.doe@example.com',
          'role': 'debater',
          'isEmailVerified': true,
          'createdAt': DateTime.now().subtract(const Duration(days: 30)),
          'lastActive': DateTime.now().subtract(const Duration(hours: 2)),
          'argumentsSubmitted': 15,
          'fallaciesDetected': 8,
          'isSuspended': false,
        },
        {
          'uid': 'user2',
          'email': 'jane.smith@example.com',
          'role': 'debater',
          'isEmailVerified': true,
          'createdAt': DateTime.now().subtract(const Duration(days: 15)),
          'lastActive': DateTime.now().subtract(const Duration(minutes: 30)),
          'argumentsSubmitted': 8,
          'fallaciesDetected': 3,
          'isSuspended': false,
        },
        {
          'uid': 'user3',
          'email': 'admin@debatemate.com',
          'role': 'admin',
          'isEmailVerified': true,
          'createdAt': DateTime.now().subtract(const Duration(days: 60)),
          'lastActive': DateTime.now().subtract(const Duration(minutes: 5)),
          'argumentsSubmitted': 0,
          'fallaciesDetected': 0,
          'isSuspended': false,
        },
      ],
      'pagination': {
        'currentPage': 1,
        'totalPages': 1,
        'totalItems': 3,
        'itemsPerPage': 20,
      },
    };
  }

  Map<String, dynamic> _getMockUserDetails(String userId) {
    return {
      'uid': userId,
      'email': 'user@example.com',
      'role': 'debater',
      'isEmailVerified': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
      'lastActive': DateTime.now().subtract(const Duration(hours: 2)),
      'argumentsSubmitted': 15,
      'fallaciesDetected': 8,
      'isSuspended': false,
      'progress': {
        'fallacyReduction': 25.5,
        'argumentQuality': 78.2,
        'engagement': 92.1,
      },
      'recentArguments': [
        {
          'id': 'arg1',
          'topic': 'Climate Change',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'fallacies': ['Strawman', 'False Dilemma'],
        },
        {
          'id': 'arg2',
          'topic': 'Education Reform',
          'timestamp': DateTime.now().subtract(const Duration(days: 3)),
          'fallacies': ['Ad Hominem'],
        },
      ],
    };
  }

  Map<String, dynamic> _getMockArgumentsQueue() {
    return {
      'arguments': [
        {
          'id': 'arg1',
          'user': 'john.doe@example.com',
          'topic': 'Climate Change Policy',
          'content': 'The proposed climate policy is fundamentally flawed...',
          'transcript': 'The proposed climate policy is fundamentally flawed and will destroy our economy.',
          'detectedFallacies': ['Strawman', 'Slippery Slope'],
          'aiCounterarguments': ['While economic concerns are valid, the long-term costs of inaction...'],
          'status': 'pending',
          'submittedAt': DateTime.now().subtract(const Duration(hours: 2)),
          'confidence': 0.87,
        },
        {
          'id': 'arg2',
          'user': 'jane.smith@example.com',
          'topic': 'Healthcare Reform',
          'content': 'Universal healthcare is a socialist nightmare...',
          'transcript': 'Universal healthcare is a socialist nightmare that will bankrupt our nation.',
          'detectedFallacies': ['False Dilemma', 'Appeal to Emotion'],
          'aiCounterarguments': ['Many developed nations successfully implement universal healthcare...'],
          'status': 'flagged',
          'submittedAt': DateTime.now().subtract(const Duration(hours: 5)),
          'confidence': 0.92,
        },
      ],
      'pagination': {
        'currentPage': 1,
        'totalPages': 1,
        'totalItems': 2,
        'itemsPerPage': 20,
      },
    };
  }

  Map<String, dynamic> _getMockAnalytics() {
    return {
      'userProgress': [
        {'month': 'Jan', 'improvement': 12.5},
        {'month': 'Feb', 'improvement': 18.3},
        {'month': 'Mar', 'improvement': 22.1},
        {'month': 'Apr', 'improvement': 25.8},
        {'month': 'May', 'improvement': 28.4},
        {'month': 'Jun', 'improvement': 31.2},
      ],
      'engagementByTopic': [
        {'topic': 'Climate Change', 'arguments': 234, 'engagement': 87.5},
        {'topic': 'Healthcare', 'arguments': 189, 'engagement': 82.3},
        {'topic': 'Education', 'arguments': 156, 'engagement': 79.8},
        {'topic': 'Technology', 'arguments': 123, 'engagement': 85.2},
      ],
      'biasStats': {
        'accentBias': 2.3,
        'genderBias': 1.8,
        'culturalBias': 3.1,
        'overallBias': 2.4,
      },
      'predictions': [
        'Forecast: 20% skill improvement in 1 month',
        'Recommendation: Review fallacy types 3-7 for beginners',
        'Alert: High bias detected in topic "Politics"',
      ],
    };
  }

  Map<String, dynamic> _getMockSystemHealth() {
    return {
      'serverStatus': 'operational',
      'databaseStatus': 'healthy',
      'authStatus': 'active',
      'aiServicesStatus': 'ready',
      'uptime': '99.9%',
      'responseTime': '145ms',
      'cpuUsage': 34.5,
      'memoryUsage': 67.2,
      'diskUsage': 45.8,
    };
  }

  Map<String, dynamic> _getMockModelMetrics() {
    return {
      'roberta': {
        'accuracy': 94.2,
        'precision': 92.8,
        'recall': 95.1,
        'f1Score': 93.9,
        'latency': '45ms',
        'errorRate': 0.8,
      },
      'gpt35': {
        'accuracy': 91.7,
        'precision': 89.4,
        'recall': 93.2,
        'f1Score': 91.3,
        'latency': '120ms',
        'errorRate': 1.2,
      },
      'biasStats': {
        'accentBias': 2.3,
        'genderBias': 1.8,
        'culturalBias': 3.1,
        'overallBias': 2.4,
      },
      'lastUpdate': DateTime.now().subtract(const Duration(hours: 6)),
    };
  }

  /// Dispose resources
  void dispose() {
    _httpClient.close();
  }
}

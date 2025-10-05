import 'package:flutter_test/flutter_test.dart';
import 'package:debate_mate/core/services/admin_service.dart';

void main() {
  group('AdminService Tests', () {
    late AdminService adminService;

    setUp(() {
      adminService = AdminService();
    });

    tearDown(() {
      adminService.dispose();
    });

    test('should initialize successfully', () {
      // Assert
      expect(adminService, isNotNull);
    });

    test('should set auth token without errors', () {
      // Arrange
      const testToken = 'test-auth-token';

      // Act & Assert
      expect(() => adminService.setAuthToken(testToken), returnsNormally);
    });

    test('should return mock dashboard metrics on error', () async {
      // Act
      final result = await adminService.getDashboardMetrics();

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('totalUsers'), isTrue);
      expect(result.containsKey('activeUsers'), isTrue);
      expect(result.containsKey('totalArguments'), isTrue);
      expect(result.containsKey('modelAccuracy'), isTrue);
    });

    test('should return mock fallacy stats on error', () async {
      // Act
      final result = await adminService.getFallacyStats();

      // Assert
      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.isNotEmpty, isTrue);
      
      final firstItem = result.first;
      expect(firstItem.containsKey('type'), isTrue);
      expect(firstItem.containsKey('count'), isTrue);
      expect(firstItem.containsKey('percentage'), isTrue);
      expect(firstItem.containsKey('color'), isTrue);
    });

    test('should return mock users data on error', () async {
      // Act
      final result = await adminService.getUsers();

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('users'), isTrue);
      expect(result.containsKey('pagination'), isTrue);
      
      final users = result['users'] as List;
      expect(users, isNotEmpty);
    });

    test('should return mock analytics data on error', () async {
      // Act
      final result = await adminService.getAnalytics();

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('userProgress'), isTrue);
      expect(result.containsKey('engagementByTopic'), isTrue);
      expect(result.containsKey('biasStats'), isTrue);
      expect(result.containsKey('predictions'), isTrue);
    });

    test('should return mock system health data on error', () async {
      // Act
      final result = await adminService.getSystemHealth();

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('serverStatus'), isTrue);
      expect(result.containsKey('databaseStatus'), isTrue);
      expect(result.containsKey('authStatus'), isTrue);
      expect(result.containsKey('aiServicesStatus'), isTrue);
      expect(result.containsKey('uptime'), isTrue);
    });

    test('should return mock model metrics data on error', () async {
      // Act
      final result = await adminService.getModelMetrics();

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('roberta'), isTrue);
      expect(result.containsKey('gpt35'), isTrue);
      expect(result.containsKey('biasStats'), isTrue);
      expect(result.containsKey('lastUpdate'), isTrue);
    });
  });
}

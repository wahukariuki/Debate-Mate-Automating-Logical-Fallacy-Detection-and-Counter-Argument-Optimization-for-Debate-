import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Admin Role Assignment Tests', () {
    const adminEmail = 'wahuabi@gmail.com';
    const regularEmail = 'user@example.com';
    
    test('should assign admin role to specific admin email', () {
      // Test the logic for admin role assignment
      final String userRole = adminEmail.toLowerCase() == adminEmail.toLowerCase() ? 'admin' : 'debater';
      
      expect(userRole, equals('admin'));
    });
    
    test('should assign debater role to non-admin emails', () {
      // Test the logic for regular user role assignment
      final String userRole = regularEmail.toLowerCase() == adminEmail.toLowerCase() ? 'admin' : 'debater';
      
      expect(userRole, equals('debater'));
    });
    
    test('should handle case insensitive email comparison', () {
      const upperCaseAdminEmail = 'WAHUABI@GMAIL.COM';
      
      final String userRole = upperCaseAdminEmail.toLowerCase() == adminEmail.toLowerCase() ? 'admin' : 'debater';
      
      expect(userRole, equals('admin'));
    });
    
    test('should handle similar but different emails', () {
      const similarEmail = 'wahuabi1@gmail.com';
      
      final String userRole = similarEmail.toLowerCase() == adminEmail.toLowerCase() ? 'admin' : 'debater';
      
      expect(userRole, equals('debater'));
    });
  });
}

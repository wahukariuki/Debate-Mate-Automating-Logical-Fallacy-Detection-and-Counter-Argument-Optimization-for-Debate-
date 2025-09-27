import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../services/admin_service.dart';

/// Admin service provider
final adminServiceProvider = Provider<AdminService>((ref) {
  final service = AdminService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Dashboard metrics state
class DashboardMetrics {
  final Map<String, dynamic> metrics;
  final bool isLoading;
  final String? error;

  const DashboardMetrics({
    required this.metrics,
    required this.isLoading,
    this.error,
  });

  DashboardMetrics copyWith({
    Map<String, dynamic>? metrics,
    bool? isLoading,
    String? error,
  }) {
    return DashboardMetrics(
      metrics: metrics ?? this.metrics,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Dashboard metrics notifier
class DashboardMetricsNotifier extends StateNotifier<DashboardMetrics> {
  final AdminService _adminService;
  final Logger _logger = Logger();

  DashboardMetricsNotifier(this._adminService) : super(const DashboardMetrics(
    metrics: {},
    isLoading: true,
  )) {
    loadMetrics();
  }

  Future<void> loadMetrics() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final metrics = await _adminService.getDashboardMetrics();
      state = state.copyWith(
        metrics: metrics,
        isLoading: false,
      );
    } catch (e) {
      _logger.e('Error loading dashboard metrics: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadMetrics();
  }
}

/// Dashboard metrics provider
final dashboardMetricsProvider = StateNotifierProvider<DashboardMetricsNotifier, DashboardMetrics>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return DashboardMetricsNotifier(adminService);
});

/// Recent activity state
class RecentActivity {
  final List<Map<String, dynamic>> activities;
  final bool isLoading;
  final String? error;

  const RecentActivity({
    required this.activities,
    required this.isLoading,
    this.error,
  });

  RecentActivity copyWith({
    List<Map<String, dynamic>>? activities,
    bool? isLoading,
    String? error,
  }) {
    return RecentActivity(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Recent activity notifier
class RecentActivityNotifier extends StateNotifier<RecentActivity> {
  final AdminService _adminService;
  final Logger _logger = Logger();

  RecentActivityNotifier(this._adminService) : super(const RecentActivity(
    activities: [],
    isLoading: true,
  )) {
    loadActivity();
  }

  Future<void> loadActivity() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final activities = await _adminService.getRecentActivity();
      state = state.copyWith(
        activities: activities,
        isLoading: false,
      );
    } catch (e) {
      _logger.e('Error loading recent activity: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadActivity();
  }
}

/// Recent activity provider
final recentActivityProvider = StateNotifierProvider<RecentActivityNotifier, RecentActivity>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return RecentActivityNotifier(adminService);
});

/// Fallacy statistics state
class FallacyStats {
  final List<Map<String, dynamic>> stats;
  final bool isLoading;
  final String? error;

  const FallacyStats({
    required this.stats,
    required this.isLoading,
    this.error,
  });

  FallacyStats copyWith({
    List<Map<String, dynamic>>? stats,
    bool? isLoading,
    String? error,
  }) {
    return FallacyStats(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Fallacy statistics notifier
class FallacyStatsNotifier extends StateNotifier<FallacyStats> {
  final AdminService _adminService;
  final Logger _logger = Logger();

  FallacyStatsNotifier(this._adminService) : super(const FallacyStats(
    stats: [],
    isLoading: true,
  )) {
    loadStats();
  }

  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final stats = await _adminService.getFallacyStats();
      state = state.copyWith(
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      _logger.e('Error loading fallacy stats: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadStats();
  }
}

/// Fallacy statistics provider
final fallacyStatsProvider = StateNotifierProvider<FallacyStatsNotifier, FallacyStats>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return FallacyStatsNotifier(adminService);
});

/// User management state
class UserManagementState {
  final List<Map<String, dynamic>> users;
  final Map<String, dynamic> pagination;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String selectedRole;
  final String sortBy;
  final String sortOrder;

  const UserManagementState({
    required this.users,
    required this.pagination,
    required this.isLoading,
    this.error,
    required this.searchQuery,
    required this.selectedRole,
    required this.sortBy,
    required this.sortOrder,
  });

  UserManagementState copyWith({
    List<Map<String, dynamic>>? users,
    Map<String, dynamic>? pagination,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? selectedRole,
    String? sortBy,
    String? sortOrder,
  }) {
    return UserManagementState(
      users: users ?? this.users,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedRole: selectedRole ?? this.selectedRole,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

/// User management notifier
class UserManagementNotifier extends StateNotifier<UserManagementState> {
  final AdminService _adminService;
  final Logger _logger = Logger();

  UserManagementNotifier(this._adminService) : super(const UserManagementState(
    users: [],
    pagination: {},
    isLoading: true,
    searchQuery: '',
    selectedRole: 'all',
    sortBy: 'createdAt',
    sortOrder: 'desc',
  )) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final data = await _adminService.getUsers(
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        role: state.selectedRole != 'all' ? state.selectedRole : null,
        sortBy: state.sortBy,
        sortOrder: state.sortOrder,
      );
      
      state = state.copyWith(
        users: List<Map<String, dynamic>>.from(data['users']),
        pagination: data['pagination'],
        isLoading: false,
      );
    } catch (e) {
      _logger.e('Error loading users: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadUsers();
  }

  void updateRoleFilter(String role) {
    state = state.copyWith(selectedRole: role);
    loadUsers();
  }

  void updateSorting(String sortBy, String sortOrder) {
    state = state.copyWith(sortBy: sortBy, sortOrder: sortOrder);
    loadUsers();
  }

  Future<bool> updateUserRole(String userId, String role) async {
    try {
      final success = await _adminService.updateUserRole(userId, role);
      if (success) {
        await loadUsers(); // Refresh the list
      }
      return success;
    } catch (e) {
      _logger.e('Error updating user role: $e');
      return false;
    }
  }

  Future<bool> toggleUserStatus(String userId, bool isSuspended) async {
    try {
      final success = await _adminService.toggleUserStatus(userId, isSuspended);
      if (success) {
        await loadUsers(); // Refresh the list
      }
      return success;
    } catch (e) {
      _logger.e('Error toggling user status: $e');
      return false;
    }
  }

  Future<void> refresh() async {
    await loadUsers();
  }
}

/// User management provider
final userManagementProvider = StateNotifierProvider<UserManagementNotifier, UserManagementState>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return UserManagementNotifier(adminService);
});

/// Content moderation state
class ContentModerationState {
  final List<Map<String, dynamic>> arguments;
  final Map<String, dynamic> pagination;
  final bool isLoading;
  final String? error;
  final String statusFilter;
  final String sortBy;

  const ContentModerationState({
    required this.arguments,
    required this.pagination,
    required this.isLoading,
    this.error,
    required this.statusFilter,
    required this.sortBy,
  });

  ContentModerationState copyWith({
    List<Map<String, dynamic>>? arguments,
    Map<String, dynamic>? pagination,
    bool? isLoading,
    String? error,
    String? statusFilter,
    String? sortBy,
  }) {
    return ContentModerationState(
      arguments: arguments ?? this.arguments,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      statusFilter: statusFilter ?? this.statusFilter,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

/// Content moderation notifier
class ContentModerationNotifier extends StateNotifier<ContentModerationState> {
  final AdminService _adminService;
  final Logger _logger = Logger();

  ContentModerationNotifier(this._adminService) : super(const ContentModerationState(
    arguments: [],
    pagination: {},
    isLoading: true,
    statusFilter: 'all',
    sortBy: 'submittedAt',
  )) {
    loadArguments();
  }

  Future<void> loadArguments() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final data = await _adminService.getArgumentsQueue(
        status: state.statusFilter != 'all' ? state.statusFilter : null,
        sortBy: state.sortBy,
      );
      
      state = state.copyWith(
        arguments: List<Map<String, dynamic>>.from(data['arguments']),
        pagination: data['pagination'],
        isLoading: false,
      );
    } catch (e) {
      _logger.e('Error loading arguments: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void updateStatusFilter(String status) {
    state = state.copyWith(statusFilter: status);
    loadArguments();
  }

  void updateSorting(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
    loadArguments();
  }

  Future<bool> moderateArgument(String argumentId, String action, {String? reason}) async {
    try {
      final success = await _adminService.moderateArgument(argumentId, action, reason: reason);
      if (success) {
        await loadArguments(); // Refresh the list
      }
      return success;
    } catch (e) {
      _logger.e('Error moderating argument: $e');
      return false;
    }
  }

  Future<void> refresh() async {
    await loadArguments();
  }
}

/// Content moderation provider
final contentModerationProvider = StateNotifierProvider<ContentModerationNotifier, ContentModerationState>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return ContentModerationNotifier(adminService);
});

/// Analytics state
class AnalyticsState {
  final Map<String, dynamic> analytics;
  final bool isLoading;
  final String? error;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? userGroup;
  final String? metric;

  const AnalyticsState({
    required this.analytics,
    required this.isLoading,
    this.error,
    this.startDate,
    this.endDate,
    this.userGroup,
    this.metric,
  });

  AnalyticsState copyWith({
    Map<String, dynamic>? analytics,
    bool? isLoading,
    String? error,
    DateTime? startDate,
    DateTime? endDate,
    String? userGroup,
    String? metric,
  }) {
    return AnalyticsState(
      analytics: analytics ?? this.analytics,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      userGroup: userGroup ?? this.userGroup,
      metric: metric ?? this.metric,
    );
  }
}

/// Analytics notifier
class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final AdminService _adminService;
  final Logger _logger = Logger();

  AnalyticsNotifier(this._adminService) : super(const AnalyticsState(
    analytics: {},
    isLoading: true,
  )) {
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final analytics = await _adminService.getAnalytics(
        startDate: state.startDate,
        endDate: state.endDate,
        userGroup: state.userGroup,
        metric: state.metric,
      );
      
      state = state.copyWith(
        analytics: analytics,
        isLoading: false,
      );
    } catch (e) {
      _logger.e('Error loading analytics: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void updateFilters({
    DateTime? startDate,
    DateTime? endDate,
    String? userGroup,
    String? metric,
  }) {
    state = state.copyWith(
      startDate: startDate,
      endDate: endDate,
      userGroup: userGroup,
      metric: metric,
    );
    loadAnalytics();
  }

  Future<void> refresh() async {
    await loadAnalytics();
  }
}

/// Analytics provider
final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return AnalyticsNotifier(adminService);
});

/// System health state
class SystemHealthState {
  final Map<String, dynamic> health;
  final bool isLoading;
  final String? error;

  const SystemHealthState({
    required this.health,
    required this.isLoading,
    this.error,
  });

  SystemHealthState copyWith({
    Map<String, dynamic>? health,
    bool? isLoading,
    String? error,
  }) {
    return SystemHealthState(
      health: health ?? this.health,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// System health notifier
class SystemHealthNotifier extends StateNotifier<SystemHealthState> {
  final AdminService _adminService;
  final Logger _logger = Logger();

  SystemHealthNotifier(this._adminService) : super(const SystemHealthState(
    health: {},
    isLoading: true,
  )) {
    loadSystemHealth();
  }

  Future<void> loadSystemHealth() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final health = await _adminService.getSystemHealth();
      state = state.copyWith(
        health: health,
        isLoading: false,
      );
    } catch (e) {
      _logger.e('Error loading system health: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadSystemHealth();
  }
}

/// System health provider
final systemHealthProvider = StateNotifierProvider<SystemHealthNotifier, SystemHealthState>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return SystemHealthNotifier(adminService);
});

/// Model metrics state
class ModelMetricsState {
  final Map<String, dynamic> metrics;
  final bool isLoading;
  final String? error;

  const ModelMetricsState({
    required this.metrics,
    required this.isLoading,
    this.error,
  });

  ModelMetricsState copyWith({
    Map<String, dynamic>? metrics,
    bool? isLoading,
    String? error,
  }) {
    return ModelMetricsState(
      metrics: metrics ?? this.metrics,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Model metrics notifier
class ModelMetricsNotifier extends StateNotifier<ModelMetricsState> {
  final AdminService _adminService;
  final Logger _logger = Logger();

  ModelMetricsNotifier(this._adminService) : super(const ModelMetricsState(
    metrics: {},
    isLoading: true,
  )) {
    loadModelMetrics();
  }

  Future<void> loadModelMetrics() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final metrics = await _adminService.getModelMetrics();
      state = state.copyWith(
        metrics: metrics,
        isLoading: false,
      );
    } catch (e) {
      _logger.e('Error loading model metrics: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadModelMetrics();
  }
}

/// Model metrics provider
final modelMetricsProvider = StateNotifierProvider<ModelMetricsNotifier, ModelMetricsState>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return ModelMetricsNotifier(adminService);
});

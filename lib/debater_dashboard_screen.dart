import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/debate_provider.dart';
import '../widgets/debate_message_bubble.dart';
import '../widgets/debate_input_widget.dart';
import '../widgets/debate_sidebar.dart';
import '../widgets/typing_indicator.dart';

/// Debater dashboard with chat-like interface for debate practice
class DebaterDashboardScreen extends ConsumerStatefulWidget {
  const DebaterDashboardScreen({super.key});

  @override
  ConsumerState<DebaterDashboardScreen> createState() => _DebaterDashboardScreenState();
}

class _DebaterDashboardScreenState extends ConsumerState<DebaterDashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final debateState = ref.watch(debateProvider);
    final isDesktop = AppTheme.isDesktop(context);
    final isTablet = AppTheme.isTablet(context);

    // Auto-scroll to bottom when new messages arrive or AI starts/stops typing
    ref.listen<DebateState>(debateProvider, (previous, next) {
      if (next.messages.length != previous?.messages.length ||
          next.isAiTyping != previous?.isAiTyping) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey[200],
            height: 1,
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/debate_mate_logo.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.forum_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            const Flexible(
              child: Text(
                'Debater Dashboard',
                style: TextStyle(color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // History Button (Mobile only - sidebar shows on desktop/tablet)
          if (!isDesktop && !isTablet)
            IconButton(
              onPressed: () => _showHistoryDrawer(context, ref),
              icon: const Icon(Icons.history),
              tooltip: 'Debate History',
            ),
          // New Debate Button
          IconButton(
            onPressed: () => _showNewDebateDialog(context, ref),
            icon: const Icon(Icons.add),
            tooltip: 'New Debate',
          ),
          // User Profile
          PopupMenuButton<String>(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.black,
              child: Text(
                authState.user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            iconColor: Colors.black,
            color: Colors.white,
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  context.push('/profile');
                  break;
                case 'settings':
                  context.push('/settings');
                  break;
                case 'logout':
                  ref.read(authProvider.notifier).signOut();
                  context.go('/sign-in');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: Colors.black),
                    SizedBox(width: 12),
                    Text('Profile', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, color: Colors.black),
                    SizedBox(width: 12),
                    Text('Settings', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.black),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Sidebar (Desktop/Tablet only)
          if (isDesktop || isTablet)
            SizedBox(
              width: isDesktop ? 300 : 250,
              child: const DebateSidebar(),
            ),
          
          // Main Chat Area
          Expanded(
            child: Column(
              children: [
                // Welcome Message (if no messages)
                if (debateState.messages.isEmpty)
                  Expanded(
                    child: _buildWelcomeSection(context),
                  )
                else
                  // Messages List
                  Expanded(
                    child: _buildMessagesList(context, debateState),
                  ),
                
                // Input Area
                DebateInputWidget(
                  onSendMessage: (message) => _handleSendMessage(context, ref, message),
                  onSendAudio: () {}, // Handled internally by the widget
                  isDisabled: debateState.isAiTyping, // Disable while AI is responding
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcome Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Icon(
                Icons.forum_outlined,
                size: 60,
                color: Colors.black,
              ),
            )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
            
            const SizedBox(height: 32),
            
            // Welcome Text
            const Text(
              'Welcome to Debate Practice!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 16),
            
            Text(
              'Start a new debate session to practice your argumentation skills with AI-powered feedback.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 32),
            
            // Start Debate Button
            ElevatedButton.icon(
              onPressed: () => _showNewDebateDialog(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Start New Debate'),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 600.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context, DebateState debateState) {
    // Calculate item count: messages + typing indicator if AI is typing
    final itemCount = debateState.messages.length + (debateState.isAiTyping ? 1 : 0);
    
    return Container(
      color: Colors.grey[50],
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // Show typing indicator at the end if AI is typing
          if (index == debateState.messages.length && debateState.isAiTyping) {
            return const TypingIndicator();
          }
          
          // Show regular message
          final message = debateState.messages[index];
          return DebateMessageBubble(
            message: message,
            isUser: message.isUser,
          )
              .animate(delay: Duration(milliseconds: index * 100))
              .fadeIn(duration: 400.ms)
              .slideX(begin: message.isUser ? 0.2 : -0.2, end: 0);
        },
      ),
    );
  }

  void _handleSendMessage(BuildContext context, WidgetRef ref, String message) {
    if (message.trim().isEmpty) return;
    
    final debateNotifier = ref.read(debateProvider.notifier);
    debateNotifier.sendMessage(message.trim());
  }

  void _showHistoryDrawer(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.history, color: Colors.black),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Debate History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Sidebar content (without header since we have one in the bottom sheet)
            const Flexible(
              child: DebateSidebar(showHeader: false),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewDebateDialog(BuildContext context, WidgetRef ref) {
    String? selectedTopic;
    final topics = [
      'Social Media',
      'Climate',
      'Education',
      'Technology',
      'Politics and Governance',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Start New Debate', style: TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedTopic,
                decoration: const InputDecoration(
                  labelText: 'Debate Topic',
                  labelStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.topic, color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                items: topics.map((topic) {
                  return DropdownMenuItem<String>(
                    value: topic,
                    child: Text(topic, style: const TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTopic = value;
                  });
                },
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedTopic != null && selectedTopic!.isNotEmpty) {
                  final debateNotifier = ref.read(debateProvider.notifier);
                  debateNotifier.startNewDebate(
                    topic: selectedTopic!,
                    context: null,
                  );
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Start Debate'),
            ),
          ],
        ),
      ),
    );
  }
}

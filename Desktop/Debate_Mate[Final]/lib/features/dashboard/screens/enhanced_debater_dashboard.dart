import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../../core/providers/auth_provider.dart';
import '../../../core/services/enhanced_api_service.dart';
import '../../../core/models/counterargument_model.dart';
import '../../../core/models/fallacy_report_model.dart';
import '../../../core/theme/app_theme.dart';
import '../models/dashboard_models.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/progress_sidebar.dart';
import '../widgets/voice_input_button.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/settings_panel.dart';
import '../widgets/export_session_dialog.dart';

/// Enhanced debater dashboard with chat-like interface for real-time debate practice
class EnhancedDebaterDashboard extends ConsumerStatefulWidget {
  const EnhancedDebaterDashboard({super.key});

  @override
  ConsumerState<EnhancedDebaterDashboard> createState() => _EnhancedDebaterDashboardState();
}

class _EnhancedDebaterDashboardState extends ConsumerState<EnhancedDebaterDashboard> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechToText _speechToText = SpeechToText();
  final EnhancedApiService _apiService = EnhancedApiService();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isListening = false;
  bool _isTyping = false;
  bool _speechEnabled = false;
  bool _showProgress = false;
  bool _showSettings = false;
  
  // Progress tracking
  List<ProgressData> _progressData = [];
  int _totalSessions = 0;
  int _totalFallaciesDetected = 0;
  double _averageScore = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _loadConversationHistory();
    _loadProgressData();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  Future<void> _loadConversationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getStringList('conversation_history') ?? [];
    
    setState(() {
      _messages = messagesJson
          .map((json) => ChatMessage.fromJson(json))
          .toList();
    });
    
    if (_messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  Future<void> _saveConversationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = _messages.map((msg) => msg.toJson()).toList();
    await prefs.setStringList('conversation_history', messagesJson);
  }

  Future<void> _loadProgressData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalSessions = prefs.getInt('total_sessions') ?? 0;
      _totalFallaciesDetected = prefs.getInt('total_fallacies') ?? 0;
      _averageScore = prefs.getDouble('average_score') ?? 0.0;
    });
  }

  Future<void> _saveProgressData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_sessions', _totalSessions);
    await prefs.setInt('total_fallacies', _totalFallaciesDetected);
    await prefs.setDouble('average_score', _averageScore);
  }

  void _addWelcomeMessage() {
    if (_messages.isEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: "Welcome to Debate Mate! I'm your AI debate coach. Share your argument and I'll help you identify logical fallacies and suggest counter-arguments. You can type or use voice input.",
          isUser: false,
          timestamp: DateTime.now(),
          messageType: ChatMessageType.welcome,
        ));
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleTextSubmit() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    await _processUserInput(text);
  }

  Future<void> _processUserInput(String input) async {
    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: input,
      isUser: true,
      timestamp: DateTime.now(),
      messageType: ChatMessageType.userInput,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final userData = ref.read(currentUserDataProvider);
      if (userData == null) {
        throw Exception('User not authenticated');
      }

      // Show typing indicator
      setState(() {
        _isTyping = true;
      });

      // Submit argument and get analysis
      final analysisResult = await _apiService.submitArgumentWithAnalysis(
        userId: userData.uid,
        content: input,
        type: 'neutral', // Default type for dashboard practice
        topic: null,
        metadata: {
          'wordCount': input.split(' ').length,
          'characterCount': input.length,
          'source': 'dashboard',
        },
      );

      final fallacyReport = analysisResult['fallacyReport'];
      final counterarguments = analysisResult['counterarguments'];

      // Update progress data
      _updateProgressData(fallacyReport, counterarguments);

      // Create AI response
      final aiResponse = _createAIResponse(fallacyReport, counterarguments);

      setState(() {
        _messages.add(aiResponse);
        _isLoading = false;
        _isTyping = false;
      });

      _scrollToBottom();
      await _saveConversationHistory();
      await _saveProgressData();

    } catch (e) {
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: "I apologize, but I encountered an error processing your argument. Please try again or check your internet connection.",
        isUser: false,
        timestamp: DateTime.now(),
        messageType: ChatMessageType.error,
      );

      setState(() {
        _messages.add(errorMessage);
        _isLoading = false;
        _isTyping = false;
      });

      _scrollToBottom();
    }
  }

  void _updateProgressData(FallacyReportModel fallacyReport, CounterargumentModel counterarguments) {
    setState(() {
      _totalSessions++;
      _totalFallaciesDetected += fallacyReport.fallacyCount;
      
      // Update average score
      final currentTotal = _averageScore * (_totalSessions - 1);
      _averageScore = (currentTotal + fallacyReport.score) / _totalSessions;
      
      // Add progress data point
      _progressData.add(ProgressData(
        date: DateTime.now(),
        score: fallacyReport.score,
        fallaciesDetected: fallacyReport.fallacyCount,
        optimizationsGenerated: counterarguments.optimizationCount,
      ));
    });
  }

  ChatMessage _createAIResponse(FallacyReportModel fallacyReport, CounterargumentModel counterarguments) {
    final buffer = StringBuffer();
    
    // Add fallacy analysis
    if (fallacyReport.hasFallacies) {
      buffer.writeln("🔍 **Detected Fallacies:**");
      for (int i = 0; i < fallacyReport.fallacies.length; i++) {
        final fallacy = fallacyReport.fallacies[i];
        buffer.writeln("${i + 1}. **${fallacy.type.replaceAll('_', ' ').toUpperCase()}**");
        buffer.writeln("   ${fallacy.description}");
        if (fallacy.suggestion != null) {
          buffer.writeln("   💡 *Suggestion: ${fallacy.suggestion}*");
        }
        buffer.writeln();
      }
    } else {
      buffer.writeln("✅ **No logical fallacies detected!** Your argument appears to be logically sound.");
      buffer.writeln();
    }

    // Add counterarguments
    buffer.writeln("💡 **Optimized Counter-Arguments:**");
    buffer.writeln(counterarguments.content);
    buffer.writeln();
    
    if (counterarguments.hasOptimizations) {
      buffer.writeln("**Improvement Suggestions:**");
      for (int i = 0; i < counterarguments.optimizations.length; i++) {
        final opt = counterarguments.optimizations[i];
        buffer.writeln("${i + 1}. **${opt.description}**");
        buffer.writeln("   ${opt.suggestion}");
        buffer.writeln();
      }
    }

    // Add score summary
    buffer.writeln("📊 **Analysis Summary:**");
    buffer.writeln("• Argument Score: ${(fallacyReport.score * 100).round()}%");
    buffer.writeln("• Fallacies Detected: ${fallacyReport.fallacyCount}");
    buffer.writeln("• Optimizations Suggested: ${counterarguments.optimizationCount}");

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: buffer.toString(),
      isUser: false,
      timestamp: DateTime.now(),
      messageType: ChatMessageType.aiResponse,
      fallacyReport: fallacyReport,
      counterarguments: counterarguments,
    );
  }

  Future<void> _startVoiceInput() async {
    if (!_speechEnabled) return;

    setState(() {
      _isListening = true;
    });

    await _speechToText.listen(
      onResult: (result) {
        // Don't update UI during listening to avoid flickering
      },
    );
  }

  Future<void> _stopVoiceInput() async {
    await _speechToText.stop();
    
    setState(() {
      _isListening = false;
    });

    if (_speechToText.lastRecognizedWords.isNotEmpty) {
      _textController.text = _speechToText.lastRecognizedWords;
      await _processUserInput(_speechToText.lastRecognizedWords);
    }
  }

  Future<void> _exportSession() async {
    showDialog(
      context: context,
      builder: (context) => ExportSessionDialog(
        messages: _messages,
        progressData: _progressData,
        onExport: _performExport,
      ),
    );
  }

  Future<void> _performExport(ExportFormat format) async {
    try {
      String? filePath;

      if (format == ExportFormat.pdf) {
        filePath = await _exportToPDF();
      } else {
        filePath = await _exportToText();
      }

      if (mounted && filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Session exported to $filePath'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<String?> _exportToPDF() async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Debate Mate Session Export',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Generated on: ${DateTime.now().toString()}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              ..._messages.map((msg) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    msg.isUser ? 'You' : 'AI Coach',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(msg.content),
                  pw.SizedBox(height: 10),
                ],
              )),
            ],
          );
        },
      ),
    );

    final timestamp = DateTime.now().toIso8601String().split('T')[0];
    final fileName = 'debate_session_$timestamp.pdf';
    
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save PDF',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      final file = await File(result).writeAsBytes(await pdf.save());
      return file.path;
    }

    return null;
  }

  Future<String?> _exportToText() async {
    final buffer = StringBuffer();
    buffer.writeln('Debate Mate Session Export');
    buffer.writeln('Generated on: ${DateTime.now()}');
    buffer.writeln('=' * 50);
    buffer.writeln();

    for (final msg in _messages) {
      buffer.writeln('${msg.isUser ? 'You' : 'AI Coach'}:');
      buffer.writeln(msg.content);
      buffer.writeln();
    }

    final timestamp = DateTime.now().toIso8601String().split('T')[0];
    final fileName = 'debate_session_$timestamp.txt';
    
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Text File',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null) {
      final file = File(result);
      await file.writeAsString(buffer.toString());
      return file.path;
    }

    return null;
  }

  void _clearConversation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Conversation'),
        content: const Text('Are you sure you want to clear the conversation history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _messages.clear();
              });
              _addWelcomeMessage();
              _saveConversationHistory();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userData = ref.watch(currentUserDataProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: theme.brightness == Brightness.dark 
              ? AppTheme.darkBackgroundGradient 
              : AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Main chat area
              Expanded(
                child: Column(
                  children: [
                    // Header
                    _buildHeader(theme, userData),
                    
                    // Chat messages
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            children: [
                              // Messages list
                              Expanded(
                                child: ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == _messages.length && _isTyping) {
                                      return const TypingIndicator();
                                    }
                                    
                                    final message = _messages[index];
                                    return ChatBubble(
                                      message: message,
                                      onFallacyTap: () {
                                        // Handle fallacy tap for detailed view
                                      },
                                      onOptimizationTap: () {
                                        // Handle optimization tap for detailed view
                                      },
                                    );
                                  },
                                ),
                              ),
                              
                              // Input area
                              _buildInputArea(theme),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              
              // Progress sidebar
              if (_showProgress)
                ProgressSidebar(
                  progressData: _progressData,
                  totalSessions: _totalSessions,
                  totalFallacies: _totalFallaciesDetected,
                  averageScore: _averageScore,
                  onClose: () => setState(() => _showProgress = false),
                ),
              
              // Settings panel
              if (_showSettings)
                SettingsPanel(
                  speechEnabled: _speechEnabled,
                  onSpeechToggle: (enabled) {
                    setState(() {
                      _speechEnabled = enabled;
                    });
                  },
                  onThemeToggle: () {
                    // Handle theme toggle
                  },
                  onClose: () => setState(() => _showSettings = false),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, userData) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Logo and title
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Debate Mate',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'AI Debate Coach',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const Spacer(),
          
          // Action buttons
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _showProgress = !_showProgress),
                icon: Icon(
                  Icons.analytics_outlined,
                  color: theme.colorScheme.onSurface,
                ),
                tooltip: 'Progress',
              ),
              IconButton(
                onPressed: _exportSession,
                icon: Icon(
                  Icons.download_outlined,
                  color: theme.colorScheme.onSurface,
                ),
                tooltip: 'Export Session',
              ),
              IconButton(
                onPressed: _clearConversation,
                icon: Icon(
                  Icons.clear_all_outlined,
                  color: theme.colorScheme.onSurface,
                ),
                tooltip: 'Clear Conversation',
              ),
              IconButton(
                onPressed: () => setState(() => _showSettings = !_showSettings),
                icon: Icon(
                  Icons.settings_outlined,
                  color: theme.colorScheme.onSurface,
                ),
                tooltip: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Voice input button
          if (_speechEnabled)
            VoiceInputButton(
              isListening: _isListening,
              onPressed: _isListening ? _stopVoiceInput : _startVoiceInput,
            ),
          
          if (_speechEnabled) const SizedBox(width: 8),
          
          // Text input
          Expanded(
            child: TextField(
              controller: _textController,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type your argument here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _handleTextSubmit(),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Send button
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: _isLoading ? null : _handleTextSubmit,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}


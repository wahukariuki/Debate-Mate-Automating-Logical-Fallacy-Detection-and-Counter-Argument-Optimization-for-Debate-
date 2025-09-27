import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../../core/theme/app_theme.dart';
import '../models/dashboard_models.dart';

/// Export session dialog for saving debate sessions
class ExportSessionDialog extends StatefulWidget {
  final List<ChatMessage> messages;
  final List<ProgressData> progressData;
  final Function(ExportFormat) onExport;

  const ExportSessionDialog({
    super.key,
    required this.messages,
    required this.progressData,
    required this.onExport,
  });

  @override
  State<ExportSessionDialog> createState() => _ExportSessionDialogState();
}

class _ExportSessionDialogState extends State<ExportSessionDialog> {
  ExportFormat _selectedFormat = ExportFormat.pdf;
  bool _includeProgress = true;
  bool _includeMetadata = true;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(theme),
            const SizedBox(height: 24),
            
            // Format selection
            _buildFormatSelection(theme),
            const SizedBox(height: 24),
            
            // Options
            _buildOptions(theme),
            const SizedBox(height: 24),
            
            // Preview
            _buildPreview(theme),
            const SizedBox(height: 24),
            
            // Actions
            _buildActions(theme),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
      curve: Curves.easeOut,
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.download_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Export Session',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Save your debate session for future reference',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormatSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Format',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildFormatOption(
                theme,
                ExportFormat.pdf,
                'PDF Document',
                'Best for sharing and printing',
                Icons.picture_as_pdf_outlined,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFormatOption(
                theme,
                ExportFormat.text,
                'Text File',
                'Simple text format',
                Icons.text_snippet_outlined,
                Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatOption(
    ThemeData theme,
    ExportFormat format,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedFormat == format;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFormat = format;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Options',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildOptionTile(
          theme,
          'Include Progress Data',
          'Add charts and statistics to the export',
          Icons.analytics_outlined,
          _includeProgress,
          (value) {
            setState(() {
              _includeProgress = value;
            });
          },
        ),
        
        const SizedBox(height: 12),
        
        _buildOptionTile(
          theme,
          'Include Metadata',
          'Add timestamps and session information',
          Icons.info_outlined,
          _includeMetadata,
          (value) {
            setState(() {
              _includeMetadata = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildOptionTile(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Export Preview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildPreviewItem(
            theme,
            'Messages',
            '${widget.messages.length} conversation entries',
            Icons.chat_outlined,
          ),
          
          if (_includeProgress) ...[
            const SizedBox(height: 8),
            _buildPreviewItem(
              theme,
              'Progress Data',
              '${widget.progressData.length} session records',
              Icons.trending_up_outlined,
            ),
          ],
          
          if (_includeMetadata) ...[
            const SizedBox(height: 8),
            _buildPreviewItem(
              theme,
              'Metadata',
              'Timestamps and session info',
              Icons.info_outlined,
            ),
          ],
          
          const SizedBox(height: 8),
          _buildPreviewItem(
            theme,
            'Format',
            _selectedFormat == ExportFormat.pdf ? 'PDF Document' : 'Text File',
            _selectedFormat == ExportFormat.pdf 
                ? Icons.picture_as_pdf_outlined 
                : Icons.text_snippet_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.onSurfaceVariant,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isExporting ? null : _handleExport,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isExporting
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Exporting...'),
                    ],
                  )
                : const Text('Export'),
          ),
        ),
      ],
    );
  }

  Future<void> _handleExport() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final timestamp = DateTime.now().toIso8601String().split('T')[0];
      String? filePath;

      if (_selectedFormat == ExportFormat.pdf) {
        filePath = await _exportToPDF(timestamp);
      } else {
        filePath = await _exportToText(timestamp);
      }

      if (mounted) {
        Navigator.of(context).pop();
        
        if (filePath != null) {
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
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<String?> _exportToPDF(String timestamp) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Debate Mate Session Export',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Metadata
              if (_includeMetadata) ...[
                pw.Text(
                  'Generated on: ${DateTime.now().toString()}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  'Total Messages: ${widget.messages.length}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  'Session Duration: ${_calculateSessionDuration()}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 20),
              ],
              
              // Messages
              pw.Header(
                level: 1,
                child: pw.Text(
                  'Conversation History',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 16),
              
              ...widget.messages.map((msg) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: msg.isUser ? PdfColors.blue100 : PdfColors.grey100,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          msg.isUser ? 'You' : 'AI Coach',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(msg.content),
                        if (_includeMetadata) ...[
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '${msg.timestamp}',
                            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                          ),
                        ],
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 8),
                ],
              )),
              
              // Progress Data
              if (_includeProgress && widget.progressData.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Header(
                  level: 1,
                  child: pw.Text(
                    'Progress Summary',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 16),
                
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Session', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Score', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Fallacies', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Optimizations', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...widget.progressData.map((data) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${widget.progressData.indexOf(data) + 1}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${(data.score * 100).round()}%'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(data.fallaciesDetected.toString()),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(data.optimizationsGenerated.toString()),
                        ),
                      ],
                    )),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );

    final fileName = 'debate_session_$timestamp.pdf';
    
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save PDF',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      final file = File(result);
      await file.writeAsBytes(await pdf.save());
      return file.path;
    }

    return null;
  }

  Future<String?> _exportToText(String timestamp) async {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('Debate Mate Session Export');
    buffer.writeln('=' * 50);
    buffer.writeln();
    
    // Metadata
    if (_includeMetadata) {
      buffer.writeln('Generated on: ${DateTime.now()}');
      buffer.writeln('Total Messages: ${widget.messages.length}');
      buffer.writeln('Session Duration: ${_calculateSessionDuration()}');
      buffer.writeln();
    }
    
    // Messages
    buffer.writeln('CONVERSATION HISTORY');
    buffer.writeln('=' * 30);
    buffer.writeln();
    
    for (final msg in widget.messages) {
      buffer.writeln('${msg.isUser ? 'You' : 'AI Coach'}:');
      buffer.writeln(msg.content);
      if (_includeMetadata) {
        buffer.writeln('Time: ${msg.timestamp}');
      }
      buffer.writeln();
    }
    
    // Progress Data
    if (_includeProgress && widget.progressData.isNotEmpty) {
      buffer.writeln('PROGRESS SUMMARY');
      buffer.writeln('=' * 20);
      buffer.writeln();
      
      buffer.writeln('Session\tScore\tFallacies\tOptimizations');
      buffer.writeln('-' * 50);
      
      for (int i = 0; i < widget.progressData.length; i++) {
        final data = widget.progressData[i];
        buffer.writeln('${i + 1}\t${(data.score * 100).round()}%\t${data.fallaciesDetected}\t${data.optimizationsGenerated}');
      }
    }

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

  String _calculateSessionDuration() {
    if (widget.messages.length < 2) return 'N/A';
    
    final firstMessage = widget.messages.first.timestamp;
    final lastMessage = widget.messages.last.timestamp;
    final duration = lastMessage.difference(firstMessage);
    
    if (duration.inMinutes < 1) {
      return '${duration.inSeconds} seconds';
    } else if (duration.inHours < 1) {
      return '${duration.inMinutes} minutes';
    } else {
      return '${duration.inHours} hours ${duration.inMinutes % 60} minutes';
    }
  }
}

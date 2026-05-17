import 'package:flutter/material.dart';
import 'terminal_chrome.dart';

/// Collapsible tool call block — matches desktop ToolCallBlock.tsx.
/// Shows [icon] ToolName summary. Expand to see input in terminal chrome.
class ToolCallBlock extends StatefulWidget {
  final String toolName;
  final String? toolInput;
  final bool isStreaming;

  const ToolCallBlock({
    super.key,
    required this.toolName,
    this.toolInput,
    this.isStreaming = false,
  });

  @override
  State<ToolCallBlock> createState() => _ToolCallBlockState();
}

class _ToolCallBlockState extends State<ToolCallBlock> {
  bool _expanded = false;

  /// Tool icons matching desktop TOOL_ICONS
  static const _icons = <String, IconData>{
    'Bash': Icons.terminal,
    'Read': Icons.description,
    'Write': Icons.edit_document,
    'Edit': Icons.edit_note,
    'Glob': Icons.search,
    'Grep': Icons.find_in_page,
    'Agent': Icons.smart_toy,
    'WebSearch': Icons.travel_explore,
    'WebFetch': Icons.cloud_download,
    'NotebookEdit': Icons.note,
    'Skill': Icons.auto_awesome,
    'Task': Icons.assignment,
    'AskUserQuestion': Icons.help_outline,
    'TodoWrite': Icons.checklist,
    'TaskOutput': Icons.outbox,
    'TaskStop': Icons.stop_circle,
    'EnterPlanMode': Icons.map,
    'ExitPlanMode': Icons.exit_to_app,
    'EnterWorktree': Icons.account_tree,
    'ExitWorktree': Icons.logout,
  };

  String get _summary {
    final name = widget.toolName;
    final input = widget.toolInput;
    if (input == null || input.isEmpty) return name;

    // Try extract command, file_path, or description for summary
    if (name == 'Bash') {
      final cmd = _extractJsonField(input, 'command');
      if (cmd != null) return cmd.length > 60 ? '${cmd.substring(0, 60)}...' : cmd;
    }
    if (name == 'Read' || name == 'Write' || name == 'Edit') {
      final path = _extractJsonField(input, 'file_path');
      if (path != null) {
        final name = path.split('/').last;
        return name;
      }
    }
    final desc = _extractJsonField(input, 'description');
    if (desc != null) return desc.length > 60 ? '${desc.substring(0, 60)}...' : desc;

    return name;
  }

  String? _extractJsonField(String json, String field) {
    final regex = RegExp('"$field"\\s*:\\s*"((?:[^"\\\\]|\\\\.)*)"');
    final match = regex.firstMatch(json);
    if (match != null) {
      return match.group(1)?.replaceAll('\\"', '"').replaceAll('\\n', '\n');
    }
    return null;
  }

  IconData get _icon => _icons[widget.toolName] ?? Icons.build;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasInput = widget.toolInput != null && widget.toolInput!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header — always visible, tap to expand
          InkWell(
            onTap: hasInput ? () => setState(() => _expanded = !_expanded) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(_icon, size: 14, color: colorScheme.outline),
                  const SizedBox(width: 8),
                  Text(
                    widget.toolName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  if (hasInput)
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                      color: colorScheme.outline,
                    ),
                  if (widget.isStreaming) ...[
                    const SizedBox(width: 4),
                    _spinner(),
                  ],
                ],
              ),
            ),
          ),
          // Expanded input
          if (_expanded && hasInput)
            TerminalChrome(
              title: '${widget.toolName} Input',
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SelectableText(
                  widget.toolInput!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    height: 1.4,
                    color: Color(0xFFD4D4D8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _spinner() {
    return SizedBox(
      width: 12,
      height: 12,
      child: CircularProgressIndicator(
        strokeWidth: 1.5,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

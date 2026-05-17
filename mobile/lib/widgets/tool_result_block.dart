import 'package:flutter/material.dart';
import 'terminal_chrome.dart';

/// Collapsible tool result block — matches desktop ToolResultBlock.tsx.
/// Shows status header (✓/✗). Expand to see content in terminal chrome.
class ToolResultBlock extends StatefulWidget {
  final String? content;
  final bool isError;

  const ToolResultBlock({
    super.key,
    this.content,
    this.isError = false,
  });

  @override
  State<ToolResultBlock> createState() => _ToolResultBlockState();
}

class _ToolResultBlockState extends State<ToolResultBlock> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isError = widget.isError;
    final hasContent = widget.content != null && widget.content!.isNotEmpty;
    final errorColor = colorScheme.error;
    final successColor = Colors.green.shade700;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isError ? errorColor.withValues(alpha: 0.06) : successColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isError ? errorColor.withValues(alpha: 0.2) : successColor.withValues(alpha: 0.2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status header
          InkWell(
            onTap: hasContent ? () => setState(() => _expanded = !_expanded) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    isError ? Icons.error_outline : Icons.check_circle_outline,
                    size: 14,
                    color: isError ? errorColor : successColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Result',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isError ? errorColor : successColor,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isError
                          ? errorColor.withValues(alpha: 0.1)
                          : successColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isError ? 'Error' : 'Success',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isError ? errorColor : successColor,
                      ),
                    ),
                  ),
                  if (hasContent) ...[
                    const SizedBox(width: 4),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                      color: isError ? errorColor.withValues(alpha: 0.6) : successColor.withValues(alpha: 0.6),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Expanded content
          if (_expanded && hasContent)
            TerminalChrome(
              title: isError ? 'Error Output' : 'Output',
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SelectableText(
                    widget.content!,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      height: 1.4,
                      color: isError
                          ? const Color(0xFFFF8A8A)
                          : const Color(0xFFD4D4D8),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

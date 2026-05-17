import 'package:flutter/material.dart';
import '../models/message.dart';

/// Renders a single chat message — text, thinking, tool use, tool result,
/// permission request, error, or system notification.
class ChatBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isStreaming;
  final void Function()? onApprove;
  final void Function()? onDeny;

  const ChatBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
    this.onApprove,
    this.onDeny,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final message = widget.message;
    final isStreaming = widget.isStreaming;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: () {
        switch (message.msgType) {
          case ChatMessageType.text:
            return _textBubble(colorScheme, message, isStreaming);
          case ChatMessageType.thinking:
            return _thinkingBubble(colorScheme, message);
          case ChatMessageType.toolUse:
            return _toolUseBubble(colorScheme, message, isStreaming);
          case ChatMessageType.toolResult:
            return _toolResultBubble(colorScheme, message);
          case ChatMessageType.permissionRequest:
            return _permissionBubble(colorScheme, message);
          case ChatMessageType.status:
            return _statusBubble(colorScheme, message);
          case ChatMessageType.error:
            return _errorBubble(colorScheme, message);
          case ChatMessageType.system:
            return _systemBubble(colorScheme, message);
        }
      }(),
    );
  }

  Widget _textBubble(ColorScheme colorScheme, ChatMessage message, bool isStreaming) {
    final text = message.text ?? '';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            text,
            style: TextStyle(color: colorScheme.onSurface),
          ),
          if (isStreaming)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: _cursor(colorScheme),
            ),
        ],
      ),
    );
  }

  Widget _thinkingBubble(ColorScheme colorScheme, ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        message.thinking ?? '',
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _toolUseBubble(ColorScheme colorScheme, ChatMessage message, bool isStreaming) {
    final toolName = message.toolName ?? '';
    final hasInput = message.toolInput != null && message.toolInput!.isNotEmpty;

    // Extract a short command summary for Bash tools
    String summary = 'Tool: $toolName';
    if (toolName == 'Bash' && hasInput) {
      try {
        final cmd = _extractJsonField(message.toolInput!, 'command');
        if (cmd != null && cmd.length <= 60) {
          summary = cmd;
        } else if (cmd != null) {
          summary = '${cmd.substring(0, 60)}...';
        }
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: hasInput ? () => setState(() => _expanded = !_expanded) : null,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.terminal, size: 14, color: Colors.indigo.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.indigo.shade700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  if (hasInput)
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                      color: Colors.indigo.shade400,
                    ),
                  if (isStreaming) const SizedBox(width: 4),
                  if (isStreaming) _cursor(colorScheme),
                ],
              ),
            ),
          ),
          if (_expanded && hasInput)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.shade100.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: SelectableText(
                message.toolInput!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.indigo.shade900,
                  fontFamily: 'monospace',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _toolResultBubble(ColorScheme colorScheme, ChatMessage message) {
    final hasContent = message.toolResult != null && message.toolResult!.isNotEmpty;
    final isError = message.toolIsError;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isError ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: hasContent ? () => setState(() => _expanded = !_expanded) : null,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    isError ? Icons.error_outline : Icons.check_circle_outline,
                    size: 14,
                    color: isError ? Colors.red.shade600 : Colors.green.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isError ? 'Error' : 'Result',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isError ? Colors.red.shade700 : Colors.green.shade700,
                    ),
                  ),
                  if (hasContent) ...[
                    const Spacer(),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                      color: isError ? Colors.red.shade400 : Colors.green.shade400,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_expanded && hasContent)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isError ? Colors.red.shade100.withValues(alpha: 0.5) : Colors.green.shade100.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: SelectableText(
                message.toolResult!,
                style: TextStyle(
                  fontSize: 12,
                  color: isError ? Colors.red.shade900 : Colors.green.shade900,
                  fontFamily: 'monospace',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _permissionBubble(ColorScheme colorScheme, ChatMessage message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, size: 18, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'haha wants to use: ${message.toolName ?? 'tool'}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade900,
                  ),
                ),
              ),
            ],
          ),
          if (message.permissionDescription != null) ...[
            const SizedBox(height: 4),
            Text(
              message.permissionDescription!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange.shade800,
              ),
            ),
          ],
          if (message.toolInput != null && message.toolInput!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: SelectableText(
                message.toolInput!,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Colors.orange.shade900,
                ),
                maxLines: 6,
              ),
            ),
          ],
          if (message.permissionPending) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: widget.onDeny,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Deny'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: widget.onApprove,
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Approve'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Responded',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBubble(ColorScheme colorScheme, ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: Text(
          message.text ?? '',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _errorBubble(ColorScheme colorScheme, ChatMessage message) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 18, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message.errorText ?? 'Unknown error',
              style: TextStyle(color: Colors.red.shade800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _systemBubble(ColorScheme colorScheme, ChatMessage message) {
    if (message.tokenUsage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Center(
          child: Text(
            'Tokens: ${message.tokenUsage!['input_tokens'] ?? 0} in / ${message.tokenUsage!['output_tokens'] ?? 0} out',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: Text(
          message.text ?? '',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _cursor(ColorScheme colorScheme) {
    return Container(
      width: 8,
      height: 14,
      decoration: BoxDecoration(
        color: colorScheme.onSurface,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Extract a field value from a JSON string like {"command": "ls -la"}.
  String? _extractJsonField(String jsonStr, String field) {
    // Simple regex extraction to avoid heavy JSON parsing
    final regex = RegExp('"$field"\\s*:\\s*"((?:[^"\\\\]|\\\\.)*)"');
    final match = regex.firstMatch(jsonStr);
    if (match != null) {
      return match.group(1)?.replaceAll('\\"', '"').replaceAll('\\n', '\n');
    }
    return null;
  }
}

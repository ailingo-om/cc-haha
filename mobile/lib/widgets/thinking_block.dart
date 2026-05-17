import 'package:flutter/material.dart';

/// Collapsible thinking block — matches desktop ThinkingBlock.tsx.
/// Collapsed: ▶ Thinking: preview... | Expanded: full text in bordered box.
class ThinkingBlock extends StatefulWidget {
  final String content;
  final bool isActive;

  const ThinkingBlock({super.key, required this.content, this.isActive = false});

  @override
  State<ThinkingBlock> createState() => _ThinkingBlockState();
}

class _ThinkingBlockState extends State<ThinkingBlock> {
  bool _expanded = false;

  String get _preview {
    final lines = widget.content.split('\n').where((l) => l.trim().isNotEmpty);
    if (lines.isEmpty) return '';
    final first = lines.first.replaceAll(RegExp(r'\s+'), ' ').trim();
    return first.length > 80 ? '${first.substring(0, 80)}...' : first;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final preview = _preview;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Text(
                  _expanded ? '\u25BE' : '\u25B8',
                  style: TextStyle(fontSize: 10, color: colorScheme.outline),
                ),
                const SizedBox(width: 4),
                Text(
                  'Thinking',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (widget.isActive) ...[
                  const SizedBox(width: 4),
                  _blinkingCursor(),
                ],
                if (!_expanded && preview.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_expanded)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 4, bottom: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
            ),
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: Text(
                widget.content,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  height: 1.35,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _blinkingCursor() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: const Duration(milliseconds: 600),
      builder: (_, value, child) => Opacity(opacity: value, child: child),
      child: Container(width: 1.5, height: 14, color: const Color(0xFF9C7CF4)),
    );
  }
}

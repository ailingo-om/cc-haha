import 'package:flutter/material.dart';

/// macOS-style terminal decoration with traffic light buttons.
/// Reusable wrapper for tool input/output — matches desktop TerminalChrome.tsx.
class TerminalChrome extends StatelessWidget {
  final String? title;
  final Widget child;

  const TerminalChrome({super.key, this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title bar with traffic lights
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D3F),
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
              ),
            ),
            child: Row(
              children: [
                _trafficLight(const Color(0xFFFF5F57)),
                const SizedBox(width: 6),
                _trafficLight(const Color(0xFFFFBD2E)),
                const SizedBox(width: 6),
                _trafficLight(const Color(0xFF27CA40)),
                if (title != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        color: Color(0xFF9898A8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Content
          child,
        ],
      ),
    );
  }

  Widget _trafficLight(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

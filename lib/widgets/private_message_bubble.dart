import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/message_model.dart';

class PrivateMessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isCurrentUser;
  final bool isRead;

  const PrivateMessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        left: isCurrentUser ? 64 : 12,
        right: isCurrentUser ? 12 : 64,
        top: 4,
        bottom: 4,
      ),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Text(
                message.senderName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: isCurrentUser
                  ? LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isCurrentUser
                  ? null
                  : isDark
                      ? const Color(0xFF242424)
                      : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isCurrentUser ? 20 : 4),
                bottomRight: Radius.circular(isCurrentUser ? 4 : 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: isCurrentUser
                      ? theme.colorScheme.primary.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    color: isCurrentUser
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(message.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: isCurrentUser
                            ? Colors.white.withValues(alpha: 0.75)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 4),
                      Icon(
                        isRead ? Icons.done_all_rounded : Icons.done_rounded,
                        size: 16,
                        color: isRead
                            ? const Color(0xFF34B7F1)
                            : Colors.white.withValues(alpha: 0.75),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

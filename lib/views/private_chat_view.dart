import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/conversation_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/private_message_bubble.dart';
import '../widgets/message_input.dart';

class PrivateChatView extends StatefulWidget {
  final String chatId;

  const PrivateChatView({super.key, required this.chatId});

  @override
  State<PrivateChatView> createState() => _PrivateChatViewState();
}

class _PrivateChatViewState extends State<PrivateChatView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  Timer? _markAsReadTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConversationViewModel>().loadChatMessages(widget.chatId);

      _markAsReadTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          context.read<ConversationViewModel>().markCurrentChatAsRead();
        }
      });
    });
  }

  @override
  void dispose() {
    _markAsReadTimer?.cancel();
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationViewModel = context.watch<ConversationViewModel>();
    final authViewModel = context.read<AuthViewModel>();
    final theme = Theme.of(context);

    final chat = conversationViewModel.getChatById(widget.chatId);
    final currentUserId = authViewModel.currentUser?.uid ?? '';
    final chatName = chat?.getChatName(currentUserId) ?? 'Chat';

    final otherUserId = chat?.participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    final isOtherUserTyping = chat?.isUserTyping(otherUserId ?? '') ?? false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chatName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            if (isOtherUserTyping)
              Text(
                'Digitando...',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.primary,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: conversationViewModel.currentChatMessages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 40,
                            color: theme.colorScheme.primary.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Nenhuma mensagem ainda',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Envie a primeira mensagem',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.scaffoldBackgroundColor,
                          theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: conversationViewModel.currentChatMessages.length,
                      itemBuilder: (context, index) {
                        final message =
                            conversationViewModel.currentChatMessages[index];
                        final isCurrentUser = conversationViewModel.isCurrentUser(
                          message.senderId,
                        );

                        final isRead = message.isReadBy(otherUserId ?? '');

                        return PrivateMessageBubble(
                          message: message,
                          isCurrentUser: isCurrentUser,
                          isRead: isRead,
                        );
                      },
                    ),
                  ),
          ),
          MessageInput(
            onSendMessage: (text) {
              conversationViewModel.sendMessage(widget.chatId, text);
              _scrollToBottom();
            },
            onTyping: () {
              conversationViewModel.startTyping(widget.chatId);
            },
          ),
        ],
      ),
    );
  }
}

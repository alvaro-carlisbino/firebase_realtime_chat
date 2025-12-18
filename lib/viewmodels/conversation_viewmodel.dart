import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/conversation_service.dart';
import '../services/auth_service.dart';

class ConversationViewModel extends ChangeNotifier {
  final ConversationService _conversationService;
  final AuthService _authService;

  List<ChatModel> _chats = [];
  List<MessageModel> _currentChatMessages = [];
  List<UserModel> _availableUsers = [];
  String? _currentChatId;
  Timer? _typingTimer;

  ConversationViewModel(this._conversationService, this._authService) {
    _loadChats();
    _loadAvailableUsers();
  }

  List<ChatModel> get chats => _chats;
  List<MessageModel> get currentChatMessages => _currentChatMessages;
  List<UserModel> get availableUsers => _availableUsers;
  String? get currentChatId => _currentChatId;

  void _loadChats() {
    final userId = _authService.getCurrentUserId();
    if (userId == null) return;

    _conversationService.getUserChats(userId).listen((chats) {
      _chats = chats;
      notifyListeners();
    });
  }

  void _loadAvailableUsers() {
    _conversationService.getAvailableUsers().listen((users) {
      final currentUserId = _authService.getCurrentUserId();
      _availableUsers = users.where((u) => u.uid != currentUserId).toList();
      notifyListeners();
    });
  }

  Future<String> startChatWith(UserModel otherUser) async {
    final currentUserId = _authService.getCurrentUserId();
    final currentUserName = _authService.getCurrentUserDisplayName();

    if (currentUserId == null) {
      throw Exception('Usuário não autenticado');
    }

    final chatId = await _conversationService.getOrCreateChat(
      currentUserId,
      otherUser.uid,
      currentUserName ?? 'Você',
      otherUser.displayName,
    );

    return chatId;
  }

  void loadChatMessages(String chatId) {
    _currentChatId = chatId;
    _conversationService.getChatMessages(chatId).listen((messages) {
      _currentChatMessages = messages;
      notifyListeners();
    });
  }

  Future<void> markCurrentChatAsRead() async {
    if (_currentChatId == null) return;

    final userId = _authService.getCurrentUserId();
    if (userId != null) {
      await _conversationService.markMessagesAsRead(_currentChatId!, userId);
    }
  }

  Future<void> sendMessage(String chatId, String text) async {
    if (text.trim().isEmpty) return;

    final userId = _authService.getCurrentUserId();
    final userName = _authService.getCurrentUserDisplayName();

    if (userId == null) return;

    await _conversationService.sendMessage(
      chatId: chatId,
      text: text.trim(),
      senderName: userName ?? 'Desconhecido',
      senderId: userId,
    );

    _stopTyping(chatId);
  }

  void startTyping(String chatId) {
    final userId = _authService.getCurrentUserId();
    if (userId == null) return;

    _conversationService.setTypingStatus(chatId, userId, true);

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      _stopTyping(chatId);
    });
  }

  void _stopTyping(String chatId) {
    final userId = _authService.getCurrentUserId();
    if (userId == null) return;

    _conversationService.setTypingStatus(chatId, userId, false);
    _typingTimer?.cancel();
  }

  bool isCurrentUser(String senderId) {
    return senderId == _authService.getCurrentUserId();
  }

  ChatModel? getChatById(String chatId) {
    try {
      return _chats.firstWhere((chat) => chat.id == chatId);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserPresence(UserModel user) async {
    await _conversationService.updateUserPresence(user);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }
}

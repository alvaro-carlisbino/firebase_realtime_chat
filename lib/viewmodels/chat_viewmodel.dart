import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _chatService;
  final AuthService _authService;

  List<MessageModel> _messages = [];
  final bool _isLoading = false;
  String? _errorMessage;

  ChatViewModel(this._chatService, this._authService) {
    _loadMessages();
  }

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _loadMessages() {
    _chatService.getMessages().listen(
      (messages) {
        _messages = messages;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Falha ao carregar mensagens';
        notifyListeners();
      },
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      final userId = _authService.getCurrentUserId();
      final userName = _authService.getCurrentUserDisplayName();

      if (userId == null) {
        _errorMessage = 'Usuário não autenticado';
        notifyListeners();
        return;
      }

      await _chatService.sendMessage(
        text: text.trim(),
        senderName: userName ?? 'Desconhecido',
        senderId: userId,
      );

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Falha ao enviar mensagem';
      notifyListeners();
    }
  }

  bool isCurrentUser(String senderId) {
    return senderId == _authService.getCurrentUserId();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

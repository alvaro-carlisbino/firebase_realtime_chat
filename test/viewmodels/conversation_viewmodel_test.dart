import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:chat_app_firebase/viewmodels/conversation_viewmodel.dart';
import 'package:chat_app_firebase/services/conversation_service.dart';
import 'package:chat_app_firebase/services/auth_service.dart';
import 'package:chat_app_firebase/models/chat_model.dart';
import 'package:chat_app_firebase/models/message_model.dart';
import 'package:chat_app_firebase/models/user_model.dart';

@GenerateNiceMocks([
  MockSpec<ConversationService>(),
  MockSpec<AuthService>(),
])
import 'conversation_viewmodel_test.mocks.dart';

void main() {
  late ConversationViewModel viewModel;
  late MockConversationService mockConversationService;
  late MockAuthService mockAuthService;
  late StreamController<List<ChatModel>> chatsStreamController;
  late StreamController<List<UserModel>> usersStreamController;
  late StreamController<List<MessageModel>> messagesStreamController;

  setUp(() {
    mockConversationService = MockConversationService();
    mockAuthService = MockAuthService();
    chatsStreamController = StreamController<List<ChatModel>>.broadcast();
    usersStreamController = StreamController<List<UserModel>>.broadcast();
    messagesStreamController = StreamController<List<MessageModel>>.broadcast();

    // Setup default mocks
    when(mockAuthService.getCurrentUserId()).thenReturn('user123');
    when(mockAuthService.getCurrentUserDisplayName()).thenReturn('João');
    when(mockConversationService.getUserChats('user123'))
        .thenAnswer((_) => chatsStreamController.stream);
    when(mockConversationService.getAvailableUsers())
        .thenAnswer((_) => usersStreamController.stream);
  });

  tearDown(() {
    chatsStreamController.close();
    usersStreamController.close();
    messagesStreamController.close();
  });

  group('ConversationViewModel', () {
    test('deve inicializar corretamente', () {
      viewModel = ConversationViewModel(mockConversationService, mockAuthService);

      expect(viewModel.chats, []);
      expect(viewModel.currentChatMessages, []);
      expect(viewModel.availableUsers, []);
      expect(viewModel.currentChatId, null);
    });

    test('deve carregar chats do usuário', () async {
      viewModel = ConversationViewModel(mockConversationService, mockAuthService);

      final chat1 = ChatModel(
        id: 'chat1',
        participantIds: ['user123', 'user456'],
        participantNames: {'user123': 'João', 'user456': 'Maria'},
      );

      chatsStreamController.add([chat1]);
      await Future.delayed(Duration.zero);

      expect(viewModel.chats.length, 1);
      expect(viewModel.chats[0].id, 'chat1');
    });

    test('deve carregar usuários disponíveis excluindo usuário atual', () async {
      viewModel = ConversationViewModel(mockConversationService, mockAuthService);

      final users = [
        UserModel(uid: 'user123', email: 'joao@test.com', displayName: 'João'),
        UserModel(uid: 'user456', email: 'maria@test.com', displayName: 'Maria'),
        UserModel(uid: 'user789', email: 'pedro@test.com', displayName: 'Pedro'),
      ];

      usersStreamController.add(users);
      await Future.delayed(Duration.zero);

      expect(viewModel.availableUsers.length, 2);
      expect(viewModel.availableUsers.any((u) => u.uid == 'user123'), false);
      expect(viewModel.availableUsers.any((u) => u.uid == 'user456'), true);
      expect(viewModel.availableUsers.any((u) => u.uid == 'user789'), true);
    });

    test('deve iniciar chat com outro usuário', () async {
      viewModel = ConversationViewModel(mockConversationService, mockAuthService);

      final otherUser = UserModel(
        uid: 'user456',
        email: 'maria@test.com',
        displayName: 'Maria',
      );

      when(mockConversationService.getOrCreateChat(
        'user123',
        'user456',
        'João',
        'Maria',
      )).thenAnswer((_) async => 'chat_user123_user456');

      final chatId = await viewModel.startChatWith(otherUser);

      expect(chatId, 'chat_user123_user456');
      verify(mockConversationService.getOrCreateChat(
        'user123',
        'user456',
        'João',
        'Maria',
      )).called(1);
    });

    test('deve carregar mensagens do chat', () async {
      viewModel = ConversationViewModel(mockConversationService, mockAuthService);

      when(mockConversationService.getChatMessages('chat123'))
          .thenAnswer((_) => messagesStreamController.stream);

      viewModel.loadChatMessages('chat123');

      final message1 = MessageModel(
        id: 'msg1',
        text: 'Hello',
        senderName: 'João',
        senderId: 'user123',
        timestamp: DateTime.now(),
        chatId: 'chat123',
      );

      messagesStreamController.add([message1]);
      await Future.delayed(Duration.zero);

      expect(viewModel.currentChatId, 'chat123');
      expect(viewModel.currentChatMessages.length, 1);
      expect(viewModel.currentChatMessages[0].text, 'Hello');
    });

    test('deve enviar mensagem', () async {
      viewModel = ConversationViewModel(mockConversationService, mockAuthService);

      when(mockConversationService.sendMessage(
        chatId: 'chat123',
        text: 'Hello World',
        senderName: 'João',
        senderId: 'user123',
      )).thenAnswer((_) async => {});

      when(mockConversationService.setTypingStatus('chat123', 'user123', false))
          .thenAnswer((_) async => {});

      await viewModel.sendMessage('chat123', 'Hello World');

      verify(mockConversationService.sendMessage(
        chatId: 'chat123',
        text: 'Hello World',
        senderName: 'João',
        senderId: 'user123',
      )).called(1);

      verify(mockConversationService.setTypingStatus('chat123', 'user123', false))
          .called(1);
    });

    test('não deve enviar mensagem vazia', () async {
      viewModel = ConversationViewModel(mockConversationService, mockAuthService);

      await viewModel.sendMessage('chat123', '   ');

      verifyNever(mockConversationService.sendMessage(
        chatId: anyNamed('chatId'),
        text: anyNamed('text'),
        senderName: anyNamed('senderName'),
        senderId: anyNamed('senderId'),
      ));
    });

    test('deve iniciar status de digitação', () async {
      viewModel = ConversationViewModel(mockConversationService, mockAuthService);

      when(mockConversationService.setTypingStatus('chat123', 'user123', true))
          .thenAnswer((_) async => {});

      viewModel.startTyping('chat123');

      await Future.delayed(Duration.zero);

      verify(mockConversationService.setTypingStatus('chat123', 'user123', true))
          .called(1);
    });

    test('deve parar status de digitação após 3 segundos', () async {
      viewModel = ConversationViewModel(mockConversationService, mockAuthService);

      when(mockConversationService.setTypingStatus('chat123', 'user123', true))
          .thenAnswer((_) async => {});
      when(mockConversationService.setTypingStatus('chat123', 'user123', false))
          .thenAnswer((_) async => {});

      viewModel.startTyping('chat123');

      await Future.delayed(Duration(seconds: 4));

      verify(mockConversationService.setTypingStatus('chat123', 'user123', false))
          .called(1);

      viewModel.dispose();
    });

    test('deve marcar mensagens como lidas', () async {
      viewModel = ConversationViewModel(mockConversationService, mockAuthService);

      when(mockConversationService.getChatMessages('chat123'))
          .thenAnswer((_) => messagesStreamController.stream);
      when(mockConversationService.markMessagesAsRead('chat123', 'user123'))
          .thenAnswer((_) async => {});

      viewModel.loadChatMessages('chat123');
      await viewModel.markCurrentChatAsRead();

      verify(mockConversationService.markMessagesAsRead('chat123', 'user123'))
          .called(1);
    });

    test('deve verificar se é usuário atual', () {
      viewModel = ConversationViewModel(mockConversationService, mockAuthService);

      expect(viewModel.isCurrentUser('user123'), true);
      expect(viewModel.isCurrentUser('user456'), false);
    });

    test('deve obter chat por ID', () async {
      viewModel = ConversationViewModel(mockConversationService, mockAuthService);

      final chat1 = ChatModel(
        id: 'chat1',
        participantIds: ['user123', 'user456'],
        participantNames: {},
      );

      final chat2 = ChatModel(
        id: 'chat2',
        participantIds: ['user123', 'user789'],
        participantNames: {},
      );

      chatsStreamController.add([chat1, chat2]);
      await Future.delayed(Duration.zero);

      final foundChat = viewModel.getChatById('chat2');
      expect(foundChat?.id, 'chat2');

      final notFoundChat = viewModel.getChatById('chat999');
      expect(notFoundChat, null);
    });

    test('deve atualizar presença do usuário', () async {
      viewModel = ConversationViewModel(mockConversationService, mockAuthService);

      final user = UserModel(
        uid: 'user123',
        email: 'joao@test.com',
        displayName: 'João',
      );

      when(mockConversationService.updateUserPresence(user))
          .thenAnswer((_) async => {});

      await viewModel.updateUserPresence(user);

      verify(mockConversationService.updateUserPresence(user)).called(1);
    });

    test('deve lançar exceção se tentar iniciar chat sem estar autenticado', () async {
      when(mockAuthService.getCurrentUserId()).thenReturn(null);
      viewModel = ConversationViewModel(mockConversationService, mockAuthService);

      final otherUser = UserModel(
        uid: 'user456',
        email: 'maria@test.com',
        displayName: 'Maria',
      );

      expect(
        () => viewModel.startChatWith(otherUser),
        throwsA(isA<Exception>()),
      );
    });

    test('deve receber chats do serviço', () async {
      viewModel = ConversationViewModel(mockConversationService, mockAuthService);

      final now = DateTime.now();
      // O serviço já retorna os chats ordenados
      final chat3 = ChatModel(
        id: 'chat3',
        participantIds: ['user123', 'user999'],
        participantNames: {},
        lastMessageTime: now,
      );

      final chat2 = ChatModel(
        id: 'chat2',
        participantIds: ['user123', 'user789'],
        participantNames: {},
        lastMessageTime: now.subtract(Duration(hours: 1)),
      );

      final chat1 = ChatModel(
        id: 'chat1',
        participantIds: ['user123', 'user456'],
        participantNames: {},
        lastMessageTime: now.subtract(Duration(hours: 2)),
      );

      // Chats já vêm ordenados do serviço
      chatsStreamController.add([chat3, chat2, chat1]);
      await Future.delayed(Duration.zero);

      expect(viewModel.chats.length, 3);
      expect(viewModel.chats[0].id, 'chat3');
      expect(viewModel.chats[1].id, 'chat2');
      expect(viewModel.chats[2].id, 'chat1');
    });
  });
}

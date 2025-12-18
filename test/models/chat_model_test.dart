import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app_firebase/models/chat_model.dart';

void main() {
  group('ChatModel', () {
    test('deve criar um ChatModel corretamente', () {
      final chat = ChatModel(
        id: 'chat123',
        participantIds: ['user1', 'user2'],
        participantNames: {'user1': 'João', 'user2': 'Maria'},
      );

      expect(chat.id, 'chat123');
      expect(chat.participantIds, ['user1', 'user2']);
      expect(chat.participantNames, {'user1': 'João', 'user2': 'Maria'});
      expect(chat.lastMessage, null);
      expect(chat.lastMessageTime, null);
      expect(chat.isTyping, {});
      expect(chat.unreadCount, {});
    });

    test('deve criar um ChatModel completo', () {
      final now = DateTime.now();
      final chat = ChatModel(
        id: 'chat123',
        participantIds: ['user1', 'user2'],
        participantNames: {'user1': 'João', 'user2': 'Maria'},
        lastMessage: 'Olá!',
        lastMessageTime: now,
        isTyping: {'user1': false, 'user2': true},
        unreadCount: {'user1': 0, 'user2': 3},
      );

      expect(chat.lastMessage, 'Olá!');
      expect(chat.lastMessageTime, now);
      expect(chat.isTyping, {'user1': false, 'user2': true});
      expect(chat.unreadCount, {'user1': 0, 'user2': 3});
    });

    test('deve converter para Map corretamente', () {
      final now = DateTime(2024, 1, 1, 12, 0, 0);
      final chat = ChatModel(
        id: 'chat123',
        participantIds: ['user1', 'user2'],
        participantNames: {'user1': 'João', 'user2': 'Maria'},
        lastMessage: 'Olá!',
        lastMessageTime: now,
        isTyping: {'user1': false, 'user2': true},
        unreadCount: {'user1': 0, 'user2': 3},
      );

      final map = chat.toMap();

      expect(map['participantIds'], {'user1': true, 'user2': true});
      expect(map['participantNames'], {'user1': 'João', 'user2': 'Maria'});
      expect(map['lastMessage'], 'Olá!');
      expect(map['lastMessageTime'], now.millisecondsSinceEpoch);
      expect(map['isTyping'], {'user1': false, 'user2': true});
      expect(map['unreadCount'], {'user1': 0, 'user2': 3});
    });

    test('deve criar ChatModel a partir de Map', () {
      final timestamp = DateTime(2024, 1, 1, 12, 0, 0).millisecondsSinceEpoch;
      final map = {
        'participantIds': {'user1': true, 'user2': true},
        'participantNames': {'user1': 'João', 'user2': 'Maria'},
        'lastMessage': 'Olá!',
        'lastMessageTime': timestamp,
        'isTyping': {'user1': false, 'user2': true},
        'unreadCount': {'user1': 0, 'user2': 3},
      };

      final chat = ChatModel.fromMap('chat123', map);

      expect(chat.id, 'chat123');
      expect(chat.participantIds, ['user1', 'user2']);
      expect(chat.participantNames, {'user1': 'João', 'user2': 'Maria'});
      expect(chat.lastMessage, 'Olá!');
      expect(chat.lastMessageTime?.millisecondsSinceEpoch, timestamp);
      expect(chat.isTyping, {'user1': false, 'user2': true});
      expect(chat.unreadCount, {'user1': 0, 'user2': 3});
    });

    test('deve criar ChatModel sem campos opcionais', () {
      final map = {
        'participantIds': {'user1': true, 'user2': true},
        'participantNames': {'user1': 'João', 'user2': 'Maria'},
      };

      final chat = ChatModel.fromMap('chat123', map);

      expect(chat.id, 'chat123');
      expect(chat.participantIds, ['user1', 'user2']);
      expect(chat.lastMessage, null);
      expect(chat.lastMessageTime, null);
      expect(chat.isTyping, {});
      expect(chat.unreadCount, {});
    });

    test('deve converter participantIds para formato de mapa no toMap', () {
      final chat = ChatModel(
        id: 'chat123',
        participantIds: ['user1', 'user2', 'user3'],
        participantNames: {},
      );

      final map = chat.toMap();
      final participantIdsMap = map['participantIds'] as Map;

      expect(participantIdsMap.keys.length, 3);
      expect(participantIdsMap['user1'], true);
      expect(participantIdsMap['user2'], true);
      expect(participantIdsMap['user3'], true);
    });

    test('deve extrair participantIds do formato de mapa no fromMap', () {
      final map = {
        'participantIds': {
          'user1': true,
          'user2': true,
          'user3': true,
        },
        'participantNames': {},
      };

      final chat = ChatModel.fromMap('chat123', map);

      expect(chat.participantIds.length, 3);
      expect(chat.participantIds.contains('user1'), true);
      expect(chat.participantIds.contains('user2'), true);
      expect(chat.participantIds.contains('user3'), true);
    });

    test('deve lidar com isTyping de diferentes usuários', () {
      final chat = ChatModel(
        id: 'chat123',
        participantIds: ['user1', 'user2'],
        participantNames: {'user1': 'João', 'user2': 'Maria'},
        isTyping: {'user1': false, 'user2': true},
      );

      expect(chat.isTyping?['user1'], false);
      expect(chat.isTyping?['user2'], true);
    });

    test('deve lidar com unreadCount de diferentes usuários', () {
      final chat = ChatModel(
        id: 'chat123',
        participantIds: ['user1', 'user2'],
        participantNames: {'user1': 'João', 'user2': 'Maria'},
        unreadCount: {'user1': 0, 'user2': 5},
      );

      expect(chat.unreadCount?['user1'], 0);
      expect(chat.unreadCount?['user2'], 5);
    });

    test('deve preservar dados após conversão Map -> Model -> Map', () {
      final timestamp = 1704110400000;
      final originalMap = {
        'participantIds': {'user1': true, 'user2': true},
        'participantNames': {'user1': 'João', 'user2': 'Maria'},
        'lastMessage': 'Teste',
        'lastMessageTime': timestamp,
        'isTyping': {'user1': true, 'user2': false},
        'unreadCount': {'user1': 2, 'user2': 0},
      };

      final chat = ChatModel.fromMap('chat123', originalMap);
      final convertedMap = chat.toMap();

      expect(convertedMap['participantIds'], {'user1': true, 'user2': true});
      expect(convertedMap['participantNames'], originalMap['participantNames']);
      expect(convertedMap['lastMessage'], originalMap['lastMessage']);
      expect(convertedMap['lastMessageTime'], originalMap['lastMessageTime']);
      expect(convertedMap['isTyping'], originalMap['isTyping']);
      expect(convertedMap['unreadCount'], originalMap['unreadCount']);
    });

    test('deve retornar nome correto do chat para usuário', () {
      final chat = ChatModel(
        id: 'chat123',
        participantIds: ['user1', 'user2'],
        participantNames: {'user1': 'João', 'user2': 'Maria'},
      );

      expect(chat.getChatName('user1'), 'Maria');
      expect(chat.getChatName('user2'), 'João');
    });

    test('deve verificar se usuário está digitando', () {
      final chat = ChatModel(
        id: 'chat123',
        participantIds: ['user1', 'user2'],
        participantNames: {},
        isTyping: {'user1': false, 'user2': true},
      );

      expect(chat.isUserTyping('user1'), false);
      expect(chat.isUserTyping('user2'), true);
      expect(chat.isUserTyping('user3'), false);
    });

    test('deve retornar contagem de não lidas para usuário', () {
      final chat = ChatModel(
        id: 'chat123',
        participantIds: ['user1', 'user2'],
        participantNames: {},
        unreadCount: {'user1': 5, 'user2': 0},
      );

      expect(chat.getUserUnreadCount('user1'), 5);
      expect(chat.getUserUnreadCount('user2'), 0);
      expect(chat.getUserUnreadCount('user3'), 0);
    });
  });
}

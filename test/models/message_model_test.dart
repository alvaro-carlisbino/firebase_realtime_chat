import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app_firebase/models/message_model.dart';

void main() {
  group('MessageModel', () {
    test('deve criar um MessageModel corretamente', () {
      final now = DateTime.now();
      final message = MessageModel(
        id: '123',
        text: 'Hello World',
        senderName: 'João',
        senderId: 'user123',
        timestamp: now,
      );

      expect(message.id, '123');
      expect(message.text, 'Hello World');
      expect(message.senderName, 'João');
      expect(message.senderId, 'user123');
      expect(message.timestamp, now);
      expect(message.chatId, null);
      expect(message.readBy, {});
    });

    test('deve criar um MessageModel com chatId e readBy', () {
      final now = DateTime.now();
      final message = MessageModel(
        id: '123',
        text: 'Hello World',
        senderName: 'João',
        senderId: 'user123',
        timestamp: now,
        chatId: 'chat456',
        readBy: {'user123': true, 'user456': false},
      );

      expect(message.chatId, 'chat456');
      expect(message.readBy, {'user123': true, 'user456': false});
    });

    test('deve converter para Map corretamente', () {
      final now = DateTime(2024, 1, 1, 12, 0, 0);
      final message = MessageModel(
        id: '123',
        text: 'Hello World',
        senderName: 'João',
        senderId: 'user123',
        timestamp: now,
        chatId: 'chat456',
        readBy: {'user123': true},
      );

      final map = message.toMap();

      expect(map['text'], 'Hello World');
      expect(map['senderName'], 'João');
      expect(map['senderId'], 'user123');
      expect(map['timestamp'], now.millisecondsSinceEpoch);
      expect(map['chatId'], 'chat456');
      expect(map['readBy'], {'user123': true});
    });

    test('deve criar MessageModel a partir de Map', () {
      final timestamp = DateTime(2024, 1, 1, 12, 0, 0).millisecondsSinceEpoch;
      final map = {
        'text': 'Hello World',
        'senderName': 'João',
        'senderId': 'user123',
        'timestamp': timestamp,
        'chatId': 'chat456',
        'readBy': {'user123': true},
      };

      final message = MessageModel.fromMap('123', map);

      expect(message.id, '123');
      expect(message.text, 'Hello World');
      expect(message.senderName, 'João');
      expect(message.senderId, 'user123');
      expect(message.timestamp.millisecondsSinceEpoch, timestamp);
      expect(message.chatId, 'chat456');
      expect(message.readBy, {'user123': true});
    });

    test('deve criar MessageModel sem campos opcionais', () {
      final timestamp = DateTime(2024, 1, 1, 12, 0, 0).millisecondsSinceEpoch;
      final map = {
        'text': 'Hello World',
        'senderName': 'João',
        'senderId': 'user123',
        'timestamp': timestamp,
      };

      final message = MessageModel.fromMap('123', map);

      expect(message.id, '123');
      expect(message.text, 'Hello World');
      expect(message.chatId, null);
      expect(message.readBy, {});
    });

    test('deve lidar com timestamp como int', () {
      final map = {
        'text': 'Test',
        'senderName': 'João',
        'senderId': 'user123',
        'timestamp': 1704110400000,
      };
      final message = MessageModel.fromMap('1', map);
      expect(message.timestamp.millisecondsSinceEpoch, 1704110400000);
    });

    test('deve lidar com readBy null ou vazio', () {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final mapWithNull = {
        'text': 'Test',
        'senderName': 'João',
        'senderId': 'user123',
        'timestamp': timestamp,
        'readBy': null,
      };
      final message1 = MessageModel.fromMap('1', mapWithNull);
      expect(message1.readBy, {});

      final mapWithoutReadBy = {
        'text': 'Test',
        'senderName': 'João',
        'senderId': 'user123',
        'timestamp': timestamp,
      };
      final message2 = MessageModel.fromMap('2', mapWithoutReadBy);
      expect(message2.readBy, {});
    });

    test('deve verificar se mensagem foi lida por usuário', () {
      final message = MessageModel(
        id: '123',
        text: 'Test',
        senderName: 'João',
        senderId: 'user123',
        timestamp: DateTime.now(),
        readBy: {'user123': true, 'user456': false},
      );

      expect(message.isReadBy('user123'), true);
      expect(message.isReadBy('user456'), false);
      expect(message.isReadBy('user789'), false);
    });

    test('deve fazer copyWith corretamente', () {
      final original = MessageModel(
        id: '123',
        text: 'Original',
        senderName: 'João',
        senderId: 'user123',
        timestamp: DateTime.now(),
      );

      final copied = original.copyWith(text: 'Modified');

      expect(copied.id, '123');
      expect(copied.text, 'Modified');
      expect(copied.senderName, 'João');
      expect(copied.senderId, 'user123');
    });

    test('deve preservar dados após conversão Map -> Model -> Map', () {
      final originalMap = {
        'text': 'Hello World',
        'senderName': 'João Silva',
        'senderId': 'abc123',
        'timestamp': 1704110400000,
        'chatId': 'chat_private',
        'readBy': {'abc123': true, 'def456': false},
      };

      final message = MessageModel.fromMap('msg1', originalMap);
      final convertedMap = message.toMap();

      expect(convertedMap['text'], originalMap['text']);
      expect(convertedMap['senderName'], originalMap['senderName']);
      expect(convertedMap['senderId'], originalMap['senderId']);
      expect(convertedMap['timestamp'], originalMap['timestamp']);
      expect(convertedMap['chatId'], originalMap['chatId']);
      expect(convertedMap['readBy'], originalMap['readBy']);
    });
  });
}

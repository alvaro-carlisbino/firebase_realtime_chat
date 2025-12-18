import 'package:firebase_database/firebase_database.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class ConversationService {
  final DatabaseReference _chatsRef =
      FirebaseDatabase.instance.ref().child('chats');
  final DatabaseReference _messagesRef =
      FirebaseDatabase.instance.ref().child('privateMessages');
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref().child('users');

  Future<String> getOrCreateChat(String userId1, String userId2,
      String userName1, String userName2) async {
    final chatId = _generateChatId(userId1, userId2);

    final snapshot = await _chatsRef.child(chatId).get();

    if (!snapshot.exists) {
      final chat = ChatModel(
        id: chatId,
        participantIds: [userId1, userId2],
        participantNames: {
          userId1: userName1,
          userId2: userName2,
        },
      );
      await _chatsRef.child(chatId).set(chat.toMap());
    }

    return chatId;
  }

  String _generateChatId(String userId1, String userId2) {
    final sorted = [userId1, userId2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Stream<List<ChatModel>> getUserChats(String userId) {
    return _chatsRef.onValue.map((event) {
      final List<ChatModel> chats = [];

      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          if (value is Map) {
            final chat = ChatModel.fromMap(key, value);
            if (chat.participantIds.contains(userId)) {
              chats.add(chat);
            }
          }
        });

        chats.sort((a, b) {
          if (a.lastMessageTime == null) return 1;
          if (b.lastMessageTime == null) return -1;
          return b.lastMessageTime!.compareTo(a.lastMessageTime!);
        });
      }

      return chats;
    });
  }

  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _messagesRef
        .child(chatId)
        .orderByChild('timestamp')
        .onValue
        .map((event) {
      final List<MessageModel> messages = [];

      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          if (value is Map) {
            messages.add(MessageModel.fromMap(key, value));
          }
        });

        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      }

      return messages;
    });
  }

  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String senderName,
    required String senderId,
  }) async {
    final message = MessageModel(
      id: '',
      text: text,
      senderName: senderName,
      senderId: senderId,
      timestamp: DateTime.now(),
      chatId: chatId,
      readBy: {senderId: true},
    );

    final messageRef = _messagesRef.child(chatId).push();
    await messageRef.set(message.toMap());

    await _chatsRef.child(chatId).update({
      'lastMessage': text,
      'lastMessageTime': message.timestamp.millisecondsSinceEpoch,
    });

    final chatSnapshot = await _chatsRef.child(chatId).get();
    if (chatSnapshot.exists && chatSnapshot.value != null) {
      final chatData = chatSnapshot.value as Map<dynamic, dynamic>;

      if (chatData['participantIds'] != null) {
        final participantIds =
            (chatData['participantIds'] as Map<dynamic, dynamic>).keys.toList();

        for (var participantId in participantIds) {
          if (participantId != senderId) {
            final currentUnread =
                chatData['unreadCount']?[participantId] as int? ?? 0;
            await _chatsRef
                .child(chatId)
                .child('unreadCount')
                .update({participantId.toString(): currentUnread + 1});
          }
        }
      }
    }
  }

  Future<void> markMessagesAsRead(String chatId, String userId) async {
    final snapshot = await _messagesRef.child(chatId).get();

    if (snapshot.exists && snapshot.value != null) {
      final data = snapshot.value as Map<dynamic, dynamic>;

      data.forEach((key, value) async {
        if (value is Map && value['senderId'] != userId) {
          await _messagesRef
              .child(chatId)
              .child(key)
              .child('readBy')
              .update({userId: true});
        }
      });
    }

    await _chatsRef
        .child(chatId)
        .child('unreadCount')
        .update({userId: 0});
  }

  Future<void> setTypingStatus(
      String chatId, String userId, bool isTyping) async {
    await _chatsRef
        .child(chatId)
        .child('isTyping')
        .update({userId: isTyping});
  }

  Stream<List<UserModel>> getAvailableUsers() {
    return _usersRef.onValue.map((event) {
      final List<UserModel> users = [];

      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          if (value is Map) {
            users.add(UserModel.fromMap(Map<String, dynamic>.from(value)));
          }
        });
      }

      return users;
    });
  }

  Future<void> updateUserPresence(UserModel user) async {
    await _usersRef.child(user.uid).set(user.toMap());
  }

  Future<void> updateUserFCMToken(String userId, String token) async {
    await _usersRef.child(userId).update({'fcmToken': token});
  }

  Future<String?> getUserFCMToken(String userId) async {
    final snapshot = await _usersRef.child(userId).child('fcmToken').get();
    return snapshot.value as String?;
  }
}

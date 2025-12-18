import 'package:firebase_database/firebase_database.dart';
import '../models/message_model.dart';

class ChatService {
  final DatabaseReference _messagesRef =
      FirebaseDatabase.instance.ref().child('messages');

  Stream<List<MessageModel>> getMessages() {
    return _messagesRef
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
    );

    await _messagesRef.push().set(message.toMap());
  }
}

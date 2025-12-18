class MessageModel {
  final String id;
  final String text;
  final String senderName;
  final String senderId;
  final DateTime timestamp;
  final String? chatId;
  final Map<String, bool> readBy;

  MessageModel({
    required this.id,
    required this.text,
    required this.senderName,
    required this.senderId,
    required this.timestamp,
    this.chatId,
    Map<String, bool>? readBy,
  }) : readBy = readBy ?? {};

  factory MessageModel.fromMap(String id, Map<dynamic, dynamic> map) {
    final readByMap = Map<String, bool>.from(
      (map['readBy'] as Map<dynamic, dynamic>?)?.map(
            (k, v) => MapEntry(k.toString(), v as bool),
          ) ??
          {},
    );

    return MessageModel(
      id: id,
      text: map['text'] ?? '',
      senderName: map['senderName'] ?? '',
      senderId: map['senderId'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      chatId: map['chatId']?.toString(),
      readBy: readByMap,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderName': senderName,
      'senderId': senderId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      if (chatId != null) 'chatId': chatId,
      'readBy': readBy,
    };
  }

  bool isReadBy(String userId) {
    return readBy[userId] ?? false;
  }

  MessageModel copyWith({
    String? id,
    String? text,
    String? senderName,
    String? senderId,
    DateTime? timestamp,
    String? chatId,
    Map<String, bool>? readBy,
  }) {
    return MessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      senderName: senderName ?? this.senderName,
      senderId: senderId ?? this.senderId,
      timestamp: timestamp ?? this.timestamp,
      chatId: chatId ?? this.chatId,
      readBy: readBy ?? this.readBy,
    );
  }
}

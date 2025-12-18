class ChatModel {
  final String id;
  final List<String> participantIds;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final Map<String, dynamic> participantNames;
  final Map<String, bool> isTyping;
  final Map<String, int> unreadCount;

  ChatModel({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageTime,
    required this.participantNames,
    Map<String, bool>? isTyping,
    Map<String, int>? unreadCount,
  })  : isTyping = isTyping ?? {},
        unreadCount = unreadCount ?? {};

  factory ChatModel.fromMap(String id, Map<dynamic, dynamic> map) {
    final participantIds = (map['participantIds'] as Map<dynamic, dynamic>?)
            ?.keys
            .map((e) => e.toString())
            .toList() ??
        [];

    final participantNames = Map<String, dynamic>.from(
      map['participantNames'] ?? {},
    );

    final isTyping = Map<String, bool>.from(
      (map['isTyping'] as Map<dynamic, dynamic>?)?.map(
            (k, v) => MapEntry(k.toString(), v as bool),
          ) ??
          {},
    );

    final unreadCount = Map<String, int>.from(
      (map['unreadCount'] as Map<dynamic, dynamic>?)?.map(
            (k, v) => MapEntry(k.toString(), v as int),
          ) ??
          {},
    );

    return ChatModel(
      id: id,
      participantIds: participantIds,
      lastMessage: map['lastMessage']?.toString(),
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime'] as int)
          : null,
      participantNames: participantNames,
      isTyping: isTyping,
      unreadCount: unreadCount,
    );
  }

  Map<String, dynamic> toMap() {
    final participantIdsMap = <String, bool>{};
    for (var id in participantIds) {
      participantIdsMap[id] = true;
    }

    return {
      'participantIds': participantIdsMap,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.millisecondsSinceEpoch,
      'participantNames': participantNames,
      'isTyping': isTyping,
      'unreadCount': unreadCount,
    };
  }

  String getChatName(String currentUserId) {
    final otherUserId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );
    return participantNames[otherUserId] ?? 'Usuário';
  }

  bool isUserTyping(String userId) {
    return isTyping[userId] ?? false;
  }

  int getUserUnreadCount(String userId) {
    return unreadCount[userId] ?? 0;
  }
}

enum ConversationStatus {
  active,
  archived,
  blocked,
}

enum ConversationType {
  ride,
  support,
  group,
}

class ChatConversation {

  const ChatConversation({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.participantIds,
    this.rideId,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageId,
    this.lastMessageAt,
    this.metadata,
  });
  final String id;
  final String title;
  final ConversationType type;
  final ConversationStatus status;
  final List<String> participantIds;
  final String? rideId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastMessageId;
  final DateTime? lastMessageAt;
  final Map<String, dynamic>? metadata;

  ChatConversation copyWith({
    String? id,
    String? title,
    ConversationType? type,
    ConversationStatus? status,
    List<String>? participantIds,
    String? rideId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessageId,
    DateTime? lastMessageAt,
    Map<String, dynamic>? metadata,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      participantIds: participantIds ?? this.participantIds,
      rideId: rideId ?? this.rideId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatConversation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatConversation(id: $id, title: $title, type: $type, status: $status)';
  }
}
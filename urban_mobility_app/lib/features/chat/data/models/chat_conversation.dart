import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_participant.dart';

class ChatConversation {
  final String id;
  final String rideId;
  final List<ChatParticipant> participants;
  final String? lastMessageId;
  final String? lastMessageContent;
  final DateTime? lastMessageAt;
  final String? lastMessageSenderId;
  final ConversationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, int> unreadCount;

  const ChatConversation({
    required this.id,
    required this.rideId,
    required this.participants,
    this.lastMessageId,
    this.lastMessageContent,
    this.lastMessageAt,
    this.lastMessageSenderId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.unreadCount,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] as String,
      rideId: json['rideId'] as String,
      participants: (json['participants'] as List)
          .map((p) => ChatParticipant.fromJson(p as Map<String, dynamic>))
          .toList(),
      lastMessageId: json['lastMessageId'] as String?,
      lastMessageContent: json['lastMessageContent'] as String?,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'] as String)
          : null,
      lastMessageSenderId: json['lastMessageSenderId'] as String?,
      status: ConversationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ConversationStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      unreadCount: Map<String, int>.from(json['unreadCount'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rideId': rideId,
      'participants': participants.map((p) => p.toJson()).toList(),
      'lastMessageId': lastMessageId,
      'lastMessageContent': lastMessageContent,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'lastMessageSenderId': lastMessageSenderId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }

  factory ChatConversation.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return ChatConversation(
      id: snapshot.id,
      rideId: data['rideId'] as String,
      participants: (data['participants'] as List)
          .map((p) => ChatParticipant.fromJson(p as Map<String, dynamic>))
          .toList(),
      lastMessageId: data['lastMessageId'] as String?,
      lastMessageContent: data['lastMessageContent'] as String?,
      lastMessageAt: data['lastMessageAt'] != null
          ? (data['lastMessageAt'] as Timestamp).toDate()
          : null,
      lastMessageSenderId: data['lastMessageSenderId'] as String?,
      status: ConversationStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ConversationStatus.active,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'rideId': rideId,
      'participants': participants.map((p) => p.toJson()).toList(),
      'lastMessageId': lastMessageId,
      'lastMessageContent': lastMessageContent,
      'lastMessageAt':
          lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'lastMessageSenderId': lastMessageSenderId,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'unreadCount': unreadCount,
    };
  }

  ChatConversation copyWith({
    String? id,
    String? rideId,
    List<ChatParticipant>? participants,
    String? lastMessageId,
    String? lastMessageContent,
    DateTime? lastMessageAt,
    String? lastMessageSenderId,
    ConversationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, int>? unreadCount,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      participants: participants ?? this.participants,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  ChatParticipant? getOtherParticipant(String currentUserId) {
    return participants.firstWhere(
      (p) => p.userId != currentUserId,
      orElse: () => participants.first,
    );
  }

  int getUnreadCountForUser(String userId) {
    return unreadCount[userId] ?? 0;
  }
}

enum ConversationStatus {
  active,
  archived,
  blocked,
  completed,
}
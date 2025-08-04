class ChatParticipant {
  final String userId;
  final String name;
  final String? avatarUrl;
  final ParticipantRole role;
  final bool isOnline;
  final DateTime? lastSeenAt;

  const ChatParticipant({
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.role,
    required this.isOnline,
    this.lastSeenAt,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      userId: json['userId'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      role: ParticipantRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => ParticipantRole.passenger,
      ),
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.parse(json['lastSeenAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'isOnline': isOnline,
      'lastSeenAt': lastSeenAt?.toIso8601String(),
    };
  }

  ChatParticipant copyWith({
    String? userId,
    String? name,
    String? avatarUrl,
    ParticipantRole? role,
    bool? isOnline,
    DateTime? lastSeenAt,
  }) {
    return ChatParticipant(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isOnline: isOnline ?? this.isOnline,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }
}

enum ParticipantRole {
  driver,
  passenger,
}
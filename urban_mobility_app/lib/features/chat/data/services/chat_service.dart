import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';
import '../models/chat_conversation.dart';
import '../models/chat_participant.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _conversationsCollection = 'conversations';
  static const String _messagesCollection = 'messages';

  CollectionReference<ChatConversation> get _conversations =>
      _firestore.collection(_conversationsCollection).withConverter<ChatConversation>(
        fromFirestore: (snapshot, options) => ChatConversation.fromFirestore(snapshot, options),
        toFirestore: (conversation, options) => conversation.toFirestore(),
      );

  CollectionReference<ChatMessage> get _messages =>
      _firestore.collection(_messagesCollection).withConverter<ChatMessage>(
        fromFirestore: (snapshot, options) => ChatMessage.fromFirestore(snapshot, options),
        toFirestore: (message, options) => message.toFirestore(),
      );

  Future<ChatConversation> createConversation({
    required String rideId,
    required String driverId,
    required String driverName,
    required String passengerId,
    required String passengerName,
  }) async {
    final conversation = ChatConversation(
      id: '',
      rideId: rideId,
      participants: [
        ChatParticipant(
          userId: driverId,
          name: driverName,
          role: ParticipantRole.driver,
          isOnline: true,
        ),
        ChatParticipant(
          userId: passengerId,
          name: passengerName,
          role: ParticipantRole.passenger,
          isOnline: true,
        ),
      ],
      status: ConversationStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      unreadCount: {driverId: 0, passengerId: 0},
    );

    final docRef = await _conversations.add(conversation);
    return conversation.copyWith(id: docRef.id);
  }

  Future<ChatConversation?> getConversationByRideId(String rideId) async {
    final querySnapshot = await _conversations
        .where('rideId', isEqualTo: rideId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;
    return querySnapshot.docs.first.data();
  }

  Stream<List<ChatConversation>> getUserConversations(String userId) {
    return _conversations
        .where('participants', arrayContains: {'userId': userId})
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    final message = ChatMessage(
      id: '',
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: type,
      status: MessageStatus.sent,
      createdAt: DateTime.now(),
    );

    final docRef = await _messages.add(message);
    final savedMessage = message.copyWith(id: docRef.id);

    await _updateConversationLastMessage(conversationId, savedMessage);

    return savedMessage;
  }

  Stream<List<ChatMessage>> getMessages(String conversationId) {
    return _messages
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> markMessageAsRead(String messageId, String userId) async {
    await _messages.doc(messageId).update({
      'readAt': Timestamp.now(),
      'status': MessageStatus.read.name,
    });
  }

  Future<void> markConversationAsRead(String conversationId, String userId) async {
    await _conversations.doc(conversationId).update({
      'unreadCount.$userId': 0,
    });

    final messages = await _messages
        .where('conversationId', isEqualTo: conversationId)
        .where('senderId', isNotEqualTo: userId)
        .where('status', whereIn: [MessageStatus.sent.name, MessageStatus.delivered.name])
        .get();

    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.update(doc.reference, {
        'readAt': Timestamp.now(),
        'status': MessageStatus.read.name,
      });
    }
    await batch.commit();
  }

  Future<void> updateParticipantOnlineStatus(String userId, bool isOnline) async {
    final conversations = await _conversations
        .where('participants', arrayContains: {'userId': userId})
        .get();

    final batch = _firestore.batch();
    for (final doc in conversations.docs) {
      final conversation = doc.data();
      final updatedParticipants = conversation.participants.map((p) {
        if (p.userId == userId) {
          return p.copyWith(
            isOnline: isOnline,
            lastSeenAt: isOnline ? null : DateTime.now(),
          );
        }
        return p;
      }).toList();

      batch.update(doc.reference, {
        'participants': updatedParticipants.map((p) => p.toJson()).toList(),
      });
    }
    await batch.commit();
  }

  Future<void> _updateConversationLastMessage(String conversationId, ChatMessage message) async {
    await _conversations.doc(conversationId).update({
      'lastMessageId': message.id,
      'lastMessageContent': message.content,
      'lastMessageAt': Timestamp.fromDate(message.createdAt),
      'lastMessageSenderId': message.senderId,
      'updatedAt': Timestamp.now(),
    });

    final conversationDoc = await _conversations.doc(conversationId).get();
    if (conversationDoc.exists) {
      final conversation = conversationDoc.data()!;
      final updatedUnreadCount = Map<String, int>.from(conversation.unreadCount);
      
      for (final participant in conversation.participants) {
        if (participant.userId != message.senderId) {
          updatedUnreadCount[participant.userId] = 
              (updatedUnreadCount[participant.userId] ?? 0) + 1;
        }
      }

      await _conversations.doc(conversationId).update({
        'unreadCount': updatedUnreadCount,
      });
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    final batch = _firestore.batch();
    
    batch.delete(_conversations.doc(conversationId));
    
    final messages = await _messages
        .where('conversationId', isEqualTo: conversationId)
        .get();
    
    for (final doc in messages.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

  Future<void> updateConversationStatus(String conversationId, ConversationStatus status) async {
    await _conversations.doc(conversationId).update({
      'status': status.name,
      'updatedAt': Timestamp.now(),
    });
  }
}
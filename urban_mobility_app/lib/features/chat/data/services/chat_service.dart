import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/chat_conversation.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Conversações
  CollectionReference get _conversationsRef =>
      _firestore.collection('conversations');

  // Mensagens
  CollectionReference _messagesRef(String conversationId) =>
      _conversationsRef.doc(conversationId).collection('messages');

  // Converter Firestore para ChatConversation
  ChatConversation _conversationFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatConversation(
      id: doc.id,
      title: data['title'] ?? '',
      type: ConversationType.values.firstWhere(
        (e) => e.toString() == 'ConversationType.${data['type']}',
        orElse: () => ConversationType.ride,
      ),
      status: ConversationStatus.values.firstWhere(
        (e) => e.toString() == 'ConversationStatus.${data['status']}',
        orElse: () => ConversationStatus.active,
      ),
      participantIds: List<String>.from(data['participantIds'] ?? []),
      rideId: data['rideId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      lastMessageId: data['lastMessageId'],
      lastMessageAt: data['lastMessageAt'] != null
          ? (data['lastMessageAt'] as Timestamp).toDate()
          : null,
      metadata: data['metadata'],
    );
  }

  // Converter ChatConversation para Firestore
  Map<String, dynamic> _conversationToFirestore(ChatConversation conversation) {
    return {
      'title': conversation.title,
      'type': conversation.type.toString().split('.').last,
      'status': conversation.status.toString().split('.').last,
      'participantIds': conversation.participantIds,
      'rideId': conversation.rideId,
      'createdAt': Timestamp.fromDate(conversation.createdAt),
      'updatedAt': Timestamp.fromDate(conversation.updatedAt),
      'lastMessageId': conversation.lastMessageId,
      'lastMessageAt': conversation.lastMessageAt != null
          ? Timestamp.fromDate(conversation.lastMessageAt!)
          : null,
      'metadata': conversation.metadata,
    };
  }

  // Converter Firestore para ChatMessage
  ChatMessage _messageFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      conversationId: data['conversationId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      content: data['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${data['type']}',
        orElse: () => MessageType.text,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${data['status']}',
        orElse: () => MessageStatus.sent,
      ),
      metadata: data['metadata'],
    );
  }

  // Converter ChatMessage para Firestore
  Map<String, dynamic> _messageToFirestore(ChatMessage message) {
    return {
      'conversationId': message.conversationId,
      'senderId': message.senderId,
      'senderName': message.senderName,
      'content': message.content,
      'type': message.type.toString().split('.').last,
      'timestamp': Timestamp.fromDate(message.timestamp),
      'isRead': message.isRead,
      'status': message.status.toString().split('.').last,
      'metadata': message.metadata,
    };
  }

  // Criar nova conversa
  Future<String> createConversation({
    required String title,
    required ConversationType type,
    required List<String> participantIds,
    String? rideId,
    Map<String, dynamic>? metadata,
  }) async {
    final now = DateTime.now();
    final conversation = ChatConversation(
      id: '',
      title: title,
      type: type,
      status: ConversationStatus.active,
      participantIds: participantIds,
      rideId: rideId,
      createdAt: now,
      updatedAt: now,
      metadata: metadata,
    );

    final docRef = await _conversationsRef.add(_conversationToFirestore(conversation));
    return docRef.id;
  }

  // Obter conversas do usuário
  Stream<List<ChatConversation>> getUserConversations(String userId) {
    return _conversationsRef
        .where('participantIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _conversationFromFirestore(doc))
            .toList());
  }

  // Obter conversa específica
  Future<ChatConversation?> getConversation(String conversationId) async {
    final doc = await _conversationsRef.doc(conversationId).get();
    if (doc.exists) {
      return _conversationFromFirestore(doc);
    }
    return null;
  }

  // Enviar mensagem
  Future<String> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String content,
    required MessageType type,
    Map<String, dynamic>? metadata,
  }) async {
    final message = ChatMessage(
      id: '',
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: type,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    final docRef = await _messagesRef(conversationId).add(_messageToFirestore(message));

    // Atualizar última mensagem na conversa
    await _conversationsRef.doc(conversationId).update({
      'lastMessageId': docRef.id,
      'lastMessageAt': Timestamp.fromDate(message.timestamp),
      'updatedAt': Timestamp.fromDate(message.timestamp),
    });

    return docRef.id;
  }

  // Obter mensagens da conversa
  Stream<List<ChatMessage>> getConversationMessages(String conversationId) {
    return _messagesRef(conversationId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _messageFromFirestore(doc))
            .toList());
  }

  // Marcar mensagens como lidas
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    final batch = _firestore.batch();
    final messages = await _messagesRef(conversationId)
        .where('senderId', isNotEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in messages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  // Arquivar conversa
  Future<void> archiveConversation(String conversationId) async {
    await _conversationsRef.doc(conversationId).update({
      'status': ConversationStatus.archived.toString().split('.').last,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Deletar conversa
  Future<void> deleteConversation(String conversationId) async {
    // Deletar todas as mensagens
    final messages = await _messagesRef(conversationId).get();
    final batch = _firestore.batch();
    
    for (final doc in messages.docs) {
      batch.delete(doc.reference);
    }
    
    // Deletar a conversa
    batch.delete(_conversationsRef.doc(conversationId));
    
    await batch.commit();
  }
}
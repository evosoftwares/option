import '../../domain/repositories/chat_repository.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/chat_conversation.dart';
import '../services/chat_service.dart';

class ChatRepositoryImpl implements ChatRepository {

  ChatRepositoryImpl(this._chatService);
  final ChatService _chatService;

  @override
  Future<ChatConversation> createConversation({
    required String rideId,
    required String driverId,
    required String driverName,
    required String passengerId,
    required String passengerName,
  }) async {
    final conversationId = await _chatService.createConversation(
      title: 'Viagem $rideId',
      type: ConversationType.ride,
      participantIds: [driverId, passengerId],
      rideId: rideId,
      metadata: {
        'driverName': driverName,
        'passengerName': passengerName,
      },
    );

    final conversation = await _chatService.getConversation(conversationId);
    return conversation!;
  }

  @override
  Future<ChatConversation?> getConversationByRideId(String rideId) async {
    // Implementação simplificada - em produção seria necessário uma query específica
    // Por enquanto, retornamos null e deixamos para implementar quando necessário
    return null;
  }

  @override
  Stream<List<ChatConversation>> getUserConversations(String userId) {
    return _chatService.getUserConversations(userId);
  }

  @override
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    final messageId = await _chatService.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: type,
      metadata: {'senderName': senderName},
    );

    // Criar o objeto ChatMessage para retorno
    return ChatMessage(
      id: messageId,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: type,
      timestamp: DateTime.now(),
      metadata: {'senderName': senderName},
    );
  }

  @override
  Stream<List<ChatMessage>> getMessages(String conversationId) {
    return _chatService.getConversationMessages(conversationId);
  }

  @override
  Future<void> markMessageAsRead(String messageId, String userId) async {
    // Implementação simplificada - marcar todas as mensagens da conversa como lidas
    // Em uma implementação completa, seria necessário identificar a conversa do messageId
    // Por enquanto, deixamos vazio
  }

  @override
  Future<void> markConversationAsRead(String conversationId, String userId) async {
    await _chatService.markMessagesAsRead(conversationId, userId);
  }

  @override
  Future<void> updateParticipantOnlineStatus(String userId, bool isOnline) async {
    // Implementação futura - por enquanto deixamos vazio
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await _chatService.deleteConversation(conversationId);
  }

  @override
  Future<void> updateConversationStatus(String conversationId, ConversationStatus status) async {
    if (status == ConversationStatus.archived) {
      await _chatService.archiveConversation(conversationId);
    }
    // Para outros status, implementação futura
  }
}
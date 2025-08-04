import '../../domain/repositories/chat_repository.dart';
import '../models/chat_message.dart';
import '../models/chat_conversation.dart';
import '../services/chat_service.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatService _chatService;

  ChatRepositoryImpl(this._chatService);

  @override
  Future<ChatConversation> createConversation({
    required String rideId,
    required String driverId,
    required String driverName,
    required String passengerId,
    required String passengerName,
  }) {
    return _chatService.createConversation(
      rideId: rideId,
      driverId: driverId,
      driverName: driverName,
      passengerId: passengerId,
      passengerName: passengerName,
    );
  }

  @override
  Future<ChatConversation?> getConversationByRideId(String rideId) {
    return _chatService.getConversationByRideId(rideId);
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
  }) {
    return _chatService.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: type,
    );
  }

  @override
  Stream<List<ChatMessage>> getMessages(String conversationId) {
    return _chatService.getMessages(conversationId);
  }

  @override
  Future<void> markMessageAsRead(String messageId, String userId) {
    return _chatService.markMessageAsRead(messageId, userId);
  }

  @override
  Future<void> markConversationAsRead(String conversationId, String userId) {
    return _chatService.markConversationAsRead(conversationId, userId);
  }

  @override
  Future<void> updateParticipantOnlineStatus(String userId, bool isOnline) {
    return _chatService.updateParticipantOnlineStatus(userId, isOnline);
  }

  @override
  Future<void> deleteConversation(String conversationId) {
    return _chatService.deleteConversation(conversationId);
  }

  @override
  Future<void> updateConversationStatus(String conversationId, ConversationStatus status) {
    return _chatService.updateConversationStatus(conversationId, status);
  }
}
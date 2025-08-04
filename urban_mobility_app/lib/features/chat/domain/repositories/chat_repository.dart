import '../models/chat_message.dart';
import '../models/chat_conversation.dart';

abstract class ChatRepository {
  Future<ChatConversation> createConversation({
    required String rideId,
    required String driverId,
    required String driverName,
    required String passengerId,
    required String passengerName,
  });

  Future<ChatConversation?> getConversationByRideId(String rideId);

  Stream<List<ChatConversation>> getUserConversations(String userId);

  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String content,
    MessageType type = MessageType.text,
  });

  Stream<List<ChatMessage>> getMessages(String conversationId);

  Future<void> markMessageAsRead(String messageId, String userId);

  Future<void> markConversationAsRead(String conversationId, String userId);

  Future<void> updateParticipantOnlineStatus(String userId, bool isOnline);

  Future<void> deleteConversation(String conversationId);

  Future<void> updateConversationStatus(String conversationId, ConversationStatus status);
}
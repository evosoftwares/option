import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/models/chat_conversation.dart';

class ChatListProvider extends ChangeNotifier {
  final ChatRepository _repository;

  ChatListProvider(this._repository);

  List<ChatConversation> _conversations = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;
  StreamSubscription<List<ChatConversation>>? _conversationsSubscription;

  List<ChatConversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserConversations(String userId) async {
    _currentUserId = userId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _startListeningToConversations(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _startListeningToConversations(String userId) async {
    await _conversationsSubscription?.cancel();
    
    _conversationsSubscription = _repository.getUserConversations(userId).listen(
      (conversations) {
        _conversations = conversations;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  Future<ChatConversation> createConversation({
    required String rideId,
    required String driverId,
    required String driverName,
    required String passengerId,
    required String passengerName,
  }) async {
    try {
      // Check if conversation already exists for this ride
      final existingConversation = await _repository.getConversationByRideId(rideId);
      if (existingConversation != null) {
        return existingConversation;
      }

      final conversation = await _repository.createConversation(
        rideId: rideId,
        driverId: driverId,
        driverName: driverName,
        passengerId: passengerId,
        passengerName: passengerName,
      );

      return conversation;
    } catch (e) {
      _error = 'Erro ao criar conversa: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      await _repository.deleteConversation(conversationId);
    } catch (e) {
      _error = 'Erro ao excluir conversa: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> updateConversationStatus(
    String conversationId, 
    ConversationStatus status,
  ) async {
    try {
      await _repository.updateConversationStatus(conversationId, status);
    } catch (e) {
      _error = 'Erro ao atualizar status da conversa: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> markConversationAsRead(String conversationId) async {
    if (_currentUserId == null) return;

    try {
      await _repository.markConversationAsRead(conversationId, _currentUserId!);
    } catch (e) {
      // Silently handle error - not critical
      debugPrint('Error marking conversation as read: $e');
    }
  }

  int getTotalUnreadCount() {
    if (_currentUserId == null) return 0;
    
    return _conversations.fold<int>(0, (total, conversation) {
      return total + conversation.getUnreadCountForUser(_currentUserId!);
    });
  }

  List<ChatConversation> getActiveConversations() {
    return _conversations
        .where((c) => c.status == ConversationStatus.active)
        .toList();
  }

  List<ChatConversation> getArchivedConversations() {
    return _conversations
        .where((c) => c.status == ConversationStatus.archived)
        .toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _conversationsSubscription?.cancel();
    super.dispose();
  }
}
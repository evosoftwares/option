import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/chat_conversation.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _repository;

  ChatProvider(this._repository);

  ChatConversation? _conversation;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  String? _currentUserId;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;

  ChatConversation? get conversation => _conversation;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;

  Future<void> loadConversation(String conversationId, String currentUserId) async {
    _currentUserId = currentUserId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load conversation details (if needed)
      // For now, we'll just start listening to messages
      await _startListeningToMessages(conversationId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _startListeningToMessages(String conversationId) async {
    await _messagesSubscription?.cancel();
    
    _messagesSubscription = _repository.getMessages(conversationId).listen(
      (messages) {
        _messages = messages;
        notifyListeners();
        
        // Auto-mark messages as read when they arrive
        if (_currentUserId != null) {
          _markNewMessagesAsRead();
        }
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  void _markNewMessagesAsRead() {
    if (_currentUserId == null) return;
    
    for (final message in _messages) {
      if (message.senderId != _currentUserId && 
          message.status != MessageStatus.read) {
        _repository.markMessageAsRead(message.id, _currentUserId!).catchError((e) {
          // Silently handle error - not critical
          debugPrint('Error marking message as read: $e');
        });
      }
    }
  }

  Future<void> sendMessage({
    required String content,
    MessageType type = MessageType.text,
  }) async {
    if (_conversation?.id == null || _currentUserId == null) return;
    if (content.trim().isEmpty && type == MessageType.text) return;

    _isSending = true;
    notifyListeners();

    try {
      await _repository.sendMessage(
        conversationId: _conversation!.id,
        senderId: _currentUserId!,
        senderName: 'Usuário Atual', // TODO: Get from user service
        content: content,
        type: type,
      );
      
      _isSending = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao enviar mensagem: ${e.toString()}';
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> markConversationAsRead() async {
    if (_conversation?.id == null || _currentUserId == null) return;

    try {
      await _repository.markConversationAsRead(_conversation!.id, _currentUserId!);
    } catch (e) {
      // Silently handle error - not critical
      debugPrint('Error marking conversation as read: $e');
    }
  }

  Future<void> updateOnlineStatus(bool isOnline) async {
    if (_currentUserId == null) return;

    try {
      await _repository.updateParticipantOnlineStatus(_currentUserId!, isOnline);
    } catch (e) {
      // Silently handle error - not critical
      debugPrint('Error updating online status: $e');
    }
  }

  void setConversation(ChatConversation conversation) {
    _conversation = conversation;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
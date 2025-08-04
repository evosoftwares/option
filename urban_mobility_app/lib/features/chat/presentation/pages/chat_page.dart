import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/chat_conversation.dart';
import '../../data/models/chat_participant.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../../../../shared/widgets/empty_state.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;

  const ChatPage({
    super.key,
    required this.conversationId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  late ChatProvider _provider;
  late ScrollController _scrollController;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _provider = Provider.of<ChatProvider>(context, listen: false);
    WidgetsBinding.instance.addObserver(this);
    _loadChat();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _messageController.dispose();
    _provider.markConversationAsRead();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _provider.updateOnlineStatus(true);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        _provider.updateOnlineStatus(false);
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _loadChat() {
    const String currentUserId = 'current_user_id'; // TODO: Get from auth service
    _provider.loadConversation(widget.conversationId, currentUserId);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar conversa',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadChat,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (provider.conversation == null) {
            return const EmptyState(
              title: 'Conversa não encontrada',
              description: 'Esta conversa pode ter sido excluída.',
              icon: Icons.chat_bubble_outline,
            );
          }

          return Column(
            children: [
              Expanded(
                child: _buildMessagesList(provider),
              ),
              ChatInput(
                controller: _messageController,
                onSendMessage: _sendMessage,
                onSendLocation: _sendLocation,
                enabled: !provider.isSending,
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return Consumer<ChatProvider>(
      builder: (context, provider, child) {
        final conversation = provider.conversation;
        final otherParticipant = conversation?.getOtherParticipant('current_user_id');

        return AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          title: Row(
            children: [
              _buildParticipantAvatar(otherParticipant),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherParticipant?.name ?? 'Chat',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (otherParticipant != null)
                      Text(
                        _getParticipantStatus(otherParticipant),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.phone),
              onPressed: () {
                // TODO: Implementar chamada telefônica
                _showFeatureNotAvailable('Chamada telefônica');
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'view_profile':
                    // TODO: Ver perfil do participante
                    _showFeatureNotAvailable('Ver perfil');
                    break;
                  case 'block':
                    _showBlockDialog();
                    break;
                  case 'report':
                    // TODO: Reportar usuário
                    _showFeatureNotAvailable('Reportar usuário');
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view_profile',
                  child: Row(
                    children: [
                      Icon(Icons.person_outline),
                      SizedBox(width: 8),
                      Text('Ver perfil'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'block',
                  child: Row(
                    children: [
                      Icon(Icons.block_outlined),
                      SizedBox(width: 8),
                      Text('Bloquear usuário'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(Icons.report_outlined),
                      SizedBox(width: 8),
                      Text('Reportar usuário'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildParticipantAvatar(ChatParticipant? participant) {
    if (participant?.avatarUrl != null) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(participant!.avatarUrl!),
        onBackgroundImageError: (_, __) {},
        child: const Icon(Icons.person, size: 18),
      );
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor: participant?.role == ParticipantRole.driver
          ? Colors.blue.withOpacity(0.3)
          : Colors.green.withOpacity(0.3),
      child: Icon(
        participant?.role == ParticipantRole.driver
            ? Icons.directions_car
            : Icons.person,
        size: 18,
        color: Colors.white,
      ),
    );
  }

  String _getParticipantStatus(ChatParticipant participant) {
    if (participant.isOnline) {
      return 'Online';
    } else if (participant.lastSeenAt != null) {
      final now = DateTime.now();
      final difference = now.difference(participant.lastSeenAt!);
      
      if (difference.inMinutes < 60) {
        return 'Visto ${difference.inMinutes}min atrás';
      } else if (difference.inHours < 24) {
        return 'Visto ${difference.inHours}h atrás';
      } else {
        return 'Visto ${difference.inDays}d atrás';
      }
    }
    return 'Offline';
  }

  Widget _buildMessagesList(ChatProvider provider) {
    if (provider.messages.isEmpty) {
      return const EmptyState(
        title: 'Nenhuma mensagem ainda',
        description: 'Comece a conversa enviando uma mensagem.',
        icon: Icons.chat_bubble_outline,
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: provider.messages.length,
      itemBuilder: (context, index) {
        final message = provider.messages[index];
        final isMe = message.senderId == 'current_user_id'; // TODO: Get from auth service
        final showDate = _shouldShowDate(provider.messages, index);

        return Column(
          children: [
            if (showDate) _buildDateDivider(message.createdAt),
            MessageBubble(
              message: message,
              isMe: isMe,
              showSenderName: !isMe,
            ),
          ],
        );
      },
    );
  }

  bool _shouldShowDate(List<ChatMessage> messages, int index) {
    if (index == 0) return true;
    
    final current = messages[index].createdAt;
    final previous = messages[index - 1].createdAt;
    
    return current.day != previous.day ||
           current.month != previous.month ||
           current.year != previous.year;
  }

  Widget _buildDateDivider(DateTime date) {
    final now = DateTime.now();
    final isToday = date.day == now.day && 
                   date.month == now.month && 
                   date.year == now.year;
    
    final isYesterday = date.day == now.day - 1 && 
                       date.month == now.month && 
                       date.year == now.year;

    String dateText;
    if (isToday) {
      dateText = 'Hoje';
    } else if (isYesterday) {
      dateText = 'Ontem';
    } else {
      dateText = '${date.day}/${date.month}/${date.year}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              dateText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  void _sendMessage(String content) {
    if (content.trim().isEmpty) return;

    _provider.sendMessage(
      content: content.trim(),
      type: MessageType.text,
    );

    _messageController.clear();
    
    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _sendLocation() {
    // TODO: Implementar envio de localização
    _showFeatureNotAvailable('Envio de localização');
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bloquear usuário'),
        content: const Text(
          'Tem certeza que deseja bloquear este usuário? Você não receberá mais mensagens dele.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implementar bloqueio de usuário
              Navigator.pop(context);
              _showFeatureNotAvailable('Bloqueio de usuário');
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Bloquear'),
          ),
        ],
      ),
    );
  }

  void _showFeatureNotAvailable(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature ainda não está disponível'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}
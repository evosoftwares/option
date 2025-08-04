import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/chat_list_provider.dart';
import '../../data/models/chat_conversation.dart';
import '../widgets/conversation_tile.dart';
import '../../../../shared/widgets/empty_state.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late ChatListProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<ChatListProvider>(context, listen: false);
    _loadConversations();
  }

  void _loadConversations() {
    const String currentUserId = 'current_user_id'; // TODO: Get from auth service
    _provider.loadUserConversations(currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversas'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implementar busca de conversas
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'archived':
                  // TODO: Mostrar conversas arquivadas
                  break;
                case 'settings':
                  // TODO: Abrir configurações do chat
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'archived',
                child: Row(
                  children: [
                    Icon(Icons.archive_outlined),
                    SizedBox(width: 8),
                    Text('Conversas arquivadas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined),
                    SizedBox(width: 8),
                    Text('Configurações'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ChatListProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
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
                    'Erro ao carregar conversas',
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
                    onPressed: _loadConversations,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (provider.conversations.isEmpty) {
            return const EmptyState(
              title: 'Nenhuma conversa ainda',
              description:
                  'Suas conversas com motoristas e passageiros aparecerão aqui.',
              icon: Icons.chat_bubble_outline,
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadConversations(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: provider.conversations.length,
              itemBuilder: (context, index) {
                final conversation = provider.conversations[index];
                return ConversationTile(
                  conversation: conversation,
                  currentUserId: 'current_user_id', // TODO: Get from auth service
                  onTap: () => _openChat(conversation),
                  onLongPress: () => _showConversationOptions(conversation),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _openChat(ChatConversation conversation) {
    context.push('/chat/${conversation.id}');
  }

  void _showConversationOptions(ChatConversation conversation) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ConversationOptionsSheet(
        conversation: conversation,
        onArchive: () => _archiveConversation(conversation.id),
        onDelete: () => _deleteConversation(conversation.id),
      ),
    );
  }

  void _archiveConversation(String conversationId) {
    _provider.updateConversationStatus(conversationId, ConversationStatus.archived);
    Navigator.pop(context);
  }

  void _deleteConversation(String conversationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir conversa'),
        content: const Text(
          'Tem certeza que deseja excluir esta conversa? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _provider.deleteConversation(conversationId);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _ConversationOptionsSheet extends StatelessWidget {
  final ChatConversation conversation;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const _ConversationOptionsSheet({
    required this.conversation,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: const Text('Arquivar conversa'),
            onTap: onArchive,
          ),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Excluir conversa',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            onTap: onDelete,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/chat_conversation.dart';
import '../../data/models/chat_participant.dart';

class ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final String currentUserId;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final otherParticipant = conversation.getOtherParticipant(currentUserId);
    final unreadCount = conversation.getUnreadCountForUser(currentUserId);
    final hasUnread = unreadCount > 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildAvatar(otherParticipant),
        title: Row(
          children: [
            Expanded(
              child: Text(
                otherParticipant?.name ?? 'Usuário',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (conversation.lastMessageAt != null)
              Text(
                _formatMessageTime(conversation.lastMessageAt!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: hasUnread
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (otherParticipant != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    otherParticipant.role == ParticipantRole.driver
                        ? Icons.directions_car
                        : Icons.person,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    otherParticipant.role == ParticipantRole.driver
                        ? 'Motorista'
                        : 'Passageiro',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (otherParticipant.isOnline)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ],
            if (conversation.lastMessageContent != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (conversation.lastMessageSenderId == currentUserId)
                    Icon(
                      Icons.done_all,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      conversation.lastMessageContent!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: hasUnread
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: hasUnread
            ? _buildUnreadBadge(unreadCount, context)
            : const SizedBox.shrink(),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }

  Widget _buildAvatar(ChatParticipant? participant) {
    if (participant?.avatarUrl != null) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(participant!.avatarUrl!),
        onBackgroundImageError: (_, __) {},
        child: const Icon(Icons.person),
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: participant?.role == ParticipantRole.driver
          ? Colors.blue.withOpacity(0.2)
          : Colors.green.withOpacity(0.2),
      child: Icon(
        participant?.role == ParticipantRole.driver
            ? Icons.directions_car
            : Icons.person,
        color: participant?.role == ParticipantRole.driver
            ? Colors.blue
            : Colors.green,
      ),
    );
  }

  Widget _buildUnreadBadge(int count, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Hoje - mostrar hora
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      // Ontem
      return 'Ontem';
    } else if (difference.inDays < 7) {
      // Esta semana - mostrar dia da semana
      return DateFormat('EEEE', 'pt_BR').format(dateTime);
    } else if (dateTime.year == now.year) {
      // Este ano - mostrar dia e mês
      return DateFormat('dd/MM').format(dateTime);
    } else {
      // Outro ano - mostrar data completa
      return DateFormat('dd/MM/yy').format(dateTime);
    }
  }
}
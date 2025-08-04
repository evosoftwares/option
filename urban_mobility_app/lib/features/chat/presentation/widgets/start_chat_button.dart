import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/chat_list_provider.dart';

class StartChatButton extends StatelessWidget {
  final String rideId;
  final String driverId;
  final String driverName;
  final String passengerId;
  final String passengerName;
  final String buttonText;
  final IconData? icon;

  const StartChatButton({
    super.key,
    required this.rideId,
    required this.driverId,
    required this.driverName,
    required this.passengerId,
    required this.passengerName,
    this.buttonText = 'Iniciar conversa',
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatListProvider>(
      builder: (context, provider, child) {
        return ElevatedButton.icon(
          onPressed: provider.isLoading ? null : () => _startChat(context, provider),
          icon: provider.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon ?? Icons.chat_bubble_outline),
          label: Text(buttonText),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  Future<void> _startChat(BuildContext context, ChatListProvider provider) async {
    try {
      final conversation = await provider.createConversation(
        rideId: rideId,
        driverId: driverId,
        driverName: driverName,
        passengerId: passengerId,
        passengerName: passengerName,
      );

      if (context.mounted) {
        context.push('/chat/${conversation.id}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao iniciar conversa: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

class ContactDriverCard extends StatelessWidget {
  final String driverId;
  final String driverName;
  final String? driverPhone;
  final String rideId;
  final String passengerId;
  final String passengerName;

  const ContactDriverCard({
    super.key,
    required this.driverId,
    required this.driverName,
    this.driverPhone,
    required this.rideId,
    required this.passengerId,
    required this.passengerName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Contato com o motorista',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              driverName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StartChatButton(
                    rideId: rideId,
                    driverId: driverId,
                    driverName: driverName,
                    passengerId: passengerId,
                    passengerName: passengerName,
                    buttonText: 'Chat',
                    icon: Icons.chat_bubble_outline,
                  ),
                ),
                if (driverPhone != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implementar chamada telefônica
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Funcionalidade de chamada ainda não disponível'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Ligar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
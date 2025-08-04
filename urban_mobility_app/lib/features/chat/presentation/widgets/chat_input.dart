import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSendMessage,
    this.onSendLocation,
    this.enabled = true,
  });
  final TextEditingController controller;
  final Function(String) onSendMessage;
  final VoidCallback? onSendLocation;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (onSendLocation != null) ...[
              IconButton(
                onPressed: enabled ? onSendLocation : null,
                icon: const Icon(Icons.location_on_outlined),
                tooltip: 'Enviar localização',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Digite uma mensagem...',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: IconButton(
                        onPressed: enabled ? _showMoreOptions : null,
                        icon: const Icon(Icons.attach_file),
                        tooltip: 'Anexar arquivo',
                      ),
                    ),
                  ),
                  onSubmitted: enabled ? onSendMessage : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                final hasText = value.text.trim().isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: IconButton(
                    onPressed: enabled && hasText 
                        ? () => onSendMessage(controller.text) 
                        : null,
                    icon: Icon(
                      hasText ? Icons.send : Icons.mic,
                    ),
                    tooltip: hasText ? 'Enviar mensagem' : 'Gravar áudio',
                    style: IconButton.styleFrom(
                      backgroundColor: hasText 
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      foregroundColor: hasText 
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      disabledBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      disabledForegroundColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions() {
    // TODO: Implementar opções de anexo (imagem, documento, etc.)
  }
}
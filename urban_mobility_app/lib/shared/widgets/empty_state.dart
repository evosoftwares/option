import 'package:flutter/material.dart';

/// Componente reutilizável para estados de lista vazia.
/// Uso:
/// EmptyState(
///   title: 'Por enquanto nada aqui',
///   description: 'Quando houver itens, eles aparecerão nesta lista.',
///   icon: Icons.inbox_outlined, // opcional
///   actionLabel: 'Adicionar',   // opcional
///   onAction: () {},            // opcional
/// )
class EmptyState extends StatelessWidget {
  final String title;
  final String? description;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;
  final double spacing;
  final double iconSize;

  const EmptyState({
    super.key,
    this.title = 'Por enquanto nada aqui',
    this.description,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.padding,
    this.spacing = 12,
    this.iconSize = 56,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final resolvedPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 32);

    final onSurfaceVariant = cs.onSurface.withOpacity(0.7);

    return Padding(
      padding: resolvedPadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                CircleAvatar(
                  radius: iconSize / 2,
                  backgroundColor: cs.primary.withOpacity(0.08),
                  foregroundColor: cs.primary,
                  child: Icon(icon, size: iconSize * 0.6),
                ),
                SizedBox(height: spacing),
              ],
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                SizedBox(height: spacing * 1.5),
                ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

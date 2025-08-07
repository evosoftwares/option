////
/// Arquivo: Widget compartilhado EmptyState (camada shared/widgets)
///
/// Propósito:
/// - Exibir um estado vazio genérico e reutilizável com título, descrição,
///   ícone opcional e ação primária opcional.
///
/// Camadas/Dependências:
/// - Depende apenas de Flutter Material.
/// - Pode ser utilizado por qualquer feature sem acoplamento.
///
/// Responsabilidades:
/// - Layout responsivo/centralizado com largura máxima.
/// - Tratamento de props opcionais (ícone, descrição, ação).
///
/// Pontos de extensão:
/// - Suporte a múltiplas ações.
/// - Temas (cores, tipografia) herdados do Theme.
/// - Slots para conteúdo customizado (ex.: footer).
////
library;

import 'package:flutter/material.dart';

/// Componente reutilizável para estados de lista vazia.
///
/// Propriedades:
/// - [title]: título principal. Padrão: 'Por enquanto nada aqui'.
/// - [description]: texto descritivo opcional.
/// - [icon]: ícone opcional exibido no topo dentro de um avatar.
/// - [actionLabel]: rótulo do botão de ação primária (exibido se [onAction] != null).
/// - [onAction]: callback da ação; se nulo, o botão não é renderizado.
/// - [padding]: espaçamento externo; padrão simétrico horizontal 24 / vertical 32.
/// - [spacing]: espaçamento vertical entre blocos; padrão 12.
/// - [iconSize]: diâmetro do avatar (em px); padrão 56.
class EmptyStateComponent extends StatelessWidget {

  /// Construtor do EmptyStateComponent.
  ///
  /// Parâmetros:
  /// - [key]: chave do widget.
  /// - [title]: título principal (padrão amigável se não fornecido).
  /// - [description]: texto opcional abaixo do título.
  /// - [icon]: ícone opcional no topo.
  /// - [actionLabel]: rótulo do botão; só aparece se [onAction] não for nulo.
  /// - [onAction]: callback do botão primário.
  /// - [padding]: padding externo; se omitido, usa simétrico padrão.
  /// - [spacing]: espaçamento vertical entre elementos.
  /// - [iconSize]: diâmetro do círculo do ícone.
  const EmptyStateComponent({
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
  /// Título principal do estado vazio.
  final String title;

  /// Descrição opcional com detalhes adicionais.
  final String? description;

  /// Ícone opcional que reforça o contexto do vazio.
  final IconData? icon;

  /// Rótulo do botão de ação primária (requer [onAction]).
  final String? actionLabel;

  /// Callback acionado ao pressionar o botão (se definido).
  final VoidCallback? onAction;

  /// Padding externo do componente. Se nulo, usa um padrão confortável.
  final EdgeInsetsGeometry? padding;

  /// Espaçamento vertical entre os elementos internos.
  final double spacing;

  /// Tamanho base do ícone/avatares renderizados.
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Resolve padding padrão apenas se nenhum customizado for fornecido.
    final resolvedPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 32);

    // Cor de texto secundária derivada do onSurface (mantém contraste adequado).
    final onSurfaceVariant = cs.onSurface.withOpacity(0.7);

    return Padding(
      padding: resolvedPadding,
      child: Center(
        child: ConstrainedBox(
          // Largura máxima para melhorar legibilidade em telas grandes.
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                // Ícone dentro de um círculo com leve ênfase de cor do tema.
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

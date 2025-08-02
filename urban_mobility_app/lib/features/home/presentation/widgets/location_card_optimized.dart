////
/// LocationCardOptimized
///
/// Propósito:
/// - Exibir o status de localização usando um seletor otimizado para rebuilds.
///
/// Camadas/Dependências:
/// - Presentation (widget) que consome [`LocationServiceOptimized`](urban_mobility_app/lib/shared/services/location_service_optimized.dart).
///
/// Responsabilidades:
/// - Renderizar cabeçalho e conteúdo conforme estado (loading/erro/sucesso/inicial).
///
/// Pontos de extensão:
/// - Ação de retry, estilos e layout responsivo.
///
/// Notas:
/// - Usa Selector para reduzir rebuilds; sem lógica de navegação.
///
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/location_service_optimized.dart';

/// Card otimizado para exibição de localização atual do usuário.
class LocationCardOptimized extends StatelessWidget {
  /// Construtor padrão.
  const LocationCardOptimized({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<LocationServiceOptimized, LocationResult>(
      selector: (_, service) => service.state,
      builder: (context, locationState, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 12),
                _buildContent(context, locationState),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Cabeçalho com ícone e título.
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          'Sua Localização',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }

  /// Renderiza o conteúdo conforme o estado do serviço de localização.
  /// Efeitos colaterais: nenhum (apenas UI). Em caso de erro, expõe callback de retry.
  Widget _buildContent(BuildContext context, LocationResult state) {
    switch (state.status) {
      case LocationStatus.loading:
        return const _LoadingState();
      case LocationStatus.error:
      case LocationStatus.permissionDenied:
        return _ErrorState(
          error: state.error ?? 'Erro desconhecido',
          onRetry: () => context
              .read<LocationServiceOptimized>()
              .getCurrentPosition(forceRefresh: true),
        );
      case LocationStatus.success:
        return _SuccessState(address: state.address ?? 'Endereço não disponível');
      case LocationStatus.initial:
        return const _InitialState();
    }
  }
}

/// Estado visual de carregamento da localização.
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 12),
        Flexible(
          child: Text('Obtendo localização...'),
        ),
      ],
    );
  }
}

/// Estado visual de erro/permissão negada com ação de tentar novamente.
class _ErrorState extends StatelessWidget {
  /// Mensagem de erro legível ao usuário.
  final String error;

  /// Callback para solicitar localização novamente.
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          error,
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Tentar Novamente'),
        ),
      ],
    );
  }
}

/// Estado visual de sucesso mostrando o endereço atual.
class _SuccessState extends StatelessWidget {
  /// Endereço formatado.
  final String address;

  const _SuccessState({required this.address});

  @override
  Widget build(BuildContext context) {
    return Text(
      address,
      style: Theme.of(context).textTheme.bodyLarge,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );
  }
}

/// Estado inicial quando a localização ainda não foi solicitada.
class _InitialState extends StatelessWidget {
  const _InitialState();

  @override
  Widget build(BuildContext context) {
    return const Text('Localização não solicitada');
  }
}
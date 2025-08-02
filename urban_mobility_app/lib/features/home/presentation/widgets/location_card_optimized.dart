/* [Widget: LocationCard] Componente otimizado para exibição de localização */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/location_service_optimized.dart';

class LocationCardOptimized extends StatelessWidget {
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

  Widget _buildContent(BuildContext context, LocationResult state) {
    switch (state.status) {
      case LocationStatus.loading:
        return const _LoadingState();
      case LocationStatus.error:
      case LocationStatus.permissionDenied:
        return _ErrorState(
          error: state.error ?? 'Erro desconhecido',
          onRetry: () => context.read<LocationServiceOptimized>().getCurrentPosition(forceRefresh: true),
        );
      case LocationStatus.success:
        return _SuccessState(address: state.address ?? 'Endereço não disponível');
      case LocationStatus.initial:
        return const _InitialState();
    }
  }
}

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

class _ErrorState extends StatelessWidget {
  final String error;
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

class _SuccessState extends StatelessWidget {
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

class _InitialState extends StatelessWidget {
  const _InitialState();

  @override
  Widget build(BuildContext context) {
    return const Text('Localização não solicitada');
  }
}
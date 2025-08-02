////
/// Página de Mapa
///
/// Propósito:
/// - Exibir área do mapa (placeholder) com busca e ações de localização/direções.
///
/// Camadas/Dependências:
/// - Presentation da feature Map.
/// - Consome [`LocationService`](urban_mobility_app/lib/shared/services/location_service.dart) para localização atual.
///
/// Responsabilidades:
/// - Buscar locais por texto (mock) e apresentar feedback.
/// - Mostrar info da localização atual.
///
/// Pontos de extensão:
/// - Integração com Google Maps.
/// - Navegação para rotas/direções.
///
/// Notas:
/// - Mantém estado de busca local (_isSearching) e controller de texto.
///
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/location_service.dart';

/// Página principal do mapa.
class MapPage extends StatefulWidget {
  /// Construtor padrão.
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  /// Controller do campo de busca.
  final TextEditingController _searchController = TextEditingController();

  /// Flag de estado para exibir indicador de progresso na busca.
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              // Interação direta com o serviço para atualizar a posição atual.
              context.read<LocationService>().getCurrentPosition();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Placeholder para o mapa (Google Maps será integrado posteriormente)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[200],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Mapa será carregado aqui',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Google Maps em desenvolvimento',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          // Barra de busca
          Positioned(top: 16, left: 16, right: 16, child: _buildSearchBar()),

          // Informações da localização atual
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: _buildLocationInfo(),
          ),

          // Botões de ação flutuantes
          Positioned(bottom: 16, right: 16, child: _buildFloatingActions()),
        ],
      ),
    );
  }

  /// Barra de busca com indicador de progresso e limpeza.
  Widget _buildSearchBar() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Buscar endereço ou local...',
                  border: InputBorder.none,
                ),
                onSubmitted: _performSearch,
              ),
            ),
            if (_isSearching)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Card com informações da localização atual do usuário.
  /// Exibe endereço (se disponível) e coordenadas formatadas.
  Widget _buildLocationInfo() {
    return Consumer<LocationService>(
      builder: (context, locationService, child) {
        if (locationService.currentPosition == null) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Localização Atual',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (locationService.currentAddress != null)
                  Text(
                    locationService.currentAddress!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const SizedBox(height: 4),
                Text(
                  'Lat: ${locationService.currentPosition!.latitude.toStringAsFixed(6)}, '
                  'Lng: ${locationService.currentPosition!.longitude.toStringAsFixed(6)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Botões flutuantes para ações rápidas (direções e opções de transporte).
  Widget _buildFloatingActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "directions",
          onPressed: _showDirectionsDialog,
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.directions, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: "transport",
          onPressed: _showTransportOptions,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: const Icon(Icons.directions_bus, color: Colors.white),
        ),
      ],
    );
  }

  /// Executa uma busca textual por localizações.
  /// Parâmetros:
  /// - [query]: termo de busca.
  /// Retorno: Future<void>.
  /// Efeitos colaterais:
  /// - Atualiza estado local (_isSearching).
  /// - Exibe SnackBars para sucesso/erro.
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final locationService = context.read<LocationService>();
      final locations = await locationService.searchLocation(query);

      if (locations.isNotEmpty) {
        // Navegação futura pode ser adicionada aqui com o resultado.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Local encontrado: ${locations.first.latitude}, ${locations.first.longitude}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro na busca: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  /// Dialog informativo para futuras direções.
  void _showDirectionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Direções'),
        content: const Text(
          'Funcionalidade de direções será implementada em breve.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Bottom sheet com opções de transporte relacionadas ao mapa.
  void _showTransportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Opções de Transporte',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.directions_bus),
              title: const Text('Ônibus'),
              subtitle: const Text('Rotas de ônibus próximas'),
              onTap: () {
                Navigator.pop(context);
                // Implementar navegação para ônibus
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_subway),
              title: const Text('Metrô'),
              subtitle: const Text('Estações de metrô'),
              onTap: () {
                Navigator.pop(context);
                // Implementar navegação para metrô
              },
            ),
            ListTile(
              leading: const Icon(Icons.pedal_bike),
              title: const Text('Bicicleta'),
              subtitle: const Text('Estações de bike sharing'),
              onTap: () {
                Navigator.pop(context);
                // Implementar navegação para bicicletas
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose do controller de busca para evitar leaks.
    _searchController.dispose();
    super.dispose();
  }
}

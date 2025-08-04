import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../providers/passenger_map_provider.dart';
import '../../data/services/address_history_service.dart';
import '../../domain/models/address_history_item.dart';
import '../../../../shared/widgets/empty_state.dart';

/// Tela inicial do passageiro com Google Maps real e localização atual
/// Integra com dados reais de localização e geocodificação
class PassengerHomePage extends ConsumerStatefulWidget {
  const PassengerHomePage({super.key});

  @override
  ConsumerState<PassengerHomePage> createState() => _PassengerHomePageState();
}

class _PassengerHomePageState extends ConsumerState<PassengerHomePage> 
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final DraggableScrollableController _scrollController = DraggableScrollableController();
  late AnimationController _handleAnimationController;
  late Animation<double> _handleAnimation;

  // Estados do painel (similar ao Uber)
  static const double _minChildSize = 0.15; // Estado mínimo - só campo de busca
  static const double _initialChildSize = 0.25; // Estado inicial
  static const double _maxChildSize = 0.85; // Estado máximo expandido

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    
    // Configurar animação do handle
    _handleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _handleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _handleAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _handleAnimationController.dispose();
    super.dispose();
  }

  /// Solicita permissão de localização
  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      // Permissão concedida, o provider irá obter a localização automaticamente
    } else if (status.isDenied) {
      _showPermissionDialog();
    }
  }

  /// Mostra diálogo de permissão
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissão de Localização'),
        content: const Text(
          'Para uma melhor experiência, permita o acesso à sua localização.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Configurações'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Maps real
          _buildGoogleMap(),
          
          // Botão de localização atual
          _buildCurrentLocationButton(),
          
          // Bottom Sheet com interface de busca
          _buildBottomSheet(),
        ],
      ),
    );
  }

  /// Constrói o Google Maps
  Widget _buildGoogleMap() {
    final mapState = ref.watch(passengerMapProvider);

    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        ref.read(passengerMapProvider.notifier).setMapController(controller);
      },
      initialCameraPosition: mapState.cameraPosition,
      markers: mapState.markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: true,
      trafficEnabled: false,
      buildingsEnabled: true,
      indoorViewEnabled: true,
      mapType: MapType.normal,
      onTap: (LatLng position) {
        // Pode adicionar funcionalidade de tap no mapa aqui
      },
    );
  }

  /// Constrói o botão de localização atual
  Widget _buildCurrentLocationButton() {
    final mapState = ref.watch(passengerMapProvider);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: mapState.isLoading
                ? null
                : () {
                    ref.read(passengerMapProvider.notifier).updateCurrentLocation();
                  },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: mapState.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    )
                  : const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 24,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói o bottom sheet scrollable com interface similar ao Uber
  Widget _buildBottomSheet() {
    final mapState = ref.watch(passengerMapProvider);

    return DraggableScrollableSheet(
      controller: _scrollController,
      initialChildSize: _initialChildSize,
      minChildSize: _minChildSize,
      maxChildSize: _maxChildSize,
      snap: true,
      snapSizes: const [_minChildSize, _initialChildSize, _maxChildSize],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // Header fixo com handle e campo de busca
              SliverToBoxAdapter(
                child: _buildFixedHeader(mapState),
              ),
              
              // Conteúdo scrollable
              SliverToBoxAdapter(
                child: _buildScrollableContent(mapState),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Constrói o header fixo que sempre aparece (handle + campo de busca)
  Widget _buildFixedHeader(dynamic mapState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          // Handle animado
          _buildAnimatedHandle(),
          
          const SizedBox(height: 16),
          
          // Mensagem de erro se houver (sempre visível)
          if (mapState.error != null) _buildErrorMessage(mapState.error!),
          
          // Campo de busca principal (sempre visível)
          _buildSearchBar(),
        ],
      ),
    );
  }

  /// Constrói o conteúdo scrollable que aparece quando expandido
  Widget _buildScrollableContent(dynamic mapState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          
          // Informações da localização atual
          if (mapState.currentLocation != null) 
            _buildCurrentLocationInfo(mapState.currentLocation!),
          
          const SizedBox(height: 16),
          
          // Histórico de endereços
          _buildAddressHistory(),
          
          // Espaço extra para scroll
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  /// Constrói a mensagem de erro
  Widget _buildErrorMessage(String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(passengerMapProvider.notifier).clearError();
            },
            icon: Icon(
              Icons.close,
              color: Colors.red.shade600,
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// Constrói as informações da localização atual
  Widget _buildCurrentLocationInfo(dynamic currentLocation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.my_location,
            color: Colors.blue.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Localização atual',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  currentLocation.fullAddress ?? 'Endereço não disponível',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a alça animada do bottom sheet
  Widget _buildAnimatedHandle() {
    return AnimatedBuilder(
      animation: _handleAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          width: 48,
          height: 6,
          decoration: BoxDecoration(
            color: Color.lerp(
              const Color(0xFFD1D5DB),
              const Color(0xFF9CA3AF),
              _handleAnimation.value,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      },
    );
  }

  /// Constrói a barra de pesquisa principal
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          const Icon(
            Icons.location_on,
            color: Color(0xFF374151),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
              decoration: const InputDecoration(
                hintText: 'Para onde vamos?',
                hintStyle: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.normal,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a seção de histórico de endereços
  Widget _buildAddressHistory() {
    final addressHistoryService = AddressHistoryService();
    
    return StreamBuilder<List<AddressHistoryItem>>(
      stream: addressHistoryService.getAddressHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Erro ao carregar histórico: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final historyItems = snapshot.data ?? [];

        if (historyItems.isEmpty) {
          return const EmptyState(
            title: 'Nenhum local recente',
            description: 'Seus destinos recentes aparecerão aqui para facilitar o acesso.',
            icon: Icons.history,
            padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Locais recentes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            ...historyItems.map((item) => _buildHistoryItem(item)),
          ],
        );
      },
    );
  }

  /// Constrói um item do histórico de endereços
  Widget _buildHistoryItem(AddressHistoryItem item) {
    return InkWell(
      onTap: () {
        // TODO: Implementar seleção do endereço do histórico
        _searchController.text = item.address;
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFE5E7EB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history,
                color: Color(0xFF374151),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.shortName ?? item.address,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.shortName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.address,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Text(
              '${item.usageCount}x',
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }


}
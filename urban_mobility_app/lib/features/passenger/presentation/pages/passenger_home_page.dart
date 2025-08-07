import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../providers/passenger_map_provider.dart';
import '../components/passenger_bottom_sheet_component.dart';

/// Tela inicial do passageiro com Google Maps real e localização atual
/// Integra com dados reais de localização e geocodificação
class PassengerHomePage extends ConsumerStatefulWidget {
  const PassengerHomePage({super.key});

  @override
  ConsumerState<PassengerHomePage> createState() => _PassengerHomePageState();
}

class _PassengerHomePageState extends ConsumerState<PassengerHomePage> {
  Prediction? _selectedDestination;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
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

  /// Mostra diálogo de permissão melhorado com retry automático
  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Semantics(
        label: 'Diálogo de permissão de localização',
        child: AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.location_on,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text('Permissão de Localização'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Para uma melhor experiência, permita o acesso à sua localização.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Isso nos ajuda a mostrar sua posição atual e destinos próximos.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Semantics(
              label: 'Cancelar permissão',
              button: true,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ),
            Semantics(
              label: 'Tentar novamente a permissão',
              button: true,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _retryLocationPermission();
                },
                child: const Text('Tentar Novamente'),
              ),
            ),
            Semantics(
              label: 'Abrir configurações do app',
              button: true,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: const Text('Configurações'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Retry automático de permissão de localização
  Future<void> _retryLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      // Atualiza a localização após permissão concedida
      ref.read(passengerMapProvider.notifier).updateCurrentLocation();

      // Mostra feedback positivo
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Localização ativada com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else if (status.isPermanentlyDenied) {
      // Mostra diálogo para ir às configurações
      if (mounted) {
        _showPermanentlyDeniedDialog();
      }
    } else {
      // Permissão ainda negada, mas não permanentemente
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Permissão de localização necessária para usar o app',
            ),
            action: SnackBarAction(
              label: 'Tentar Novamente',
              onPressed: _retryLocationPermission,
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Diálogo quando permissão foi negada permanentemente
  void _showPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => Semantics(
        label: 'Diálogo de permissão negada permanentemente',
        child: AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              const Text('Permissão Negada'),
            ],
          ),
          content: const Text(
            'A permissão de localização foi negada permanentemente. '
            'Para usar este recurso, você precisa ativar manualmente nas configurações do seu dispositivo.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendi'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Abrir Configurações'),
            ),
          ],
        ),
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

          // Logotipo no canto superior esquerdo
          _buildLogo(),

          // Botão de localização atual
          _buildCurrentLocationButton(),

          // Botão para acessar sessão do motorista
          _buildDriverModeButton(),

          // Bottom Sheet com interface de busca
          PassengerBottomSheetComponent(
            onDestinationSelected: (prediction) {
              setState(() {
                _selectedDestination = prediction;
              });

              // Log da seleção (pode ser removido em produção)
              debugPrint('Destino selecionado: ${prediction.description}');
              debugPrint('Coordenadas: ${prediction.lat}, ${prediction.lng}');
            },
          ),
        ],
      ),
    );
  }

  /// Constrói o Google Maps com lazy loading otimizado
  Widget _buildGoogleMap() {
    return Consumer(
      builder: (context, ref, child) {
        // Lazy loading - só acessa o provider quando necessário
        final cameraPosition = ref.watch(
          passengerMapProvider.select((state) => state.cameraPosition),
        );
        final markers = ref.watch(
          passengerMapProvider.select((state) => state.markers),
        );

        return GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            // Async para não bloquear a UI
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(passengerMapProvider.notifier)
                  .setMapController(controller);
            });
          },
          initialCameraPosition: cameraPosition,
          markers: markers,
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
      },
    );
  }

  /// Constrói o botão de localização atual com melhor tratamento de erro
  Widget _buildCurrentLocationButton() {
    return Consumer(
      builder: (context, ref, child) {
        // Seletor específico - só reconstrói quando necessário
        final isLoading = ref.watch(
          passengerMapProvider.select((state) => state.isLoading),
        );
        final error = ref.watch(
          passengerMapProvider.select((state) => state.error),
        );
        final isUpdateInProgress = ref.watch(
          passengerMapProvider.select(
            (state) => state.isLocationUpdateInProgress,
          ),
        );

        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          right: 16,
          child: RepaintBoundary(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFE),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 12,
                    offset: Offset(0, 3),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Semantics(
                  label: (isLoading || isUpdateInProgress)
                      ? 'Atualizando localização atual'
                      : 'Ir para localização atual',
                  button: true,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: (isLoading || isUpdateInProgress)
                        ? null
                        : _updateLocationWithDebounce,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: (isLoading || isUpdateInProgress)
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue,
                                  ),
                                ),
                              )
                            : Icon(
                                error != null
                                    ? Icons.location_off
                                    : Icons.my_location,
                                color: error != null
                                    ? Colors.red.shade600
                                    : Colors.blue,
                                size: 24,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Atualiza localização com debounce e retry
  void _updateLocationWithDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _updateLocationWithRetry();
    });
  }

  /// Atualiza localização com retry automático
  Future<void> _updateLocationWithRetry() async {
    try {
      await ref.read(passengerMapProvider.notifier).updateCurrentLocation();

      // Feedback positivo se sucesso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Localização atualizada!'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Em caso de erro, oferece retry
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao atualizar localização'),
            action: SnackBarAction(
              label: 'Tentar Novamente',
              onPressed: _updateLocationWithRetry,
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Constrói o botão para acessar a sessão do motorista
  Widget _buildDriverModeButton() {
    return Positioned(
      top:
          MediaQuery.of(context).padding.top +
          80, // Abaixo do botão de localização
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.orange.shade600,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _navigateToDriverMode(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(Icons.drive_eta, color: Colors.white, size: 24),
            ),
          ),
        ),
      ),
    );
  }

  /// Navega para o modo motorista usando GoRouter
  void _navigateToDriverMode() {
    debugPrint('🚗 Navegando para modo motorista...');
    context.go('/driver');
  }

  /// Constrói o logotipo no canto superior esquerdo
  Widget _buildLogo() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      child: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 12,
                offset: Offset(0, 3),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Semantics(
              label: 'Logotipo Option Brasil Transportes',
              image: true,
              child: Image.asset(
                'assets/images/logo_option.png',
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback em caso de erro ao carregar a imagem
                  return Container(
                    height: 40,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'OPTION',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../providers/pickup_location_provider.dart';
import '../widgets/location_pin_widget.dart';
import '../widgets/my_location_button.dart';
import '../widgets/bottom_pickup_panel.dart';
import '../widgets/address_search_sheet.dart';

class ConfirmPickupScreen extends ConsumerStatefulWidget {
  const ConfirmPickupScreen({super.key});

  @override
  ConsumerState<ConfirmPickupScreen> createState() => _ConfirmPickupScreenState();
}

class _ConfirmPickupScreenState extends ConsumerState<ConfirmPickupScreen>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _pinAnimationController;
  late Animation<double> _pinAnimation;

  @override
  void initState() {
    super.initState();
    
    // Inicializar animação do pin
    _pinAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pinAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _pinAnimationController,
      curve: Curves.easeInOut,
    ));

    // Inicializar localização após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pickupLocationProvider.notifier).initializeLocation();
    });
  }

  @override
  void dispose() {
    _pinAnimationController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    ref.read(pickupLocationProvider.notifier).setMapController(controller);
  }

  void _onCameraMove(CameraPosition position) {
    ref.read(pickupLocationProvider.notifier).onCameraMove();
    if (!_pinAnimationController.isAnimating) {
      _pinAnimationController.forward();
    }
  }

  void _onCameraIdle() {
    ref.read(pickupLocationProvider.notifier).onCameraIdle();
    _pinAnimationController.reverse();
  }

  void _onMyLocationPressed() {
    ref.read(pickupLocationProvider.notifier).moveToCurrentLocation();
  }

  void _onSearchPressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddressSearchSheet(
        onAddressSelected: (location) {
          // Implementar navegação para a localização selecionada
          Navigator.pop(context);
        },
      ),
    );
  }

  void _onConfirmPickup() {
    final state = ref.read(pickupLocationProvider);
    
    if (state.currentLocation == null) {
      _showErrorSnackBar('Por favor, aguarde a localização ser carregada');
      return;
    }

    if (state.isLoadingAddress) {
      _showErrorSnackBar('Aguarde o endereço ser carregado');
      return;
    }

    // Aqui você pode navegar para a próxima tela ou processar a confirmação
    _showSnackBar('Local confirmado: ${state.currentLocation!.fullAddress}');
    
    // Exemplo de navegação:
    // Navigator.pushNamed(context, '/driver-selection', arguments: state.currentLocation);
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pickupLocationProvider);

    // Mostrar erro se houver
    ref.listen<PickupLocationState>(pickupLocationProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        _showErrorSnackBar(next.errorMessage!);
        // Limpar erro após mostrar
        Future.delayed(const Duration(seconds: 1), () {
          ref.read(pickupLocationProvider.notifier).clearError();
        });
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Google Maps
          GoogleMap(
            initialCameraPosition: PickupLocationNotifier.initialCameraPosition,
            onMapCreated: _onMapCreated,
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: state.hasLocationPermission,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            zoomGesturesEnabled: true,
            // Estilo do mapa (opcional)
            mapType: MapType.normal,
          ),

          // Pin centralizado com animação
          Align(
            alignment: Alignment.center,
            child: AnimatedBuilder(
              animation: _pinAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_pinAnimation.value),
                  child: LocationPinWidget(
                    isMoving: state.isMapMoving,
                  ),
                );
              },
            ),
          ),

          // Botão de localização atual
          Positioned(
            right: 16,
            bottom: 280,
            child: MyLocationButton(
              onPressed: _onMyLocationPressed,
              isLoading: state.isLoadingAddress,
            ),
          ),

          // Painel inferior
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomPickupPanel(
              currentAddress: state.currentAddress,
              fullAddress: state.currentLocation?.fullAddress ?? '',
              isLoadingAddress: state.isLoadingAddress,
              isMapMoving: state.isMapMoving,
              onSearchPressed: _onSearchPressed,
              onConfirmPressed: _onConfirmPickup,
            ),
          ),

          // Indicador de loading global (se necessário)
          if (state.isLoadingAddress && state.currentLocation == null)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Obtendo sua localização...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
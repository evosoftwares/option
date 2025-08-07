import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../domain/models/active_trip.dart';
import '../../domain/models/trip_status.dart';
import '../providers/trip_management_provider.dart';
import '../widgets/trip_info_card.dart';
import '../widgets/trip_actions_panel.dart';

/// Tela de gerenciamento de viagem ativa
class TripManagementPage extends StatefulWidget {
  const TripManagementPage({super.key, required this.tripId});

  final String tripId;

  @override
  State<TripManagementPage> createState() => _TripManagementPageState();
}

class _TripManagementPageState extends State<TripManagementPage> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripManagementProvider>().loadTrip(widget.tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        title: const Text('Viagem em Andamento'),
        backgroundColor: DesignTokens.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Botão de emergência
          IconButton(
            icon: const Icon(Icons.emergency, color: Colors.red),
            onPressed: () => _showEmergencyDialog(),
          ),
          // Botão de suporte
          IconButton(
            icon: const Icon(Icons.support_agent),
            onPressed: () => _contactSupport(),
          ),
        ],
      ),
      body: Consumer<TripManagementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.activeTrip == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.activeTrip == null) {
            return const Center(child: Text('Viagem não encontrada'));
          }

          final trip = provider.activeTrip!;

          return Column(
            children: [
              // Mapa
              Expanded(flex: 3, child: _buildMap(trip, provider)),

              // Informações da viagem
              Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(DesignTokens.radiusLg),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle
                      Container(
                        margin: const EdgeInsets.only(
                          top: DesignTokens.spaceSm,
                        ),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: DesignTokens.textMuted,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Conteúdo
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(DesignTokens.spaceMd),
                          child: Column(
                            children: [
                              // Card de informações da viagem
                              TripInfoCard(trip: trip),

                              const SizedBox(height: DesignTokens.spaceMd),

                              // Painel de ações
                              TripActionsPanel(
                                trip: trip,
                                onAction: (action) =>
                                    _handleTripAction(action, provider),
                                isLoading: provider.isLoading,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMap(ActiveTrip trip, TripManagementProvider provider) {
    return GoogleMap(
      onMapCreated: (controller) {
        _mapController = controller;
        _updateMapView(trip);
      },
      initialCameraPosition: CameraPosition(
        target: trip.pickupLocation,
        zoom: 15,
      ),
      markers: _buildMarkers(trip),
      polylines: provider.routePolylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }

  Set<Marker> _buildMarkers(ActiveTrip trip) {
    final markers = <Marker>{};

    // Marcador de origem
    markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: trip.pickupLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Local de Embarque',
          snippet: trip.pickupAddress,
        ),
      ),
    );

    // Marcador de destino
    markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: trip.destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Destino',
          snippet: trip.destinationAddress,
        ),
      ),
    );

    return markers;
  }

  void _updateMapView(ActiveTrip trip) {
    if (_mapController == null) return;

    // Ajusta a câmera para mostrar origem e destino
    final bounds = LatLngBounds(
      southwest: LatLng(
        trip.pickupLocation.latitude < trip.destination.latitude
            ? trip.pickupLocation.latitude
            : trip.destination.latitude,
        trip.pickupLocation.longitude < trip.destination.longitude
            ? trip.pickupLocation.longitude
            : trip.destination.longitude,
      ),
      northeast: LatLng(
        trip.pickupLocation.latitude > trip.destination.latitude
            ? trip.pickupLocation.latitude
            : trip.destination.latitude,
        trip.pickupLocation.longitude > trip.destination.longitude
            ? trip.pickupLocation.longitude
            : trip.destination.longitude,
      ),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  void _handleTripAction(String action, TripManagementProvider provider) {
    switch (action) {
      case 'arrived_pickup':
        provider.markArrivedAtPickup();
        break;
      case 'start_trip':
        provider.startTrip();
        break;
      case 'arrived_destination':
        provider.markArrivedAtDestination();
        break;
      case 'complete_trip':
        _showCompleteTripDialog(provider);
        break;
      case 'cancel_trip':
        _showCancelTripDialog(provider);
        break;
      case 'call_passenger':
        _callPassenger(provider.activeTrip!.passengerPhone);
        break;
      case 'navigate':
        _openNavigation(provider.activeTrip!);
        break;
    }
  }

  void _showCompleteTripDialog(TripManagementProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Viagem'),
        content: const Text(
          'Confirma que o passageiro chegou ao destino e desembarcou?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.completeTrip();
              // Navegar para tela de avaliação
              _navigateToRating();
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  void _showCancelTripDialog(TripManagementProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Viagem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selecione o motivo do cancelamento:'),
            const SizedBox(height: DesignTokens.spaceMd),
            // Lista de motivos
            ...[
              'Passageiro não apareceu',
              'Problema no veículo',
              'Emergência',
              'Outro',
            ].map(
              (reason) => ListTile(
                title: Text(reason),
                onTap: () {
                  Navigator.of(context).pop();
                  provider.cancelTrip(reason);
                  Navigator.of(context).pop(); // Volta para tela principal
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Colors.red),
            SizedBox(width: 8),
            Text('Emergência'),
          ],
        ),
        content: const Text(
          'Em caso de emergência, ligue imediatamente para:\n\n'
          '• Polícia: 190\n'
          '• SAMU: 192\n'
          '• Bombeiros: 193\n\n'
          'Ou entre em contato com nosso suporte 24h.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _callEmergency();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ligar 190'),
          ),
        ],
      ),
    );
  }

  void _callPassenger(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _callEmergency() async {
    final uri = Uri.parse('tel:190');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _contactSupport() async {
    final uri = Uri.parse('tel:08006000000'); // Número fictício
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openNavigation(ActiveTrip trip) async {
    final destination = trip.status == TripStatus.goingToPickup
        ? trip.pickupLocation
        : trip.destination;

    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _navigateToRating() {
    // TODO: Implementar navegação para tela de avaliação
    Navigator.of(context).pushReplacementNamed('/driver/rating');
  }
}

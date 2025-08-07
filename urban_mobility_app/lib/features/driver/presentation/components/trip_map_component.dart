import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../domain/models/active_trip.dart';
import '../../domain/models/trip_status.dart';

/// Componente complexo para exibir o mapa da viagem
class TripMapComponent extends StatefulWidget {
  const TripMapComponent({
    super.key,
    required this.trip,
    required this.currentLocation,
    this.polylines = const {},
    this.onMapCreated,
    this.onLocationUpdate,
  });

  final ActiveTrip trip;
  final LatLng currentLocation;
  final Set<Polyline> polylines;
  final Function(GoogleMapController)? onMapCreated;
  final Function(LatLng)? onLocationUpdate;

  @override
  State<TripMapComponent> createState() => _TripMapComponentState();
}

class _TripMapComponentState extends State<TripMapComponent>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: Stack(
          children: [
            // Mapa principal
            _buildGoogleMap(),

            // Overlay de informações
            _buildMapOverlay(),

            // Botões de controle
            _buildMapControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        widget.onMapCreated?.call(controller);
        _fitMapToRoute();
      },
      initialCameraPosition: CameraPosition(
        target: widget.currentLocation,
        zoom: 15.0,
      ),
      markers: _buildMarkers(),
      polylines: widget.polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: true,
      trafficEnabled: true,
      buildingsEnabled: true,
      onCameraMove: (CameraPosition position) {
        widget.onLocationUpdate?.call(position.target);
      },
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // Marcador do motorista (localização atual)
    markers.add(
      Marker(
        markerId: const MarkerId('driver_location'),
        position: widget.currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
          title: 'Sua Localização',
          snippet: 'Motorista',
        ),
      ),
    );

    // Marcador de origem (pickup)
    markers.add(
      Marker(
        markerId: const MarkerId('pickup_location'),
        position: widget.trip.pickupLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Local de Embarque',
          snippet: widget.trip.pickupAddress,
        ),
      ),
    );

    // Marcador de destino
    markers.add(
      Marker(
        markerId: const MarkerId('destination_location'),
        position: widget.trip.destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Destino',
          snippet: widget.trip.destinationAddress,
        ),
      ),
    );

    return markers;
  }

  Widget _buildMapOverlay() {
    return Positioned(
      top: DesignTokens.spaceMd,
      left: DesignTokens.spaceMd,
      right: DesignTokens.spaceMd,
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícone de status com animação
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(
                      0.1 + (_pulseAnimation.value * 0.2),
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getStatusColor().withOpacity(
                        0.3 + (_pulseAnimation.value * 0.4),
                      ),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                    size: DesignTokens.iconMd,
                  ),
                );
              },
            ),

            const SizedBox(width: DesignTokens.spaceMd),

            // Informações de status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.trip.status.displayName,
                    style: DesignTokens.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getStatusDescription(),
                    style: DesignTokens.bodySmall.copyWith(
                      color: DesignTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Tempo estimado
            if (_getEstimatedTime() != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceSm,
                  vertical: DesignTokens.space2xs,
                ),
                decoration: BoxDecoration(
                  color: DesignTokens.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: Text(
                  _getEstimatedTime()!,
                  style: DesignTokens.labelSmall.copyWith(
                    color: DesignTokens.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      bottom: DesignTokens.spaceMd,
      right: DesignTokens.spaceMd,
      child: Column(
        children: [
          // Botão de centralizar no motorista
          FloatingActionButton.small(
            onPressed: _centerOnDriver,
            backgroundColor: Colors.white,
            foregroundColor: DesignTokens.primaryBlue,
            child: const Icon(Icons.my_location),
          ),

          const SizedBox(height: DesignTokens.spaceSm),

          // Botão de ajustar rota
          FloatingActionButton.small(
            onPressed: _fitMapToRoute,
            backgroundColor: Colors.white,
            foregroundColor: DesignTokens.primaryBlue,
            child: const Icon(Icons.zoom_out_map),
          ),
        ],
      ),
    );
  }

  void _centerOnDriver() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: widget.currentLocation,
          zoom: 17.0,
          bearing: 0,
          tilt: 0,
        ),
      ),
    );
  }

  void _fitMapToRoute() {
    if (_mapController == null) return;

    final bounds = _calculateBounds();
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100.0));
  }

  LatLngBounds _calculateBounds() {
    final points = [
      widget.currentLocation,
      widget.trip.pickupLocation,
      widget.trip.destination,
    ];

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Color _getStatusColor() {
    switch (widget.trip.status) {
      case TripStatus.goingToPickup:
        return DesignTokens.primaryBlue;
      case TripStatus.arrivedAtPickup:
      case TripStatus.waitingPassenger:
        return DesignTokens.warningOrange;
      case TripStatus.onTrip:
        return DesignTokens.successGreen;
      case TripStatus.arrivedAtDestination:
        return DesignTokens.infoBlue;
      default:
        return DesignTokens.textSecondary;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.trip.status) {
      case TripStatus.goingToPickup:
        return Icons.directions_car;
      case TripStatus.arrivedAtPickup:
        return Icons.location_on;
      case TripStatus.waitingPassenger:
        return Icons.person_add;
      case TripStatus.onTrip:
        return Icons.navigation;
      case TripStatus.arrivedAtDestination:
        return Icons.flag;
      default:
        return Icons.info;
    }
  }

  String _getStatusDescription() {
    switch (widget.trip.status) {
      case TripStatus.goingToPickup:
        return 'Navegando até ${widget.trip.passengerName}';
      case TripStatus.arrivedAtPickup:
        return 'Aguardando ${widget.trip.passengerName}';
      case TripStatus.waitingPassenger:
        return '${widget.trip.passengerName} está entrando';
      case TripStatus.onTrip:
        return 'Viagem em andamento';
      case TripStatus.arrivedAtDestination:
        return 'Chegou ao destino';
      default:
        return widget.trip.status.description;
    }
  }

  String? _getEstimatedTime() {
    switch (widget.trip.status) {
      case TripStatus.goingToPickup:
        return '${widget.trip.estimatedDuration.inMinutes} min';
      case TripStatus.onTrip:
        return '${widget.trip.estimatedDuration.inMinutes} min';
      default:
        return null;
    }
  }
}

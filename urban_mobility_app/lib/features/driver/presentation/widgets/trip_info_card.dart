import 'package:flutter/material.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../domain/models/active_trip.dart';
import '../../domain/models/trip_status.dart';

/// Card com informações da viagem ativa
class TripInfoCard extends StatelessWidget {
  const TripInfoCard({super.key, required this.trip});

  final ActiveTrip trip;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status da viagem
            _buildStatusHeader(),

            const SizedBox(height: DesignTokens.spaceMd),

            // Informações do passageiro
            _buildPassengerInfo(),

            const SizedBox(height: DesignTokens.spaceMd),

            // Detalhes da viagem
            _buildTripDetails(),

            const SizedBox(height: DesignTokens.spaceMd),

            // Informações de tempo e preço
            _buildTimeAndPrice(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceMd,
        vertical: DesignTokens.spaceSm,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: _getStatusColor().withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: DesignTokens.iconMd,
          ),
          const SizedBox(width: DesignTokens.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.status.displayName,
                  style: DesignTokens.labelLarge.copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  trip.status.description,
                  style: DesignTokens.bodySmall.copyWith(
                    color: DesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerInfo() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceMd),
      decoration: BoxDecoration(
        color: DesignTokens.backgroundLight,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      child: Row(
        children: [
          // Avatar do passageiro
          CircleAvatar(
            radius: 24,
            backgroundColor: DesignTokens.primaryBlue,
            child: Text(
              trip.passengerName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(width: DesignTokens.spaceMd),

          // Informações do passageiro
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.passengerName,
                  style: DesignTokens.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: DesignTokens.space2xs),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: DesignTokens.warningOrange,
                      size: 16,
                    ),
                    const SizedBox(width: DesignTokens.space2xs),
                    Text(
                      trip.passengerRating.toStringAsFixed(1),
                      style: DesignTokens.bodySmall.copyWith(
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spaceSm),
                    Icon(
                      Icons.payment,
                      color: DesignTokens.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: DesignTokens.space2xs),
                    Text(
                      trip.paymentMethod,
                      style: DesignTokens.bodySmall.copyWith(
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetails() {
    return Column(
      children: [
        // Origem
        _buildLocationRow(
          icon: Icons.radio_button_checked,
          iconColor: DesignTokens.successGreen,
          title: 'Embarque',
          address: trip.pickupAddress,
        ),

        const SizedBox(height: DesignTokens.spaceSm),

        // Linha conectora
        Container(
          margin: const EdgeInsets.only(left: 12),
          width: 2,
          height: 20,
          color: DesignTokens.textMuted,
        ),

        const SizedBox(height: DesignTokens.spaceSm),

        // Destino
        _buildLocationRow(
          icon: Icons.location_on,
          iconColor: DesignTokens.errorRed,
          title: 'Destino',
          address: trip.destinationAddress,
        ),
      ],
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: DesignTokens.iconMd),
        const SizedBox(width: DesignTokens.spaceSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: DesignTokens.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: DesignTokens.space2xs),
              Text(
                address,
                style: DesignTokens.bodySmall.copyWith(
                  color: DesignTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeAndPrice() {
    return Row(
      children: [
        // Tempo
        Expanded(
          child: _buildInfoItem(
            icon: Icons.access_time,
            label: 'Tempo',
            value: trip.formattedDuration,
          ),
        ),

        // Distância
        Expanded(
          child: _buildInfoItem(
            icon: Icons.straighten,
            label: 'Distância',
            value: trip.formattedDistance,
          ),
        ),

        // Preço
        Expanded(
          child: _buildInfoItem(
            icon: Icons.attach_money,
            label: 'Valor',
            value: trip.formattedPrice,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: DesignTokens.primaryBlue, size: DesignTokens.iconMd),
        const SizedBox(height: DesignTokens.space2xs),
        Text(
          label,
          style: DesignTokens.bodySmall.copyWith(
            color: DesignTokens.textSecondary,
          ),
        ),
        const SizedBox(height: DesignTokens.space2xs),
        Text(
          value,
          style: DesignTokens.labelMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (trip.status) {
      case TripStatus.waiting:
        return DesignTokens.textSecondary;
      case TripStatus.goingToPickup:
        return DesignTokens.primaryBlue;
      case TripStatus.arrivedAtPickup:
        return DesignTokens.warningOrange;
      case TripStatus.waitingPassenger:
        return DesignTokens.warningOrange;
      case TripStatus.onTrip:
        return DesignTokens.successGreen;
      case TripStatus.arrivedAtDestination:
        return DesignTokens.infoBlue;
      case TripStatus.waitingPayment:
        return DesignTokens.warningOrange;
      case TripStatus.completed:
        return DesignTokens.successGreen;
      case TripStatus.cancelled:
        return DesignTokens.errorRed;
    }
  }

  IconData _getStatusIcon() {
    switch (trip.status) {
      case TripStatus.waiting:
        return Icons.hourglass_empty;
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
      case TripStatus.waitingPayment:
        return Icons.payment;
      case TripStatus.completed:
        return Icons.check_circle;
      case TripStatus.cancelled:
        return Icons.cancel;
    }
  }
}

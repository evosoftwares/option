import 'package:flutter/material.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../domain/models/active_trip.dart';
import '../../domain/models/trip_status.dart';

/// Painel de ações para gerenciamento da viagem
class TripActionsPanel extends StatelessWidget {
  const TripActionsPanel({
    super.key,
    required this.trip,
    required this.onMarkArrival,
    required this.onStartTrip,
    required this.onCompleteTrip,
    required this.onCancelTrip,
    required this.onEmergency,
    required this.onSupport,
    required this.onNavigate,
  });

  final ActiveTrip trip;
  final VoidCallback onMarkArrival;
  final VoidCallback onStartTrip;
  final VoidCallback onCompleteTrip;
  final VoidCallback onCancelTrip;
  final VoidCallback onEmergency;
  final VoidCallback onSupport;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusLg),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador de arrastar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: DesignTokens.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: DesignTokens.spaceLg),

          // Ações principais baseadas no status
          _buildPrimaryActions(),

          const SizedBox(height: DesignTokens.spaceMd),

          // Ações secundárias
          _buildSecondaryActions(),
        ],
      ),
    );
  }

  Widget _buildPrimaryActions() {
    switch (trip.status) {
      case TripStatus.goingToPickup:
        return Column(
          children: [
            _buildPrimaryButton(
              label: 'Cheguei ao Local',
              icon: Icons.location_on,
              onPressed: onMarkArrival,
              color: DesignTokens.primaryBlue,
            ),
            const SizedBox(height: DesignTokens.spaceSm),
            _buildNavigateButton(),
          ],
        );

      case TripStatus.arrivedAtPickup:
      case TripStatus.waitingPassenger:
        return Column(
          children: [
            _buildPrimaryButton(
              label: 'Iniciar Viagem',
              icon: Icons.play_arrow,
              onPressed: onStartTrip,
              color: DesignTokens.successGreen,
            ),
            const SizedBox(height: DesignTokens.spaceSm),
            _buildSecondaryButton(
              label: 'Passageiro não apareceu',
              icon: Icons.person_off,
              onPressed: onCancelTrip,
              color: DesignTokens.warningOrange,
            ),
          ],
        );

      case TripStatus.onTrip:
        return Column(
          children: [
            _buildPrimaryButton(
              label: 'Finalizar Viagem',
              icon: Icons.flag,
              onPressed: onCompleteTrip,
              color: DesignTokens.successGreen,
            ),
            const SizedBox(height: DesignTokens.spaceSm),
            _buildNavigateButton(),
          ],
        );

      case TripStatus.arrivedAtDestination:
        return _buildPrimaryButton(
          label: 'Confirmar Chegada',
          icon: Icons.check_circle,
          onPressed: onCompleteTrip,
          color: DesignTokens.successGreen,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSecondaryActions() {
    return Row(
      children: [
        // Botão de emergência
        Expanded(
          child: _buildActionButton(
            label: 'Emergência',
            icon: Icons.emergency,
            onPressed: onEmergency,
            color: DesignTokens.errorRed,
            isOutlined: true,
          ),
        ),

        const SizedBox(width: DesignTokens.spaceMd),

        // Botão de suporte
        Expanded(
          child: _buildActionButton(
            label: 'Suporte',
            icon: Icons.support_agent,
            onPressed: onSupport,
            color: DesignTokens.infoBlue,
            isOutlined: true,
          ),
        ),

        const SizedBox(width: DesignTokens.spaceMd),

        // Botão de cancelar (se permitido)
        if (trip.status.canCancelTrip)
          Expanded(
            child: _buildActionButton(
              label: 'Cancelar',
              icon: Icons.cancel,
              onPressed: onCancelTrip,
              color: DesignTokens.warningOrange,
              isOutlined: true,
            ),
          ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: DesignTokens.iconMd),
        label: Text(
          label,
          style: DesignTokens.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: DesignTokens.iconSm),
        label: Text(label, style: DesignTokens.labelMedium),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigateButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onNavigate,
        icon: const Icon(Icons.navigation, size: DesignTokens.iconSm),
        label: Text('Navegar', style: DesignTokens.labelMedium),
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.primaryBlue,
          side: const BorderSide(color: DesignTokens.primaryBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    bool isOutlined = false,
  }) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: DesignTokens.iconSm),
        label: Text(
          label,
          style: DesignTokens.bodySmall.copyWith(fontWeight: FontWeight.w500),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceSm,
            vertical: DesignTokens.spaceSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: DesignTokens.iconSm),
      label: Text(
        label,
        style: DesignTokens.bodySmall.copyWith(fontWeight: FontWeight.w500),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceSm,
          vertical: DesignTokens.spaceSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        ),
      ),
    );
  }
}

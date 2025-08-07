import 'package:flutter/material.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../../domain/models/driver_status.dart';

/// Card que exibe e controla o status do motorista
class DriverStatusCard extends StatelessWidget {
  const DriverStatusCard({
    super.key,
    required this.status,
    required this.isLoading,
    required this.onToggleStatus,
    this.canGoOnline = true,
  });

  final DriverStatus status;
  final bool isLoading;
  final VoidCallback onToggleStatus;
  final bool canGoOnline;

  @override
  Widget build(BuildContext context) {
    final isOnline = status == DriverStatus.online;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceLg),
        child: Column(
          children: [
            // Indicador visual do status
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getStatusColor(status),
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor(status).withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _getStatusIcon(status),
                size: 40,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: DesignTokens.spaceMd),

            // Status atual
            Text(
              status.displayName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getStatusColor(status),
              ),
            ),

            const SizedBox(height: DesignTokens.spaceSm),

            // Descrição do status
            Text(
              status.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: DesignTokens.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: DesignTokens.spaceLg),

            // Botão de toggle
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading || !canGoOnline ? null : onToggleStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOnline
                      ? DesignTokens.errorRed
                      : DesignTokens.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: DesignTokens.spaceMd,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        isOnline ? 'Ficar Offline' : 'Ficar Online',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(DriverStatus status) {
    switch (status) {
      case DriverStatus.offline:
        return DesignTokens.textSecondary;
      case DriverStatus.online:
        return DesignTokens.successGreen;
      case DriverStatus.paused:
        return DesignTokens.warningOrange;
      case DriverStatus.onTrip:
        return DesignTokens.primaryBlue;
      case DriverStatus.suspended:
        return DesignTokens.errorRed;
    }
  }

  IconData _getStatusIcon(DriverStatus status) {
    switch (status) {
      case DriverStatus.offline:
        return Icons.power_settings_new;
      case DriverStatus.online:
        return Icons.radio_button_checked;
      case DriverStatus.paused:
        return Icons.pause_circle_filled;
      case DriverStatus.onTrip:
        return Icons.directions_car;
      case DriverStatus.suspended:
        return Icons.block;
    }
  }
}

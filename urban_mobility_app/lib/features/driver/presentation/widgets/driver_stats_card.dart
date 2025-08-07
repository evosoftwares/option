import 'package:flutter/material.dart';
import '../../../../core/design_system/design_tokens.dart';

/// Card que exibe as estatísticas do motorista
class DriverStatsCard extends StatelessWidget {
  const DriverStatsCard({
    super.key,
    required this.stats,
    this.isLoading = false,
  });

  final Map<String, dynamic>? stats;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(DesignTokens.spaceLg),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (stats == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(DesignTokens.spaceLg),
          child: Center(child: Text('Dados não disponíveis')),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: DesignTokens.primaryBlue,
                  size: DesignTokens.iconLg,
                ),
                const SizedBox(width: DesignTokens.spaceSm),
                Text('Estatísticas', style: DesignTokens.headingMedium),
              ],
            ),

            const SizedBox(height: DesignTokens.spaceLg),

            // Grid de estatísticas
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: DesignTokens.spaceMd,
              mainAxisSpacing: DesignTokens.spaceMd,
              children: [
                _buildStatItem(
                  icon: Icons.directions_car,
                  label: 'Viagens',
                  value: '${stats!['totalRides'] ?? 0}',
                  color: DesignTokens.primaryBlue,
                ),
                _buildStatItem(
                  icon: Icons.star,
                  label: 'Avaliação',
                  value:
                      '${(stats!['averageRating'] ?? 0.0).toStringAsFixed(1)}',
                  color: DesignTokens.warningOrange,
                ),
                _buildStatItem(
                  icon: Icons.attach_money,
                  label: 'Ganhos',
                  value:
                      'R\$ ${(stats!['totalEarnings'] ?? 0.0).toStringAsFixed(0)}',
                  color: DesignTokens.successGreen,
                ),
                _buildStatItem(
                  icon: Icons.route,
                  label: 'Distância',
                  value:
                      '${(stats!['totalDistance'] ?? 0.0).toStringAsFixed(0)}km',
                  color: DesignTokens.infoBlue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceMd),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: DesignTokens.iconLg),
          const SizedBox(height: DesignTokens.spaceXs),
          Text(
            value,
            style: DesignTokens.headingSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.space2xs),
          Text(
            label,
            style: DesignTokens.bodySmall.copyWith(
              color: DesignTokens.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

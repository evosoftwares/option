import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/design_system/design_tokens.dart';
import '../providers/driver_main_provider.dart';
import '../widgets/driver_status_card.dart';
import '../widgets/driver_stats_card.dart';
import '../widgets/ride_request_card.dart';

/// Tela principal do motorista
class DriverMainPage extends StatefulWidget {
  const DriverMainPage({super.key});

  @override
  State<DriverMainPage> createState() => _DriverMainPageState();
}

class _DriverMainPageState extends State<DriverMainPage> {
  final String _driverId =
      'current_driver_id'; // TODO: Obter do contexto de autenticação

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverMainProvider>().initialize(_driverId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.backgroundLight,
      appBar: AppBar(
        title: const Text('InDriver - Motorista'),
        backgroundColor: DesignTokens.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Botão de configurações
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsBottomSheet(context),
          ),
          // Botão de perfil
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Navegar para perfil
            },
          ),
        ],
      ),
      body: Consumer<DriverMainProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.driverProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(_driverId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(DesignTokens.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mensagem de erro, se houver
                  if (provider.error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(DesignTokens.spaceMd),
                      margin: const EdgeInsets.only(
                        bottom: DesignTokens.spaceMd,
                      ),
                      decoration: BoxDecoration(
                        color: DesignTokens.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusMd,
                        ),
                        border: Border.all(
                          color: DesignTokens.errorRed.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: DesignTokens.errorRed,
                          ),
                          const SizedBox(width: DesignTokens.spaceSm),
                          Expanded(
                            child: Text(
                              provider.error!,
                              style: DesignTokens.bodyMedium.copyWith(
                                color: DesignTokens.errorRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Solicitação de viagem ativa
                  if (provider.currentRideRequest != null) ...[
                    RideRequestCard(
                      request: provider.currentRideRequest!,
                      onAccept: () => provider.acceptRideRequest(),
                      onDecline: () => provider.declineRideRequest(),
                      isLoading: provider.isLoading,
                    ),
                    const SizedBox(height: DesignTokens.spaceLg),
                  ],

                  // Card de status do motorista
                  DriverStatusCard(
                    status: provider.status,
                    isLoading: provider.isLoading,
                    onToggleStatus: () =>
                        provider.toggleOnlineStatus(_driverId),
                    canGoOnline: provider.canGoOnline,
                  ),

                  const SizedBox(height: DesignTokens.spaceLg),

                  // Configurações rápidas
                  _buildQuickSettings(provider),

                  const SizedBox(height: DesignTokens.spaceLg),

                  // Estatísticas do motorista
                  DriverStatsCard(
                    stats: provider.driverStats,
                    isLoading: provider.isLoading,
                  ),

                  const SizedBox(height: DesignTokens.spaceLg),

                  // Informações adicionais
                  _buildAdditionalInfo(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickSettings(DriverMainProvider provider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune,
                  color: DesignTokens.primaryBlue,
                  size: DesignTokens.iconLg,
                ),
                const SizedBox(width: DesignTokens.spaceSm),
                Text(
                  'Configurações Rápidas',
                  style: DesignTokens.headingMedium,
                ),
              ],
            ),

            const SizedBox(height: DesignTokens.spaceLg),

            // Taxa por quilômetro
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Taxa por Km', style: DesignTokens.labelMedium),
                    const SizedBox(height: DesignTokens.space2xs),
                    Text(
                      'R\$ ${provider.ratePerKm.toStringAsFixed(2)}',
                      style: DesignTokens.headingSmall.copyWith(
                        color: DesignTokens.primaryBlue,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showRateDialog(context, provider),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Alterar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spaceMd,
                      vertical: DesignTokens.spaceSm,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(DriverMainProvider provider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: DesignTokens.infoBlue,
                  size: DesignTokens.iconLg,
                ),
                const SizedBox(width: DesignTokens.spaceSm),
                Text('Informações', style: DesignTokens.headingMedium),
              ],
            ),

            const SizedBox(height: DesignTokens.spaceMd),

            _buildInfoRow(
              icon: Icons.location_on,
              label: 'Status de Localização',
              value: 'Ativo',
              color: DesignTokens.successGreen,
            ),

            const SizedBox(height: DesignTokens.spaceSm),

            _buildInfoRow(
              icon: Icons.wifi,
              label: 'Conexão',
              value: 'Online',
              color: DesignTokens.successGreen,
            ),

            const SizedBox(height: DesignTokens.spaceSm),

            _buildInfoRow(
              icon: Icons.battery_full,
              label: 'Bateria',
              value: 'Boa',
              color: DesignTokens.successGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: DesignTokens.iconMd),
        const SizedBox(width: DesignTokens.spaceSm),
        Expanded(child: Text(label, style: DesignTokens.bodyMedium)),
        Text(value, style: DesignTokens.labelMedium.copyWith(color: color)),
      ],
    );
  }

  void _showRateDialog(BuildContext context, DriverMainProvider provider) {
    final controller = TextEditingController(
      text: provider.ratePerKm.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Taxa por Km'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Defina sua taxa por quilômetro:',
              style: DesignTokens.bodyMedium,
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Taxa (R\$)',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newRate = double.tryParse(controller.text);
              if (newRate != null && newRate > 0) {
                provider.updateRatePerKm(_driverId, newRate);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusLg),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(DesignTokens.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DesignTokens.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: DesignTokens.spaceLg),

            Text('Configurações', style: DesignTokens.headingMedium),

            const SizedBox(height: DesignTokens.spaceLg),

            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notificações'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Implementar configurações de notificação
              },
            ),

            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Localização'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Implementar configurações de localização
              },
            ),

            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Ajuda'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Implementar tela de ajuda
              },
            ),

            const SizedBox(height: DesignTokens.spaceMd),
          ],
        ),
      ),
    );
  }
}

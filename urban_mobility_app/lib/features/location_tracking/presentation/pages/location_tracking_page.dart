import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_tracking_provider.dart';
import '../components/location_tracking_controls_component.dart';
import '../widgets/location_display_widget.dart';

/// Tela principal de rastreamento de localização
/// 
/// Integra todos os componentes do sistema de rastreamento
/// em uma interface unificada e responsiva.
class LocationTrackingPage extends StatefulWidget {
  const LocationTrackingPage({super.key});

  @override
  State<LocationTrackingPage> createState() => _LocationTrackingPageState();
}

class _LocationTrackingPageState extends State<LocationTrackingPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _showAdvancedControls = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rastreamento de Localização'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_showAdvancedControls ? Icons.expand_less : Icons.expand_more),
            onPressed: () {
              setState(() {
                _showAdvancedControls = !_showAdvancedControls;
              });
            },
            tooltip: _showAdvancedControls 
                ? 'Ocultar controles avançados' 
                : 'Mostrar controles avançados',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Atualizar Localização'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'clear_history',
                child: ListTile(
                  leading: Icon(Icons.clear_all),
                  title: Text('Limpar Histórico'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Exportar Dados'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.control_camera), text: 'Controles'),
            Tab(icon: Icon(Icons.location_on), text: 'Localização'),
            Tab(icon: Icon(Icons.analytics), text: 'Estatísticas'),
          ],
        ),
      ),
      body: Consumer<LocationTrackingProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Status bar sempre visível
              _buildStatusBar(provider),
              
              // Conteúdo principal em abas
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Aba de Controles
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          LocationTrackingControlsComponent(
                            showAdvancedControls: _showAdvancedControls,
                            onLocationUpdate: () => _handleLocationUpdate(),
                          ),
                          if (provider.hasLocation) ...[
                            const SizedBox(height: 16),
                            _buildQuickInfo(provider),
                          ],
                        ],
                      ),
                    ),
                    
                    // Aba de Localização
                    const LocationDisplayWidget(
                      showHistory: true,
                      showStatistics: false,
                      maxHistoryItems: 20,
                    ),
                    
                    // Aba de Estatísticas
                    const LocationDisplayWidget(
                      showHistory: false,
                      showStatistics: true,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<LocationTrackingProvider>(
        builder: (context, provider, child) {
          if (provider.isTracking) {
            return FloatingActionButton(
              onPressed: () => provider.stopTracking(),
              backgroundColor: Colors.red,
              tooltip: 'Parar Rastreamento',
              child: const Icon(Icons.stop, color: Colors.white),
            );
          } else if (provider.canStart) {
            return FloatingActionButton(
              onPressed: () => _startTracking(provider),
              backgroundColor: Colors.green,
              tooltip: 'Iniciar Rastreamento',
              child: const Icon(Icons.play_arrow, color: Colors.white),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatusBar(LocationTrackingProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor(provider).withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: _getStatusColor(provider).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(provider),
            color: _getStatusColor(provider),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            _getStatusText(provider),
            style: TextStyle(
              color: _getStatusColor(provider),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          if (provider.isTracking && provider.locationHistory.isNotEmpty)
            Text(
              '${provider.locationHistory.length} pontos',
              style: TextStyle(
                color: _getStatusColor(provider),
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo(LocationTrackingProvider provider) {
    final location = provider.currentLocation!;
    final stats = provider.getTrackingStatistics();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações Rápidas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickStat(
                    'Precisão',
                    '±${location.accuracy.toStringAsFixed(0)}m',
                    Icons.gps_fixed,
                    _getAccuracyColor(location.accuracy),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickStat(
                    'Velocidade',
                    location.speed != null 
                        ? '${(location.speed! * 3.6).toStringAsFixed(1)} km/h'
                        : '0 km/h',
                    Icons.speed,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            if (provider.isTracking) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickStat(
                      'Distância',
                      '${(stats['totalDistance'] as double).toStringAsFixed(2)} km',
                      Icons.straighten,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickStat(
                      'Tempo',
                      _formatDuration(stats['totalTime'] as Duration),
                      Icons.timer,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Métodos de ação

  Future<void> _startTracking(LocationTrackingProvider provider) async {
    try {
      await provider.startTracking();
      _showSnackBar('Rastreamento iniciado', Colors.green);
    } catch (e) {
      _showSnackBar('Erro ao iniciar rastreamento: $e', Colors.red);
    }
  }

  void _handleLocationUpdate() {
    // Callback para quando a localização é atualizada
    // Pode ser usado para atualizar mapas ou outras visualizações
  }

  void _handleMenuAction(String action) async {
    final provider = context.read<LocationTrackingProvider>();
    
    switch (action) {
      case 'refresh':
        try {
          await provider.getCurrentLocation();
          _showSnackBar('Localização atualizada', Colors.green);
        } catch (e) {
          _showSnackBar('Erro ao atualizar localização: $e', Colors.red);
        }
        break;
        
      case 'clear_history':
        if (provider.locationHistory.isNotEmpty) {
          final confirmed = await _showConfirmDialog(
            'Limpar Histórico',
            'Tem certeza que deseja limpar todo o histórico de localizações?',
          );
          if (confirmed) {
            provider.clearHistory();
            _showSnackBar('Histórico limpo', Colors.blue);
          }
        }
        break;
        
      case 'export':
        _showSnackBar('Funcionalidade de exportação em desenvolvimento', Colors.orange);
        break;
    }
  }

  // Métodos auxiliares

  Color _getStatusColor(LocationTrackingProvider provider) {
    if (provider.hasError) return Colors.red;
    if (provider.isTracking) return Colors.green;
    if (provider.isPaused) return Colors.orange;
    return Colors.grey;
  }

  IconData _getStatusIcon(LocationTrackingProvider provider) {
    if (provider.hasError) return Icons.error;
    if (provider.isTracking) return Icons.location_on;
    if (provider.isPaused) return Icons.pause_circle;
    return Icons.location_off;
  }

  String _getStatusText(LocationTrackingProvider provider) {
    if (provider.hasError) return 'Erro: ${provider.errorMessage}';
    if (provider.isTracking) return 'Rastreamento ativo';
    if (provider.isPaused) return 'Rastreamento pausado';
    return 'Rastreamento inativo';
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy <= 5) return Colors.green;
    if (accuracy <= 15) return Colors.orange;
    return Colors.red;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else if (minutes > 0) {
      return '${minutes}min';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
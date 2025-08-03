import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/tracking_config.dart';
import '../../domain/entities/tracking_status.dart';
import '../providers/location_tracking_provider.dart';

/// Widget de controles para rastreamento de localização
/// 
/// Fornece interface para iniciar, parar, pausar e configurar
/// o rastreamento de localização.
class LocationTrackingControls extends StatelessWidget {

  const LocationTrackingControls({
    Key? key,
    this.onLocationUpdate,
    this.showAdvancedControls = false,
  }) : super(key: key);
  final VoidCallback? onLocationUpdate;
  final bool showAdvancedControls;

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationTrackingProvider>(
      builder: (context, provider, child) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatusIndicator(provider),
                const SizedBox(height: 16),
                _buildMainControls(context, provider),
                if (showAdvancedControls) ...[
                  const SizedBox(height: 16),
                  _buildAdvancedControls(context, provider),
                ],
                if (provider.hasError) ...[
                  const SizedBox(height: 16),
                  _buildErrorDisplay(provider),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(LocationTrackingProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: _getStatusColor(provider.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(provider.status),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(provider.status),
            color: _getStatusColor(provider.status),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            provider.status.description,
            style: TextStyle(
              color: _getStatusColor(provider.status),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (provider.isTracking)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(
                  _getStatusColor(provider.status),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainControls(BuildContext context, LocationTrackingProvider provider) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: provider.canStart ? () => _startTracking(context, provider) : null,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Iniciar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: provider.canPause ? () => _pauseTracking(provider) : null,
            icon: Icon(provider.isPaused ? Icons.play_arrow : Icons.pause),
            label: Text(provider.isPaused ? 'Retomar' : 'Pausar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: provider.canStop ? () => _stopTracking(provider) : null,
            icon: const Icon(Icons.stop),
            label: const Text('Parar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedControls(BuildContext context, LocationTrackingProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        const Text(
          'Configurações Avançadas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showConfigDialog(context, provider),
                icon: const Icon(Icons.settings),
                label: const Text('Configurar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _getCurrentLocation(provider),
                icon: const Icon(Icons.my_location),
                label: const Text('Localização'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: provider.locationHistory.isNotEmpty 
                    ? () => provider.clearHistory() 
                    : null,
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpar Histórico'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: provider.hasError 
                    ? () => provider.clearError() 
                    : null,
                icon: const Icon(Icons.refresh),
                label: const Text('Limpar Erro'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorDisplay(LocationTrackingProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              provider.errorMessage ?? 'Erro desconhecido',
              style: const TextStyle(color: Colors.red),
            ),
          ),
          IconButton(
            onPressed: () => provider.clearError(),
            icon: const Icon(Icons.close, color: Colors.red),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  // Métodos de ação

  Future<void> _startTracking(BuildContext context, LocationTrackingProvider provider) async {
    try {
      await provider.startTracking();
      onLocationUpdate?.call();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao iniciar rastreamento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pauseTracking(LocationTrackingProvider provider) async {
    if (provider.isPaused) {
      await provider.resumeTracking();
    } else {
      await provider.pauseTracking();
    }
  }

  Future<void> _stopTracking(LocationTrackingProvider provider) async {
    await provider.stopTracking();
  }

  Future<void> _getCurrentLocation(LocationTrackingProvider provider) async {
    await provider.getCurrentLocation();
    onLocationUpdate?.call();
  }

  void _showConfigDialog(BuildContext context, LocationTrackingProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _ConfigDialog(
        currentConfig: provider.config,
        onConfigChanged: (config) => provider.updateConfig(config),
      ),
    );
  }

  // Métodos auxiliares

  Color _getStatusColor(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.idle:
        return Colors.grey;
      case TrackingStatus.active:
        return Colors.green;
      case TrackingStatus.paused:
        return Colors.orange;
      case TrackingStatus.error:
      case TrackingStatus.permissionDenied:
      case TrackingStatus.serviceDisabled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.idle:
        return Icons.location_off;
      case TrackingStatus.active:
        return Icons.location_on;
      case TrackingStatus.paused:
        return Icons.pause_circle;
      case TrackingStatus.error:
        return Icons.error;
      case TrackingStatus.permissionDenied:
        return Icons.block;
      case TrackingStatus.serviceDisabled:
        return Icons.location_disabled;
    }
  }
}

/// Dialog para configuração do rastreamento
class _ConfigDialog extends StatefulWidget {

  const _ConfigDialog({
    required this.currentConfig,
    required this.onConfigChanged,
  });
  final TrackingConfig currentConfig;
  final ValueChanged<TrackingConfig> onConfigChanged;

  @override
  State<_ConfigDialog> createState() => _ConfigDialogState();
}

class _ConfigDialogState extends State<_ConfigDialog> {
  late TrackingConfig _config;

  @override
  void initState() {
    super.initState();
    _config = widget.currentConfig;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configurações de Rastreamento'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPresetButtons(),
            const SizedBox(height: 16),
            _buildSlider(
              'Intervalo de Atualização',
              '${_config.updateIntervalMs ~/ 1000}s',
              _config.updateIntervalMs.toDouble(),
              1000,
              60000,
              (value) => _config = _config.copyWith(updateIntervalMs: value.round()),
            ),
            _buildSlider(
              'Distância Mínima',
              '${_config.minDistanceMeters.round()}m',
              _config.minDistanceMeters,
              1,
              500,
              (value) => _config = _config.copyWith(minDistanceMeters: value),
            ),
            _buildAccuracyDropdown(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfigChanged(_config);
            Navigator.of(context).pop();
          },
          child: const Text('Aplicar'),
        ),
      ],
    );
  }

  Widget _buildPresetButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _config = TrackingConfig.highPrecision()),
            child: const Text('Alta Precisão'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _config = TrackingConfig.balanced()),
            child: const Text('Balanceado'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _config = TrackingConfig.batterySaver()),
            child: const Text('Economia'),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(
    String label,
    String value,
    double currentValue,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: currentValue,
          min: min,
          max: max,
          divisions: 20,
          onChanged: (value) {
            setState(() => onChanged(value));
          },
        ),
      ],
    );
  }

  Widget _buildAccuracyDropdown() {
    return DropdownButtonFormField<LocationAccuracy>(
      value: _config.accuracy,
      decoration: const InputDecoration(
        labelText: 'Precisão',
        border: OutlineInputBorder(),
      ),
      items: LocationAccuracy.values.map((accuracy) {
        return DropdownMenuItem(
          value: accuracy,
          child: Text(accuracy.description),
        );
      }).toList(),
      onChanged: (accuracy) {
        if (accuracy != null) {
          setState(() => _config = _config.copyWith(accuracy: accuracy));
        }
      },
    );
  }
}
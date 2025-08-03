import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/location_data.dart';
import '../providers/location_tracking_provider.dart';

/// Widget para exibir informações de localização
/// 
/// Mostra dados da localização atual, histórico e estatísticas
/// de rastreamento de forma organizada e responsiva.
class LocationDisplay extends StatelessWidget {

  const LocationDisplay({
    Key? key,
    this.showHistory = true,
    this.showStatistics = true,
    this.maxHistoryItems = 10,
  }) : super(key: key);
  final bool showHistory;
  final bool showStatistics;
  final int maxHistoryItems;

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationTrackingProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCurrentLocationCard(provider),
              if (showStatistics && provider.isTracking) ...[
                const SizedBox(height: 16),
                _buildStatisticsCard(provider),
              ],
              if (showHistory && provider.locationHistory.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildHistoryCard(provider),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentLocationCard(LocationTrackingProvider provider) {
    final location = provider.currentLocation;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Localização Atual',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (provider.isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (location != null) ...[
              _buildLocationInfo(location),
            ] else ...[
              const Center(
                child: Text(
                  'Nenhuma localização disponível',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(EnhancedLocationData location) {
    return Column(
      children: [
        _buildInfoRow('Latitude', '${location.latitude.toStringAsFixed(6)}°'),
        _buildInfoRow('Longitude', '${location.longitude.toStringAsFixed(6)}°'),
        _buildInfoRow('Precisão', '±${location.accuracy.toStringAsFixed(1)}m'),
        if (location.altitude != null)
          _buildInfoRow('Altitude', '${location.altitude!.toStringAsFixed(1)}m'),
        if (location.speed != null && location.speed! > 0)
          _buildInfoRow('Velocidade', '${(location.speed! * 3.6).toStringAsFixed(1)} km/h'),
        if (location.heading != null)
          _buildInfoRow('Direção', '${location.heading!.toStringAsFixed(0)}°'),
        if (location.address != null && location.address!.isNotEmpty)
          _buildInfoRow('Endereço', location.address!, isAddress: true),
        _buildInfoRow('Atualizado', _formatTimestamp(location.timestamp)),
        _buildInfoRow('Fonte', _getSourceDescription(location.source)),
      ],
    );
  }

  Widget _buildStatisticsCard(LocationTrackingProvider provider) {
    final stats = provider.getTrackingStatistics();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Estatísticas de Rastreamento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Distância Total',
                    '${(stats['totalDistance'] as double).toStringAsFixed(2)} km',
                    Icons.straighten,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Velocidade Média',
                    '${(stats['averageSpeed'] as double).toStringAsFixed(1)} km/h',
                    Icons.speed,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Precisão Média',
                    '±${(stats['averageAccuracy'] as double).toStringAsFixed(1)}m',
                    Icons.gps_fixed,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Tempo Total',
                    _formatDuration(stats['totalTime'] as Duration),
                    Icons.timer,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(LocationTrackingProvider provider) {
    final history = provider.locationHistory
        .take(maxHistoryItems)
        .toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Histórico de Localizações',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${history.length} de ${provider.locationHistory.length}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...history.map((location) => _buildHistoryItem(location)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(EnhancedLocationData location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getSourceIcon(location.source),
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                if (location.address != null && location.address!.isNotEmpty)
                  Text(
                    location.address!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '±${location.accuracy.toStringAsFixed(0)}m',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                _formatTimestamp(location.timestamp, short: true),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAddress = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              maxLines: isAddress ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Métodos auxiliares

  String _formatTimestamp(DateTime timestamp, {bool short = false}) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (short) {
      if (difference.inMinutes < 1) {
        return 'agora';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}min';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h';
      } else {
        return '${difference.inDays}d';
      }
    }
    
    if (difference.inMinutes < 1) {
      return 'há ${difference.inSeconds} segundos';
    } else if (difference.inHours < 1) {
      return 'há ${difference.inMinutes} minutos';
    } else if (difference.inDays < 1) {
      return 'há ${difference.inHours} horas';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else if (minutes > 0) {
      return '${minutes}min ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String _getSourceDescription(LocationSource source) {
    switch (source) {
      case LocationSource.gps:
        return 'GPS';
      case LocationSource.network:
        return 'Rede';
      case LocationSource.geocoding:
        return 'Geocoding';
      case LocationSource.cache:
        return 'Cache';
      case LocationSource.mock:
        return 'Mock';
    }
  }

  IconData _getSourceIcon(LocationSource source) {
    switch (source) {
      case LocationSource.gps:
        return Icons.gps_fixed;
      case LocationSource.network:
        return Icons.wifi;
      case LocationSource.geocoding:
        return Icons.search;
      case LocationSource.cache:
        return Icons.cached;
      case LocationSource.mock:
        return Icons.bug_report;
    }
  }
}
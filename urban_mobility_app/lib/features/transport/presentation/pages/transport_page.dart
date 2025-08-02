import 'package:flutter/material.dart';

class TransportPage extends StatefulWidget {
  const TransportPage({super.key});

  @override
  State<TransportPage> createState() => _TransportPageState();
}

class _TransportPageState extends State<TransportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transporte'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.directions_bus), text: 'Ônibus'),
            Tab(icon: Icon(Icons.directions_subway), text: 'Metrô'),
            Tab(icon: Icon(Icons.pedal_bike), text: 'Bike'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBusTab(),
          _buildSubwayTab(),
          _buildBikeTab(),
        ],
      ),
    );
  }

  Widget _buildBusTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchCard('Buscar linha de ônibus...'),
          const SizedBox(height: 20),
          Text(
            'Linhas Próximas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _buildBusRouteCard(
            routeNumber: '001',
            routeName: 'Centro - Aeroporto',
            nextArrival: '5 min',
            status: 'No horário',
            statusColor: Colors.green,
          ),
          _buildBusRouteCard(
            routeNumber: '025',
            routeName: 'Shopping - Universidade',
            nextArrival: '12 min',
            status: 'Atrasado',
            statusColor: Colors.orange,
          ),
          _buildBusRouteCard(
            routeNumber: '103',
            routeName: 'Rodoviária - Praia',
            nextArrival: '8 min',
            status: 'No horário',
            statusColor: Colors.green,
          ),
          const SizedBox(height: 20),
          _buildFavoritesSection('Linhas Favoritas'),
        ],
      ),
    );
  }

  Widget _buildSubwayTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchCard('Buscar estação de metrô...'),
          const SizedBox(height: 20),
          Text(
            'Estações Próximas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _buildSubwayStationCard(
            stationName: 'Estação Central',
            line: 'Linha Azul',
            distance: '200m',
            nextTrain: '3 min',
            lineColor: Colors.blue,
          ),
          _buildSubwayStationCard(
            stationName: 'Estação Liberdade',
            line: 'Linha Verde',
            distance: '450m',
            nextTrain: '7 min',
            lineColor: Colors.green,
          ),
          _buildSubwayStationCard(
            stationName: 'Estação República',
            line: 'Linha Vermelha',
            distance: '600m',
            nextTrain: '4 min',
            lineColor: Colors.red,
          ),
          const SizedBox(height: 20),
          _buildMapCard('Mapa do Metrô'),
        ],
      ),
    );
  }

  Widget _buildBikeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchCard('Buscar estação de bike...'),
          const SizedBox(height: 20),
          Text(
            'Estações Próximas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _buildBikeStationCard(
            stationName: 'Praça da Sé',
            availableBikes: 8,
            availableDocks: 4,
            distance: '150m',
          ),
          _buildBikeStationCard(
            stationName: 'Parque Ibirapuera',
            availableBikes: 12,
            availableDocks: 8,
            distance: '300m',
          ),
          _buildBikeStationCard(
            stationName: 'Avenida Paulista',
            availableBikes: 3,
            availableDocks: 17,
            distance: '500m',
          ),
          const SizedBox(height: 20),
          _buildBikeInfoCard(),
        ],
      ),
    );
  }

  Widget _buildSearchCard(String hint) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusRouteCard({
    required String routeNumber,
    required String routeName,
    required String nextArrival,
    required String status,
    required Color statusColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  routeNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routeName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Próximo: $nextArrival',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubwayStationCard({
    required String stationName,
    required String line,
    required String distance,
    required String nextTrain,
    required Color lineColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              color: lineColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stationName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    line,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: lineColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Distância: $distance',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  nextTrain,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const Text('próximo trem'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBikeStationCard({
    required String stationName,
    required int availableBikes,
    required int availableDocks,
    required String distance,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stationName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  distance,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.pedal_bike, color: Colors.green[600]),
                      const SizedBox(width: 8),
                      Text('$availableBikes bikes'),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      Text('$availableDocks vagas'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'Nenhuma linha favorita',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Toque no ❤️ para adicionar favoritos',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapCard(String title) {
    return Card(
      child: InkWell(
        onTap: () {
          // Implementar visualização do mapa
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.map,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ver mapa completo das linhas',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBikeInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Como usar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildInfoStep('1', 'Encontre uma estação próxima'),
            _buildInfoStep('2', 'Desbloqueie uma bike com o app'),
            _buildInfoStep('3', 'Pedale até seu destino'),
            _buildInfoStep('4', 'Devolva em qualquer estação'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoStep(String number, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
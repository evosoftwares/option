////
/// Página de Corridas (Rides)
///
/// Propósito:
/// - Gerenciar visualização de corridas ativas e histórico, além de criar nova corrida.
///
/// Camadas/Dependências:
/// - Presentation da feature Rides. Sem dependências de domínio no momento.
///
/// Responsabilidades:
/// - Controle de abas (ativas/histórico).
/// - Exibir cartões de corridas com ações básicas.
///
/// Pontos de extensão:
/// - Integração com estado real (streams de corridas).
/// - Ações de ligar/mensagem e aceite/recusa com backend.
///
/// Notas:
/// - Usa TabController com SingleTickerProviderStateMixin.
///
library;

import 'package:flutter/material.dart';

/// Página principal de corridas com abas.
class RidesPage extends StatefulWidget {
  /// Construtor padrão.
  const RidesPage({super.key});

  @override
  State<RidesPage> createState() => _RidesPageState();
}

class _RidesPageState extends State<RidesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Controle de abas: duas seções (Ativas e Histórico).
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Corridas'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.access_time), text: 'Ativas'),
            Tab(icon: Icon(Icons.history), text: 'Histórico'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildActiveRidesTab(), _buildHistoryTab()],
      ),
      // Ação principal para criação de uma nova corrida (mock).
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRequestRideDialog(),
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nova Corrida',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  /// Aba de corridas ativas com cards de status e ações.
  Widget _buildActiveRidesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Corridas em Andamento',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _buildActiveRideCard(
            driverName: 'João Silva',
            carModel: 'Honda Civic Branco',
            plate: 'ABC-1234',
            price: 'R\$ 25,00',
            status: 'A caminho',
            estimatedTime: '5 min',
            rating: 4.8,
          ),
          const SizedBox(height: 20),
          Text(
            'Ofertas Recebidas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _buildOfferCard(
            driverName: 'Maria Santos',
            carModel: 'Toyota Corolla Prata',
            originalPrice: 'R\$ 30,00',
            offerPrice: 'R\$ 28,00',
            rating: 4.9,
            estimatedTime: '8 min',
          ),
          _buildOfferCard(
            driverName: 'Carlos Oliveira',
            carModel: 'Hyundai HB20 Azul',
            originalPrice: 'R\$ 30,00',
            offerPrice: 'R\$ 32,00',
            rating: 4.7,
            estimatedTime: '12 min',
          ),
        ],
      ),
    );
  }

  /// Aba de histórico de corridas com cards resumidos.
  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Corridas Recentes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _buildHistoryCard(
            date: 'Hoje, 14:30',
            from: 'Shopping Center',
            to: 'Aeroporto Internacional',
            price: 'R\$ 45,00',
            driverName: 'Pedro Costa',
            rating: 5.0,
            status: 'Concluída',
          ),
          _buildHistoryCard(
            date: 'Ontem, 09:15',
            from: 'Casa',
            to: 'Escritório',
            price: 'R\$ 18,00',
            driverName: 'Ana Lima',
            rating: 4.8,
            status: 'Concluída',
          ),
          _buildHistoryCard(
            date: '2 dias atrás, 18:45',
            from: 'Universidade',
            to: 'Shopping Mall',
            price: 'R\$ 22,00',
            driverName: 'Roberto Silva',
            rating: 4.6,
            status: 'Concluída',
          ),
        ],
      ),
    );
  }

  // Aba "Favoritos" e conteúdo removidos conforme solicitação.

  /// Card para corrida ativa.
  /// Parâmetros: [driverName], [carModel], [plate], [price], [status], [estimatedTime], [rating].
  Widget _buildActiveRideCard({
    required String driverName,
    required String carModel,
    required String plate,
    required String price,
    required String status,
    required String estimatedTime,
    required double rating,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    driverName[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '$carModel • $plate',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(' $rating'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$status • $estimatedTime',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone),
                    label: const Text('Ligar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.message),
                    label: const Text('Mensagem'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Card de oferta recebida de motorista com preço e estimativa.
  Widget _buildOfferCard({
    required String driverName,
    required String carModel,
    required String originalPrice,
    required String offerPrice,
    required double rating,
    required String estimatedTime,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    driverName[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        carModel,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(' $rating • $estimatedTime'),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      originalPrice,
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      offerPrice,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Recusar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Aceitar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Card de histórico de corrida finalizada.
  Widget _buildHistoryCard({
    required String date,
    required String from,
    required String to,
    required String price,
    required String driverName,
    required double rating,
    required String status,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    date,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Text(
                  price,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.radio_button_checked,
                  color: Colors.green,
                  size: 12,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(from)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 12),
                const SizedBox(width: 8),
                Expanded(child: Text(to)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Motorista: $driverName'),
                const Spacer(),
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text(' $rating'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Cards de "Motoristas Favoritos" removidos.

  // Cards de "Rotas Favoritas" removidos.

  /// Exibe diálogo para solicitar nova corrida.
  /// Parâmetros opcionais para preencher campos: [prefilledFrom], [prefilledTo].
  /// Efeitos colaterais: exibe SnackBar ao confirmar.
  void _showRequestRideDialog({String? prefilledFrom, String? prefilledTo}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Corrida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'De onde?',
                prefixIcon: Icon(
                  Icons.radio_button_checked,
                  color: Colors.green,
                ),
              ),
              controller: TextEditingController(text: prefilledFrom),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Para onde?',
                prefixIcon: Icon(Icons.location_on, color: Colors.red),
              ),
              controller: TextEditingController(text: prefilledTo),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Você verá as ofertas dos motoristas com suas taxas após solicitar.',
                      style: TextStyle(color: Colors.blue[700], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Corrida solicitada! Buscando motoristas próximos...',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Solicitar'),
          ),
        ],
      ),
    );
  }
}

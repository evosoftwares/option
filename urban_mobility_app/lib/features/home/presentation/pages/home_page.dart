/* [Page: Home] Tela inicial sem ações rápidas e sem navegação para Map.
   Comentários curtos e endereçados por seção. */
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/services/location_service_optimized.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../core/di/service_locator.dart';

/* [Home] Widget raiz da Home. */
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _locationUpdateTimer;
  late LocationServiceOptimized _locationService;

  @override
  void initState() {
    super.initState();
    _locationService = sl<LocationServiceOptimized>();
    
    /* [Home/Init] Solicita localização após primeiro frame. */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _locationService.getCurrentPosition();
      _startLocationUpdates();
    });
  }

  void _startLocationUpdates() {
    // Atualiza a localização a cada 30 segundos
    print('[HomePage] Iniciando timer de atualização de localização');
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        if (mounted) {
          print('[HomePage] Timer disparado - atualizando localização');
          _locationService.getCurrentPosition(forceRefresh: true);
        } else {
          print('[HomePage] Widget não está montado - cancelando timer');
          timer.cancel();
        }
      },
    );
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* [Home/AppBar] Mantido para consistência do app. */
      appBar: AppBar(
        title: const Text('InDriver'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      /* [Home/Body] Hierarquia visual: cabeçalho compacto, busca e conteúdos existentes (acessos rápidos removidos). */
      body: LayoutBuilder(
        builder: (context, constraints) {
          const horizontal = 16.0;

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: horizontal,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /* Header compacto com saudação e ação à direita */
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Explorar mobilidade',
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.account_circle_outlined),
                        onPressed: () {},
                        tooltip: 'Conta',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  /* Campo de busca elevado */
                  const _SearchBarCard(),

                  const SizedBox(height: 24),

                  /* Conteúdos existentes preservados */
                  _buildWelcomeCard(),
                  const SizedBox(height: 16),
                  _buildLocationCard(),
                  const SizedBox(height: 16),
                  _buildLocationTrackingCard(),
                  const SizedBox(height: 16),

                  /* Placeholder de lista vazia (demonstração do componente reutilizável) */
                  const EmptyState(
                    title: 'Por enquanto nada aqui',
                    description:
                        'Quando houver conteúdo, ele aparecerá nesta seção.',
                    icon: Icons.inbox_outlined,
                  ),

                  const SizedBox(height: 16),
                  _buildRecentTrips(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /* [Home/Welcome] Card de boas-vindas e slogan. */
  Widget _buildWelcomeCard() {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Encontre sua corrida!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Conecte-se com motoristas próximos e veja suas taxas',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  /* [Home/Location] Card reativo com status de localização usando serviço otimizado. */
  Widget _buildLocationCard() {
    return ChangeNotifierProvider<LocationServiceOptimized>.value(
      value: _locationService,
      child: Consumer<LocationServiceOptimized>(
        builder: (context, locationService, child) {
          final state = locationService.state;
          
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /* [Home/Location/Header] Cabeçalho com ícone. */
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sua Localização',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      if (state.status == LocationStatus.success)
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  /* [Home/Location/Content] Conteúdo dinâmico baseado no estado otimizado. */
                  if (state.status == LocationStatus.loading)
                    const Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Flexible(
                          child: Text('Obtendo localização...'),
                        ),
                      ],
                    )
                  else if (state.status == LocationStatus.error || 
                           state.status == LocationStatus.permissionDenied)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.error ?? 'Erro desconhecido',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _locationService.getCurrentPosition(forceRefresh: true),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar Novamente'),
                        ),
                      ],
                    )
                  else if (state.status == LocationStatus.success && state.address != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.address!,
                          style: Theme.of(context).textTheme.bodyLarge,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Atualizado automaticamente',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                          ),
                        ),
                      ],
                    )
                  else
                    const Text('Localização não disponível'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /* [Home/LocationTracking] Card para acessar o sistema de rastreamento. */
  Widget _buildLocationTrackingCard() {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade600,
              Colors.blue.shade400,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.gps_fixed,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Rastreamento de Localização',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Sistema avançado de rastreamento em tempo real com estatísticas detalhadas e configurações personalizáveis.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/location-tracking'),
                icon: const Icon(Icons.navigation),
                label: const Text('Abrir Rastreamento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* [Home/Recent] Lista de corridas recentes. */
  Widget _buildRecentTrips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Corridas Recentes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/rides'),
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTripCard(
          from: 'Casa',
          to: 'Trabalho',
          date: 'Hoje, 08:30',
          price: 'R\$ 18,00',
          driver: 'João Silva',
          rating: 4.8,
        ),
        _buildTripCard(
          from: 'Shopping Center',
          to: 'Aeroporto',
          date: 'Ontem, 14:20',
          price: 'R\$ 45,00',
          driver: 'Maria Santos',
          rating: 4.9,
        ),
        _buildTripCard(
          from: 'Universidade',
          to: 'Casa',
          date: '2 dias atrás',
          price: 'R\$ 15,00',
          driver: 'Carlos Oliveira',
          rating: 4.7,
        ),
      ],
    );
  }

  /* [Home/Recent/Card] Card de corrida recente. */
  Widget _buildTripCard({
    required String from,
    required String to,
    required String date,
    required String price,
    required String driver,
    required double rating,
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
                    color: Theme.of(context).primaryColor,
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
                Flexible(
                  child: Text(
                    'Motorista: $driver',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text(' $rating'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /* [Home/Dialog] Diálogo para solicitar nova corrida. */
  void _showRequestRideDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.directions_car, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Nova Corrida'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'De onde?',
                prefixIcon: Icon(
                  Icons.radio_button_checked,
                  color: Colors.green,
                ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Para onde?',
                prefixIcon: Icon(Icons.location_on, color: Colors.red),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Você verá o valor estimado baseado nas taxas dos motoristas próximos antes de confirmar.',
                      style: TextStyle(color: Colors.green[700], fontSize: 12),
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
                SnackBar(
                  content: const Text(
                    'Corrida solicitada! Buscando motoristas próximos...',
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  action: SnackBarAction(
                    label: 'Ver',
                    textColor: Colors.white,
                    onPressed: () => context.go('/rides'),
                  ),
                ),
              );
            },
            child: const Text('Solicitar Corrida'),
          ),
        ],
      ),
    );
  }
  /* =========================
     Widgets privados auxiliares
     ========================= */

  /* Barra de busca elevada com tema */
  // ignore: unused_element
  static Color _surfaceOf(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  // ignore: unused_element
  static Color _onSurfaceVariantOf(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Fallback simples se variant não existir no tema
    return scheme.onSurface.withOpacity(0.7);
  }

  // Search Bar Card
  // ignore: unused_element
  Widget _searchField(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Para onde?',
        border: InputBorder.none,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.mic_none),
          onPressed: () {}, // sem lógica, apenas UI
          tooltip: 'Falar',
        ),
      ),
    );
  }
}

class _SearchBarCard extends StatelessWidget {
  const _SearchBarCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surface = colorScheme.surface;
    return Material(
      color: surface,
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Para onde?',
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.mic_none),
              onPressed: () {}, // apenas UI
              tooltip: 'Falar',
            ),
          ),
        ),
      ),
    );
  }
}

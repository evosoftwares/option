/* [App Entry] Ponto de entrada do app e configuração global de tema/rotas.
   Mantemos comentários curtos e seções nomeadas para leitura rápida. */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/passenger/presentation/pages/passenger_home_page.dart';
// import 'features/map/presentation/pages/map_page.dart'; // [Removed] MapPage removida
import 'features/rides/presentation/pages/rides_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/location_tracking/presentation/screens/location_tracking_screen.dart';
import 'features/profile/presentation/pages/edit_profile_page.dart';
import 'features/transport/presentation/pages/transport_example_page.dart';
import 'features/transport/presentation/pages/confirm_pickup_screen.dart';
// import 'features/chat/presentation/pages/chat_list_page.dart';
// import 'features/chat/presentation/pages/chat_page.dart';
// import 'features/chat/presentation/providers/chat_provider.dart';
// import 'features/chat/presentation/providers/chat_list_provider.dart';
// import 'features/chat/data/services/chat_service.dart';
// import 'features/chat/data/repositories/chat_repository_impl.dart';

/* [App Entry] Inicializa o app + Firebase + Supabase + Service Locator. */
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart' as fo;
import 'core/di/service_locator.dart';
import 'core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(options: fo.DefaultFirebaseOptions.currentPlatform);
  
  // Inicializar Supabase
  await SupabaseService.instance.initialize();
  
  // Configurar Service Locator
  await setupServiceLocator();
  
  runApp(const InDriverApp());
}

/* [App Entry] Raiz do aplicativo com Riverpod e MaterialApp.router. */
class InDriverApp extends StatelessWidget {
  const InDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'InDriver - Defina seu preço!',
        debugShowCheckedModeBanner: false,
        /* [Theme] Tema claro/escuro definidos em AppTheme. */
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        /* [Routing] GoRouter com rotas nomeadas. */
        routerConfig: _router,
      ),
    );
  }
}

/* [Routing] Declaração de rotas principais. */
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const MainNavigationPage()),
    GoRoute(path: '/passenger', builder: (context, state) => const PassengerHomePage()),
    // GoRoute(path: '/map', builder: (context, state) => const MapPage()), // [Removed] rota /map
    GoRoute(path: '/rides', builder: (context, state) => const RidesPage()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
    GoRoute(path: '/edit-profile', builder: (context, state) => const EditProfilePage()),
    GoRoute(path: '/location-tracking', builder: (context, state) => const LocationTrackingScreen()),
    GoRoute(path: '/transport-example', builder: (context, state) => const TransportExamplePage()),
    GoRoute(path: '/confirm-pickup', builder: (context, state) => const ConfirmPickupScreen()),
    // GoRoute(path: '/chat', builder: (context, state) => const ChatListPage()),
    // GoRoute(
    //   path: '/chat/:conversationId',
    //   builder: (context, state) {
    //     final conversationId = state.pathParameters['conversationId']!;
    //     return ChatPage(conversationId: conversationId);
    //   },
    // ),
  ],
);

/* [Shell] Página com BottomNavigation e preservação de estado via IndexedStack. */
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  /* [Shell/State] Índice atual da aba selecionada. */
  int _currentIndex = 0;

  /* [Shell/Pages] Pilha de páginas principais. */
  // [Shell/Pages] Removida MapPage do fluxo principal.
  final List<Widget> _pages = [
    const PassengerHomePage(), // Nova tela inicial do passageiro
    const RidesPage(),
    // const ChatListPage(), // Temporariamente desabilitado
    const Placeholder(child: Text('Chat em desenvolvimento')),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* [Shell/Body] IndexedStack mantém estado das páginas. */
      body: IndexedStack(index: _currentIndex, children: _pages),
      /* [Shell/Nav] Barra inferior sem item "Mapa". */
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Corridas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

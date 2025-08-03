/* [App Entry] Ponto de entrada do app e configuração global de tema/rotas.
   Mantemos comentários curtos e seções nomeadas para leitura rápida. */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/home/presentation/pages/home_page.dart';
// import 'features/map/presentation/pages/map_page.dart'; // [Removed] MapPage removida
import 'features/rides/presentation/pages/rides_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/location_tracking/presentation/screens/location_tracking_screen.dart';
import 'features/location_tracking/di/location_tracking_dependencies.dart';

/* [App Entry] Inicializa o app + Firebase + Service Locator. */
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart' as fo;
import 'core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: fo.DefaultFirebaseOptions.currentPlatform);
  await setupServiceLocator();
  runApp(const InDriverApp());
}

/* [App Entry] Raiz do aplicativo com Provider e MaterialApp.router. */
class InDriverApp extends StatelessWidget {
  const InDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      /* [App Entry/Providers] Serviços injetados no app. */
      providers: [
        ...LocationTrackingDependencies.getProviders(),
      ],
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
    // GoRoute(path: '/map', builder: (context, state) => const MapPage()), // [Removed] rota /map
    GoRoute(path: '/rides', builder: (context, state) => const RidesPage()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
    GoRoute(path: '/location-tracking', builder: (context, state) => const LocationTrackingScreen()),
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
    const HomePage(),
    const RidesPage(),
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

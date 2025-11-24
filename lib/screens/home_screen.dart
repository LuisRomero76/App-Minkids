import 'package:flutter/material.dart';
import 'package:minkids/screens/profile_screen.dart';
import 'package:minkids/screens/child_apps_screen.dart';
import 'package:minkids/screens/parent_app_config_screen.dart';
import 'package:minkids/screens/home_tab.dart';
import 'package:minkids/screens/location_screen.dart';
import 'package:minkids/services/auth_service.dart';
import 'package:minkids/services/realtime_location_service.dart';
import 'package:minkids/services/app_usage_tracker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _index = 0;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initLocationTracking();
    _initUsageTracking();
    _loadUserRole();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    RealtimeLocationService.stopTracking();
    AppUsageTracker.stopTracking();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reiniciar tracking cuando la app vuelve al foreground
    if (state == AppLifecycleState.resumed) {
      _initLocationTracking();
      _initUsageTracking();
    } else if (state == AppLifecycleState.paused) {
      RealtimeLocationService.stopTracking();
      // No detener usage tracker para que siga monitoreando en background
    }
  }

  Future<void> _initLocationTracking() async {
    final user = await AuthService.currentUser();
    // Solo iniciar tracking para hijos
    if (user?.rol == 'hijo') {
      await RealtimeLocationService.startTracking(intervalSeconds: 30);
    }
  }

  Future<void> _initUsageTracking() async {
    final user = await AuthService.currentUser();
    // Solo iniciar tracking de apps para hijos
    if (user?.rol == 'hijo') {
      await AppUsageTracker.startTracking(intervalMinutes: 5);
    }
  }

  Future<void> _loadUserRole() async {
    final user = await AuthService.currentUser();
    if (mounted) {
      setState(() {
        _userRole = user?.rol;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MinKids'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: _userRole == 'hijo'
            ? const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
                BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Apps'),
                BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Consejos'),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Perfil'),
              ]
            : const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
                BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Apps'),
                BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Ubicación'),
                BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Consejos'),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Perfil'),
              ],
      ),
    );
  }

  Widget _buildBody() {
    // Para hijo: 0=Inicio, 1=Apps, 2=Consejos, 3=Perfil
    // Para padre: 0=Inicio, 1=Apps, 2=Ubicación, 3=Consejos, 4=Perfil
    
    if (_userRole == 'hijo') {
      switch (_index) {
        case 0:
          return HomeTab(onNavigate: (i) => setState(() => _index = i));
        case 1:
          return const ChildAppsScreen();
        case 2:
          return const Center(child: Text('Consejos'));
        case 3:
          return const ProfileScreen();
        default:
          return HomeTab(onNavigate: (i) => setState(() => _index = i));
      }
    } else {
      // Para padre (incluye ubicación)
      switch (_index) {
        case 0:
          return HomeTab(onNavigate: (i) => setState(() => _index = i));
        case 1:
          return const ParentAppConfigScreen();
        case 2:
          return const LocationScreen();
        case 3:
          return const Center(child: Text('Consejos'));
        case 4:
          return const ProfileScreen();
        default:
          return HomeTab(onNavigate: (i) => setState(() => _index = i));
      }
    }
  }
}

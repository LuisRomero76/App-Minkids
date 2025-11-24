import 'package:flutter/material.dart';
import 'package:minkids/screens/profile_screen.dart';
import 'package:minkids/screens/apps_screen.dart';
import 'package:minkids/screens/home_tab.dart';
import 'package:minkids/screens/location_screen.dart';
import 'package:minkids/services/auth_service.dart';
import 'package:minkids/services/realtime_location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initLocationTracking();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    RealtimeLocationService.stopTracking();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reiniciar tracking cuando la app vuelve al foreground
    if (state == AppLifecycleState.resumed) {
      _initLocationTracking();
    } else if (state == AppLifecycleState.paused) {
      RealtimeLocationService.stopTracking();
    }
  }

  Future<void> _initLocationTracking() async {
    final user = await AuthService.currentUser();
    // Solo iniciar tracking para hijos
    if (user?.rol == 'hijo') {
      await RealtimeLocationService.startTracking(intervalSeconds: 30);
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
        items: const [
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
    switch (_index) {
      case 0:
        return HomeTab(onNavigate: (i) => setState(() => _index = i));
      case 1:
        return const AppsScreen();
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

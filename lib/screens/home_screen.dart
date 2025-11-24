import 'package:flutter/material.dart';
import 'package:minkids/screens/profile_screen.dart';
import 'package:minkids/screens/apps_screen.dart';
import 'package:minkids/screens/home_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

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
        return const Center(child: Text('Ubicación'));
      case 3:
        return const Center(child: Text('Consejos'));
      case 4:
        return const ProfileScreen();
      default:
        return HomeTab(onNavigate: (i) => setState(() => _index = i));
    }
  }
}

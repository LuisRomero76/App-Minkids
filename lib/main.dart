import 'package:flutter/material.dart';
import 'package:minkids/screens/home_screen.dart';
import 'package:minkids/screens/login_screen.dart';
import 'package:minkids/screens/register_screen.dart';
import 'package:minkids/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MinKids',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const RootDecider(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}

class RootDecider extends StatefulWidget {
  const RootDecider({super.key});

  @override
  State<RootDecider> createState() => _RootDeciderState();
}

class _RootDeciderState extends State<RootDecider> {
  late Future<bool> _logged;

  @override
  void initState() {
    super.initState();
    _logged = AuthService.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _logged,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final logged = snapshot.data ?? false;
        if (logged) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

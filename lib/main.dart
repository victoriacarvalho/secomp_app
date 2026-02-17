import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart'; 

// Telas principais
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart'; 

void main() async {
  // Garante que os bindings do Flutter estejam prontos antes da inicialização
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializa o Firebase com as configurações geradas pelo CLI
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Inicializa a formatação de datas para o padrão brasileiro
  await initializeDateFormatting('pt_BR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Secomp App',
      theme: ThemeData(
        primaryColor: const Color(0xFF9A202F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9A202F),
          primary: const Color(0xFF9A202F),
        ),
        useMaterial3: true,
        // Define fontes padrão se necessário (ex: sans-serif)
        fontFamily: 'sans-serif',
      ),
      // O AuthWrapper decide qual será a primeira tela exibida
      home: const AuthWrapper(),
    );
  }
}

// --- AUTH WRAPPER (PORTEIRO) ---
// Escuta em tempo real se o usuário está logado ou não
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        
        // Exibe indicador de carregamento enquanto verifica a sessão
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF9A202F)),
            ),
          );
        }

        // Caso exista um usuário na sessão do Firebase -> Vai para Home
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Caso contrário -> Vai para a tela de introdução (Onboarding)
        return const OnboardingScreen();
      },
    );
  }
}
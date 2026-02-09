import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';

// Importe suas telas
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
// Se você tiver uma tela de Onboarding, importe ela também:
// import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp();

  // Inicializa a formatação de datas para Português
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
        // Configuração de cores do seu projeto
        primaryColor: const Color(0xFF9A202F),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9A202F)),
        useMaterial3: true,
      ),
      // EM VEZ DE CHAMAR A LOGIN SCREEN DIRETO, CHAMAMOS O "PORTEIRO"
      home: const AuthWrapper(),
    );
  }
}

// --- O "PORTEIRO" (AUTH WRAPPER) ---
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder fica "ouvindo" o Firebase Auth em tempo real
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // 1. Enquanto verifica (Carregando...)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF9A202F)),
            ),
          );
        }

        // 2. Se tem erro na conexão
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Erro ao conectar no Firebase.")),
          );
        }

        // 3. SE TEM DADOS (USUÁRIO ESTÁ LOGADO) -> VAI PARA HOME
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // 4. SE NÃO TEM DADOS (DESLOGADO) -> VAI PARA LOGIN (OU ONBOARDING)
        return const LoginScreen();
      },
    );
  }
}
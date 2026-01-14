import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // Importamos a tela de splash

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App SECOMP',
      debugShowCheckedModeBanner: false, // Remove a faixa "Debug"
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9A202F)),
        useMaterial3: true,
      ),
      // Aqui definimos que a primeira tela é a SplashScreen
      home: const SplashScreen(),
    );
  }
}
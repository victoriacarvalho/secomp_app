import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // Importamos a tela de splash

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Sua tela de Splash como inicial
    );
  }
}
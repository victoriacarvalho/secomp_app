import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // Lógica para esperar 4 segundos e ir para a próxima tela
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  // Cores do layout
  final Color backgroundColor = const Color(0xFFE6E6E6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // --- LOGO CENTRAL (SECOMP) ---
            // Substituído o Texto pela Imagem
            Center(
              child: Image.asset(
                'public/secomp.png', // Certifique-se que o nome do arquivo e extensão estão corretos
                width: 250, // Ajuste este valor para aumentar ou diminuir a logo
                fit: BoxFit.contain,
              ),
            ),

            const Spacer(),

            // --- RODAPÉ (ICEA) ---
            // Substituído o Texto pela Imagem
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Image.asset(
                'public/icea.png', // Certifique-se que o nome do arquivo e extensão estão corretos
                height: 80,
                width: 200,// Ajuste a altura conforme necessário
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
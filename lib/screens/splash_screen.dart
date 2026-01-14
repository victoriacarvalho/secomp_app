import 'package:flutter/material.dart';
import 'home_screen.dart'; // Importamos a Home para poder navegar até ela
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
    // Lógica para esperar 3 segundos e ir para a próxima tela
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        // MUDEI AQUI: Agora vai para o OnboardingScreen
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  // Cores do layout
  final Color backgroundColor = const Color(0xFFE6E6E6);
  final Color primaryColor = const Color(0xFF9A202F);
  final Color greyTextColor = const Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),


            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SECOMP',
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 48,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                    letterSpacing: 2.0,
                  ),
                ),
                Container(
                  height: 4,
                  width: 120,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // --- RODAPÉ (ICEA) ---
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'icea',
                    style: TextStyle(
                      fontFamily: 'Futura', // Se não tiver, ele usa a padrão
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Instituto de Ciências', style: TextStyle(fontSize: 12, color: greyTextColor)),
                      Text('Exatas e Aplicadas', style: TextStyle(fontSize: 12, color: greyTextColor)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
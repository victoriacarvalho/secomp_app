import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFF9A202F);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Imagem de Fundo (Topo)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            // Aumentamos levemente a altura para garantir que o corte da imagem 
            // no encontro com o branco fique no ponto ideal do design
            height: MediaQuery.of(context).size.height * 0.60, 
            child: Image.asset(
              'assets/images/onboarding_bg.png',
              // BoxFit.cover garante que a imagem preencha o espaço sem sobras
              fit: BoxFit.cover, 
              alignment: Alignment.topCenter, // Mantém o foco no topo da imagem
              errorBuilder: (context, error, stackTrace) => Container(color: primaryRed),
            ),
          ),

          // 2. Painel Branco (Base)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              // Ajustado para encontrar a imagem perfeitamente
              height: MediaQuery.of(context).size.height * 0.42, 
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 35),
              decoration: const BoxDecoration(
                color: Colors.white,
                // Sem Border Radius conforme sua preferência anterior para encostar nas bordas
                borderRadius: BorderRadius.zero, 
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Text(
                        "Organize sua\nconferência",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Times New Roman',
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Faça login e conheça nossas ferramentas disponíveis para facilitar a organização do seu evento.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black45,
                          fontFamily: 'sans-serif',
                        ),
                      ),
                    ],
                  ),
                  
                  // Botão Iniciar
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        "INICIAR",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
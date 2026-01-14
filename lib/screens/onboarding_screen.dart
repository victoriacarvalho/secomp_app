import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Cores
    final Color primaryRed = const Color(0xFF9A202F);
    final Color darkBlue = const Color(0xFF2C3E50);

    return Scaffold(
      backgroundColor: darkBlue, // Cor de fundo de segurança
      body: Column(
        children: [
          // --- METADE SUPERIOR (Apenas a Imagem) ---
          Expanded(
            flex: 6, // Ocupa 60% da tela
            child: SizedBox(
              width: double.infinity, // Garante que ocupa a largura toda
              child: Image.asset(
                'public/calendario.png', // Certifique-se que esta imagem está na pasta e no pubspec
                fit: BoxFit.cover, // Cobre todo o espaço (corta excessos se necessário)
              ),
            ),
          ),

          // --- METADE INFERIOR (Quadrado Branco com Infos) ---
          Expanded(
            flex: 4, // Ocupa 40% da tela
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5), // Branco gelo
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Título
                    Text(
                      'Organize sua\nconferência',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Times New Roman',
                        fontSize: 32,
                        color: primaryRed,
                        height: 1.1,
                      ),
                    ),

                    // Descrição
                    const Text(
                      'Faça login e conheça nossas ferramentas disponíveis para facilitar a organização do seu evento.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    // Botão INICIAR
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          'Iniciar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para fazer as bolinhas (dots)
  Widget _buildDot({required bool isActive, required Color color}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 30 : 8,
      decoration: BoxDecoration(
        color: isActive ? color : color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
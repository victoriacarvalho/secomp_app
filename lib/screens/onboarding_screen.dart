import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Cores extraídas da imagem
    final Color primaryRed = const Color(0xFF9A202F); // Vinho
    final Color darkBlue = const Color(0xFF2C3E50);   // Azul escuro/Cinza do fundo

    return Scaffold(
      // O fundo geral é o gradiente superior
      backgroundColor: darkBlue,
      body: Column(
        children: [
          // --- METADE SUPERIOR (Escura com Logo e Ícone) ---
          Expanded(
            flex: 6, // Ocupa 60% da tela (ajustável)
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                // Simulação do fundo geométrico com Gradiente Linear
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    darkBlue,
                    primaryRed.withOpacity(0.8), // Mistura um pouco do vermelho
                    darkBlue,
                  ],
                ),
                // SE VOCÊ TIVER A IMAGEM DE FUNDO, DESCOMENTE ABAIXO:
                /*
                image: DecorationImage(
                  image: AssetImage('assets/images/fundo_triangulos.png'),
                  fit: BoxFit.cover,
                ),
                */
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo ICEA Pequena no topo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('icea', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Futura')),
                        const SizedBox(width: 8),
                        Text('Instituto de Ciências\nExatas e Aplicadas', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    ),

                    const Spacer(),

                    // Texto SECOMP
                    Text(
                      'SECOMP',
                      style: TextStyle(
                        color: primaryRed, // Texto em vermelho escuro sobre o fundo
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),

                    // Texto Agendamentos
                    const Text(
                      'Agendamentos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Ícone de Calendário (Simulando a imagem)
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1), // Fundo leve atrás do ícone
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.calendar_month_outlined, // Ícone de calendário
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),

          // --- METADE INFERIOR (Branca com Texto e Botão) ---
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
                        fontFamily: 'Times New Roman', // Fonte serifada
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

                    // Indicador de Páginas (Bolinhas)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(isActive: true, color: primaryRed),
                        _buildDot(isActive: false, color: primaryRed),
                        _buildDot(isActive: false, color: primaryRed),
                      ],
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
      width: isActive ? 30 : 8, // Se ativo é largo, se não é bolinha
      decoration: BoxDecoration(
        color: isActive ? color : color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
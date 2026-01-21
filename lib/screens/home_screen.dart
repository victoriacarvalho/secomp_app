import 'package:flutter/material.dart';
import 'event_detail_screen.dart';
import 'all_events_screen.dart';
import 'diary_screen.dart';
import 'certificates_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Cores padronizadas do projeto
  final Color primaryRed = const Color(0xFF9A202F);
  final Color backgroundGrey = const Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // --- CABEÇALHO (User info & Notificações) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.blue[100],
                          child: const Icon(Icons.person, color: Colors.blue),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Leonardo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    _buildNotificationIcon(),
                  ],
                ),

                const SizedBox(height: 30),

                // --- TÍTULO PRINCIPAL ---
                const Text(
                  'Explore suas',
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 32,
                    color: Colors.black54,
                  ),
                ),
                _buildSecompTitle(),

                const SizedBox(height: 30),

                // ============================================================
                // 1. SEÇÃO DE SUGESTÕES (Já existia)
                // ============================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sugestões',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Pode levar para uma lista específica de sugestões se quiser
                      },
                      child: Text(
                        'Ver tudo',
                        style: TextStyle(color: primaryRed, fontSize: 16),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Lista Horizontal Sugestões
                SizedBox(
                  height: 330,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildSuggestionCard(
                        context,
                        title: 'Gestão de Carreira',
                        location: 'Auditório ICEA',
                        points: '60',
                        imagePath: 'public/campus.png',
                      ),
                      _buildSuggestionCard(
                        context,
                        title: 'Workshop Flutter',
                        location: 'Lab 04',
                        points: '45',
                        imagePath: 'public/campus.png',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ============================================================
                // 2. NOVA SEÇÃO: EVENTOS POPULARES
                // ============================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Eventos Populares',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navega para a tela de Grid (AllEventsScreen)
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AllEventsScreen()),
                        );
                      },
                      child: Text(
                        'Ver tudo',
                        style: TextStyle(color: primaryRed, fontSize: 16),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Nova Lista Horizontal (Eventos Populares)
                SizedBox(
                  height: 330,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildSuggestionCard(
                        context,
                        title: 'Mineração de dados',
                        location: 'Sala C203',
                        points: '30',
                        imagePath: 'public/campus.png', // Trocamos a imagem aqui se tiver outra
                      ),
                      _buildSuggestionCard(
                        context,
                        title: 'Análise de dados',
                        location: 'Sala H102',
                        points: '25',
                        imagePath: 'public/campus.png',
                      ),
                      _buildSuggestionCard(
                        context,
                        title: 'Avanço da IA',
                        location: 'Auditório',
                        points: '60',
                        imagePath: 'public/campus.png',
                      ),
                    ],
                  ),
                ),

                // Espaço extra no final para não ficar colado na barra inferior
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: const CustomBottomBar(),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildNotificationIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundGrey,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          const Icon(Icons.notifications_none_outlined, size: 28),
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSecompTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Opções ',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Image.asset(
          'public/secomp.png',
          height: 45,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(
      BuildContext context, {
        required String title,
        required String location,
        required String points,
        required String imagePath,
      }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(
              title: title,
              location: location,
              points: points,
              imagePath: imagePath,
            ),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 20, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
                  child: Container(
                    color: backgroundGrey,
                    child: Image.asset(
                      imagePath,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bookmark_border, color: Colors.white),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        points,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(location, style: const TextStyle(color: Colors.grey)),
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

// --- BARRA INFERIOR PADRONIZADA ---
class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5)
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Botão INÍCIO
          _buildNavItem(
              Icons.home_outlined,
              "Início",
              true, // Ativo
              onTap: () {
                // Já na home
              }
          ),

          // Botão AGENDA
          _buildNavItem(
              Icons.calendar_month,
              "Agenda",
              false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AgendaScreen()),
                );
              }
          ),

          // Botão BUSCA
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Busca clicada")));
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFA93244),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0x40A93244), blurRadius: 10, offset: Offset(0, 5))
                ],
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 30),
            ),
          ),

          // Botão CERTIFICADOS
          _buildNavItem(
              Icons.chat_bubble_outline,
              "Certificados",
              false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CertificatesScreen()),
                );
              }
          ),

          // Botão PERFIL
          _buildNavItem(
              Icons.person_outline,
              "Perfil",
              false,
              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              }
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? const Color(0xFFA93244) : Colors.grey, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                  color: isActive ? const Color(0xFFA93244) : Colors.grey,
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ],
        ),
      ),
    );
  }
}
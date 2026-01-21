import 'package:flutter/material.dart';
import 'event_detail_screen.dart';
import 'diary_screen.dart';
import 'all_events_screen.dart';

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

                const SizedBox(height: 40),

                // --- SEÇÃO DE SUGESTÕES ---
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

                // --- LISTA HORIZONTAL DE CARDS ---
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
              ],
            ),
          ),
        ),
      ),

      // --- BARRA DE NAVEGAÇÃO CUSTOMIZADA ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryRed,
        shape: const CircleBorder(),
        child: const Icon(Icons.search, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ERRO CORRIGIDO: Passamos o (context) aqui e mantivemos apenas esta chamada
      bottomNavigationBar: _buildBottomBar(context),
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

  // ERRO CORRIGIDO: Adicionamos BuildContext context como parâmetro obrigatório
  Widget _buildBottomBar(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, 'Início', isSelected: true),

            // Item Agenda com navegação
            _buildNavItem(
              Icons.calendar_month_outlined,
              'Agenda',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AgendaScreen()),
                );
              },
            ),

            const SizedBox(width: 40),
            _buildNavItem(Icons.chat_bubble_outline, 'Certificados'),
            _buildNavItem(Icons.person_outline, 'Perfil'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? primaryRed : Colors.grey),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? primaryRed : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
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
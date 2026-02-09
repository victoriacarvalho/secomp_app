import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Necessário para QuerySnapshot
import '../servicos/autenticacao_servico.dart';
import 'event_detail_screen.dart';
import 'all_events_screen.dart';
import 'diary_screen.dart';
import 'certificates_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final Color primaryRed = const Color(0xFF9A202F);
  final Color backgroundGrey = const Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    final AutenticacaoServico autenticacaoServico = AutenticacaoServico();

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

                // --- CABEÇALHO (Nome do Banco de Dados) ---
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
                        FutureBuilder<Map<String, dynamic>?>(
                          future: autenticacaoServico.getDadosUsuarioLogado(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text("...");
                            }
                            String nomeUsuario = snapshot.data?['nome'] ?? 'Usuário';
                            return Text(
                              nomeUsuario,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    _buildNotificationIcon(context),
                  ],
                ),

                const SizedBox(height: 30),
                const Text(
                  'Explore suas',
                  style: TextStyle(fontFamily: 'Times New Roman', fontSize: 32, color: Colors.black54),
                ),
                _buildSecompTitle(),
                const SizedBox(height: 30),

                // --- SEÇÃO DE EVENTOS DO BANCO (Substitui Sugestões e Populares) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Próximos Eventos',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AllEventsScreen()),
                        );
                      },
                      child: Text('Ver tudo', style: TextStyle(color: primaryRed, fontSize: 16)),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // LISTA DINÂMICA VIA STREAMBUILDER
                StreamBuilder<QuerySnapshot>(
                  stream: autenticacaoServico.getEventos(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 330,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const SizedBox(
                        height: 100,
                        child: Center(child: Text("Nenhum evento cadastrado.")),
                      );
                    }

                    var eventos = snapshot.data!.docs;

                    return SizedBox(
                      height: 330,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: eventos.length,
                        itemBuilder: (context, index) {
                          var dados = eventos[index].data() as Map<String, dynamic>;

                          return _buildSuggestionCard(
                            context,
                            title: dados['titulo'] ?? 'Sem título',
                            location: dados['local'] ?? 'Local indefinido',
                            points: dados['pontos']?.toString() ?? '0',
                            imagePath: 'public/campus.png', // Pode ser alterado para dados['imagemUrl']
                          );
                        },
                      ),
                    );
                  },
                ),

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
  Widget _buildNotificationIcon(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen())),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: backgroundGrey, shape: BoxShape.circle),
        child: const Icon(Icons.notifications_none_outlined, size: 28),
      ),
    );
  }

  Widget _buildSecompTitle() {
    return Row(
      children: [
        const Text('Opções ', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
        Image.asset('public/secomp.png', height: 45, errorBuilder: (c, e, s) => const Icon(Icons.error)),
      ],
    );
  }

  Widget _buildSuggestionCard(BuildContext context, {required String title, required String location, required String points, required String imagePath}) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailScreen(
            eventData: {
              'titulo': title,         // Mapeia sua variavel 'title' para a chave 'titulo'
              'local': location,       // Mapeia 'location' para 'local'
              'imageUrl': imagePath,   // Mapeia 'imagePath' para 'imageUrl'
              'descricao': 'Sem descrição detalhada.', // Valor padrão
              'palestrantePrincipal': 'Organização',   // Valor padrão
              'vagas': 0,                              // Valor padrão
              'isOnline': false,                       // Valor padrão
              'data': Timestamp.now(),                 // Valor padrão (agora)
            },
          ),
        ),
      ),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 20, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
              child: Image.asset(imagePath, height: 220, width: double.infinity, fit: BoxFit.contain),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                      Text(points, style: const TextStyle(fontSize: 16, color: Colors.grey)),
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

// CustomBottomBar permanece igual ao seu código original...
class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, "Início", true),
          _buildNavItem(Icons.calendar_month, "Agenda", false, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AgendaScreen()))),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFFA93244), shape: BoxShape.circle),
            child: const Icon(Icons.search, color: Colors.white, size: 30),
          ),
          _buildNavItem(Icons.chat_bubble_outline, "Certificados", false, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CertificatesScreen()))),
          _buildNavItem(Icons.person_outline, "Perfil", false, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()))),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? const Color(0xFFA93244) : Colors.grey),
          Text(label, style: TextStyle(color: isActive ? const Color(0xFFA93244) : Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }
}
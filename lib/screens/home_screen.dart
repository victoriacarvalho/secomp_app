import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../servicos/autenticacao_servico.dart';
import 'create_event_screen.dart';
import 'event_detail_screen.dart';
import 'diary_screen.dart';
import 'profile_screen.dart';
import 'certificates_screen.dart';
import 'all_events_screen.dart';
import 'search_screen.dart';
import '../servicos/notificacao_servico.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AutenticacaoServico _authService = AutenticacaoServico();

  String nomeUsuario = "Visitante";
  String? fotoPerfilUrl;
  bool _isOrganizador = false;
  final Color primaryColor = const Color(0xFFA93244);

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
    NotificacaoServico.listarAgendamentos();
  }

  // Carrega dados básicos do usuário logado e valida se é organizador UFOP
  void _carregarUsuario() {
    User? user = FirebaseAuth.instance.currentUser;
    bool isAdmin = false;
    if (user?.email != null && user!.email!.endsWith("@ufop.edu.br")) {
      isAdmin = true;
    }

    setState(() {
      nomeUsuario = user?.displayName?.split(" ")[0] ?? "Visitante";
      fotoPerfilUrl = user?.photoURL;
      _isOrganizador = isAdmin;
    });
  }

  Widget _buildSecompTitle() {
    return Row(
      children: [
        const Text('Opções ', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
        Image.asset(
          'public/secomp.png',
          height: 45,
          errorBuilder: (c, e, s) => const Icon(Icons.code, size: 45, color: Color(0xFFA93244)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CustomBottomBar(activeIndex: 0),
      floatingActionButton: _isOrganizador
          ? FloatingActionButton(
              backgroundColor: primaryColor,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateEventScreen())),
            )
          : null,
      body: SafeArea(
        // Remove efeito visual e físico de esticamento (over-scroll)
        child: ScrollConfiguration(
          behavior: NoOverscrollBehavior(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Cabeçalho (Avatar e Nome)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: fotoPerfilUrl != null ? NetworkImage(fotoPerfilUrl!) : null,
                        child: fotoPerfilUrl == null
                            ? Text(nomeUsuario[0].toUpperCase(), style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Text(nomeUsuario, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 2. Título principal
                const Text('Explore suas', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 32, color: Colors.black54)),
                _buildSecompTitle(),
                const SizedBox(height: 30),

                // 3. Seção de Sugestões
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Sugestões", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AllEventsScreen())),
                      child: Text("Ver todos", style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 4. Lista Vertical (Feed de Eventos)
                StreamBuilder<QuerySnapshot>(
                  stream: _authService.getEventosStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Nenhum evento encontrado."));

                    var docs = snapshot.data!.docs;
                    int itemCount = docs.length > 2 ? 2 : docs.length;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        var doc = docs[index];
                        var dados = doc.data() as Map<String, dynamic>;
                        dados['id'] = doc.id;
                        if (dados['data'] is Timestamp) dados['data'] = (dados['data'] as Timestamp).toDate();
                        return _buildWideCard(context, dados);
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideCard(BuildContext context, Map<String, dynamic> event) {
    int vagas = int.tryParse(event['vagas'].toString()) ?? 0;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(eventData: event))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: EventImage(imageUrl: event['imageUrl'], fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event['titulo'] ?? "Sem título", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 5),
                      Expanded(child: Text(event['isOnline'] == true ? "Online" : (event['local'] ?? "A definir"), style: TextStyle(color: Colors.grey[600], fontSize: 14), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(vagas > 0 ? "$vagas vagas disponíveis" : "Esgotado", style: TextStyle(color: vagas > 0 ? const Color(0xFFA93244) : Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
                      const Icon(Icons.arrow_forward, size: 18, color: Colors.grey),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoOverscrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}

class CustomBottomBar extends StatelessWidget {
  final int activeIndex;
  const CustomBottomBar({super.key, required this.activeIndex});

  void _navigateTo(BuildContext context, int index) {
    if (index == activeIndex) return;
    Widget page;
    switch (index) {
      case 0: page = const HomeScreen(); break;
      case 1: page = const AgendaScreen(); break;
      case 2: page = const CertificatesScreen(); break;
      case 3: page = const ProfileScreen(); break;
      default: return;
    }
    Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => page, transitionDuration: Duration.zero));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home, "Início", 0),
          _buildNavItem(context, Icons.calendar_month, "Agenda", 1),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFA93244), 
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 28),
            ),
          ),
          _buildNavItem(context, Icons.chat_bubble_outline, "Certificados", 2),
          _buildNavItem(context, Icons.person_outline, "Perfil", 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    bool isActive = activeIndex == index;
    return GestureDetector(
      onTap: () => _navigateTo(context, index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? const Color(0xFFA93244) : Colors.grey, size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isActive ? const Color(0xFFA93244) : Colors.grey, fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

class EventImage extends StatelessWidget {
  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  static const String _defaultAsset = "assets/images/icea.png";

  const EventImage({super.key, required this.imageUrl, this.height, this.width, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) return Image.asset(_defaultAsset, height: height, width: width, fit: fit);
    if (imageUrl!.startsWith('http')) {
      return Image.network(
        imageUrl!, height: height, width: width, fit: fit,
        loadingBuilder: (context, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(color: Color(0xFF9A202F))),
        errorBuilder: (context, error, stack) => Image.asset(_defaultAsset, height: height, width: width, fit: fit),
      );
    }
    return Image.asset(imageUrl!, height: height, width: width, fit: fit, errorBuilder: (c, e, s) => Image.asset(_defaultAsset));
  }
}
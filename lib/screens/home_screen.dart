import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../servicos/autenticacao_servico.dart';
import 'create_event_screen.dart';
import 'event_detail_screen.dart';
import 'diary_screen.dart';
import 'profile_screen.dart';
import 'certificates_screen.dart';
import 'all_events_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AutenticacaoServico _authService = AutenticacaoServico();

  // Dados do Usuário
  String nomeUsuario = "Visitante";
  String? fotoPerfilUrl; // Variável para guardar a URL da foto
  bool _isOrganizador = false;

  final Color primaryColor = const Color(0xFFA93244);

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  void _carregarUsuario() {
    User? user = FirebaseAuth.instance.currentUser;

    // Verifica se é Admin/Organizador
    bool isAdmin = false;
    if (user != null && user.email != null) {
      if (user.email!.endsWith("@ufop.edu.br")) {
        isAdmin = true;
      }
    }

    // Pega o primeiro nome
    String primeiroNome = "Visitante";
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      primeiroNome = user.displayName!.split(" ")[0];
    }

    setState(() {
      nomeUsuario = primeiroNome;
      fotoPerfilUrl = user?.photoURL; // Pega a foto do Firebase/Google
      _isOrganizador = isAdmin;
    });
  }

  Widget _buildSecompTitle() {
    return Row(
      children: [
        const Text(
            'Opções ',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)
        ),
        Image.asset(
          'public/secomp.png',
          height: 45,
          errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, color: Colors.red),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: const CustomBottomBar(activeIndex: 0),

      // FAB para Organizador
      floatingActionButton: _isOrganizador
          ? FloatingActionButton(
        backgroundColor: primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateEventScreen()));
        },
      )
          : null,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // --- 1. CABEÇALHO (HEADER) IDÊNTICO À IMAGEM ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // CÁPSULA DE PERFIL
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
                        // AVATAR (Foto ou Inicial)
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: fotoPerfilUrl != null
                              ? NetworkImage(fotoPerfilUrl!)
                              : null,
                          child: fotoPerfilUrl == null
                              ? Text(
                            nomeUsuario.isNotEmpty ? nomeUsuario[0].toUpperCase() : "U",
                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                          )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        // NOME
                        Text(
                            nomeUsuario,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black87
                            )
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),

                  // BOTÃO DE NOTIFICAÇÃO
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200),
                        color: Colors.white,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.notifications_outlined, size: 24, color: Colors.black87),

                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),


              const SizedBox(height: 30),

              // 2. TÍTULO COM "RABISCO" VERMELHO
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explore suas',
                    style: TextStyle(
                        fontFamily: 'Times New Roman',
                        fontSize: 32,
                        color: Colors.black54
                    ),
                  ),
                  _buildSecompTitle(), // <--- Aqui você apenas chama a função
                ],
              ),

              const SizedBox(height: 30),

              const SizedBox(height: 25),

              // 3. SUGESTÕES + BOTÃO DE AÇÃO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Sugestões", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () {
                      if (_isOrganizador) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateEventScreen()));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AllEventsScreen()));
                      }
                    },
                    child: Text(
                        _isOrganizador ? "Criar +" : "Ver todos",
                        style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.bold)
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 4. LISTA DE EVENTOS
              SizedBox(
                height: 320,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _authService.getEventosStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return const Center(child: Text("Erro ao carregar"));
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("Nenhum evento encontrado."));
                    }

                    var docs = snapshot.data!.docs;

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        var doc = docs[index];
                        var dados = doc.data() as Map<String, dynamic>;
                        dados['id'] = doc.id;
                        if (dados['data'] is Timestamp) {
                          dados['data'] = (dados['data'] as Timestamp).toDate();
                        }
                        return _buildBigCard(context, dados);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- CARD DE EVENTO ---
  Widget _buildBigCard(BuildContext context, Map<String, dynamic> event) {
    String imageUrl = event['imageUrl'] ?? "";
    ImageProvider imagemBg;
    if (imageUrl.startsWith('http')) {
      imagemBg = NetworkImage(imageUrl);
    } else if (imageUrl.isNotEmpty) {
      imagemBg = FileImage(File(imageUrl));
    } else {
      imagemBg = const AssetImage('assets/images/event_placeholder.jpg');
    }

    int vagasRestantes = 0;
    if (event['vagas'] != null) {
      vagasRestantes = int.tryParse(event['vagas'].toString()) ?? 0;
    }

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(eventData: event))),
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 20, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(image: imagemBg, fit: BoxFit.cover),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                      child: const Icon(Icons.bookmark_border, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        event['titulo'] ?? "Sem título",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        maxLines: 1, overflow: TextOverflow.ellipsis
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(event['isOnline'] == true ? "Online" : (event['local'] ?? "A definir"), style: TextStyle(color: Colors.grey[500], fontSize: 13), overflow: TextOverflow.ellipsis)),
                        Text("$vagasRestantes", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildAvatarStack(),
                        const SizedBox(width: 8),
                        Text(vagasRestantes > 0 ? "+$vagasRestantes vagas" : "Esgotado", style: TextStyle(color: vagasRestantes > 0 ? Colors.grey[600] : Colors.red, fontSize: 12, fontWeight: FontWeight.bold))
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStack() {
    return SizedBox(
      width: 50, height: 24,
      child: Stack(
        children: [
          const Positioned(left: 0, child: CircleAvatar(radius: 12, backgroundColor: Colors.blue)),
          const Positioned(left: 15, child: CircleAvatar(radius: 12, backgroundColor: Colors.red)),
          Positioned(left: 30, child: CircleAvatar(radius: 12, backgroundColor: Colors.amber[200])),
        ],
      ),
    );
  }
}

// --- PAINTER PARA O SUBLINHADO CURVO ---
class UnderlinePainter extends CustomPainter {
  final Color color;
  UnderlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var path = Path();
    // Cria uma curva suave para baixo (sorriso)
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(
        size.width / 2, size.height, // Ponto de controle (meio baixo)
        size.width, size.height * 0.4 // Ponto final (direita cima)
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// --- BARRA INFERIOR ---
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
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Color(0xFFA93244), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x40A93244), blurRadius: 10, offset: Offset(0, 5))]),
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
    final Color primaryColor = const Color(0xFFA93244);
    return GestureDetector(
      onTap: () => _navigateTo(context, index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? primaryColor : Colors.grey, size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isActive ? primaryColor : Colors.grey, fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
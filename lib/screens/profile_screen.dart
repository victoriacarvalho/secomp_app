import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../servicos/autenticacao_servico.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import 'personal_data_screen.dart';
import 'create_event_screen.dart';
import 'edit_profile_screen.dart';
import 'saved_events_screen.dart';
import 'checkin_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AutenticacaoServico authService = AutenticacaoServico();
  final Color primaryRed = const Color(0xFF9A202F);
  final Color textGrey = const Color(0xFF666666);

  // Variáveis para armazenar os dados carregados
  Map<String, dynamic>? _dadosUsuario;
  int _stat1 = 0, _stat2 = 0, _stat3 = 0;
  bool _isAdmin = false;

  // FUNÇÃO MESTRE: Aguarda todos os Futures antes de liberar a UI
  Future<void> _carregarDadosCompletos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Dispara as consultas ao Firestore em paralelo para melhor performance
    final resultados = await Future.wait([
      authService.getDadosUsuarioLogado(),
      _buscarEstatisticas(user.uid),
    ]);

    _dadosUsuario = resultados[0] as Map<String, dynamic>?;
    _isAdmin = (_dadosUsuario?['role'] == 'admin') || 
               (user.email?.endsWith('@ufop.edu.br') ?? false);
  }

  Future<void> _buscarEstatisticas(String uid) async {
    final firestore = FirebaseFirestore.instance;
    final email = FirebaseAuth.instance.currentUser?.email ?? "";
    bool isAdmin = email.endsWith('@ufop.edu.br');

    if (isAdmin) {
      final eventosQuery = await firestore
          .collection('eventos')
          .where('organizadorUid', isEqualTo: uid)
          .get();

      int somaInscritos = 0;
      int somaPresencas = 0;

      for (var doc in eventosQuery.docs) {
        var qInscritos = await firestore.collection('inscricoes').where('eventId', isEqualTo: doc.id).count().get();
        var qPresencas = await firestore.collection('inscricoes').where('eventId', isEqualTo: doc.id).where('presencaConfirmada', isEqualTo: true).count().get();

        somaInscritos += qInscritos.count ?? 0;
        somaPresencas += qPresencas.count ?? 0;
      }

      _stat1 = eventosQuery.docs.length;
      _stat2 = somaInscritos;
      _stat3 = somaPresencas;
    } else {
      final minhasInscricoes = await firestore
          .collection('inscricoes')
          .where('uidParticipante', isEqualTo: uid)
          .count()
          .get();

      _stat1 = minhasInscricoes.count ?? 0;
      _stat2 = 0; // Pode ser usado para Presenças futuras
      _stat3 = 0; // Pode ser usado para Certificados
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _carregarDadosCompletos(),
      builder: (context, snapshot) {
        // Enquanto carrega, mostra apenas o loading centralizado
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator(color: primaryRed)),
            bottomNavigationBar: const CustomBottomBar(activeIndex: 3),
          );
        }

        if (_dadosUsuario == null) {
          return const Scaffold(body: Center(child: Text("Erro ao carregar dados.")));
        }

        String nome = _dadosUsuario!['nome'] ?? "Usuário";
        String email = _dadosUsuario!['email'] ?? "";
        String? fotoUrl = _dadosUsuario!['fotoUrl'];

        return Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: const CustomBottomBar(activeIndex: 3),
          appBar: _buildAppBar(context, _dadosUsuario!),
          body: ScrollConfiguration(
            behavior: NoOverscrollBehavior(),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(nome, email, fotoUrl),
                    const SizedBox(height: 35),
                    
                    // Stats já aparecem com valores reais aqui
                    _buildStatsContainer(
                      _stat1.toString(), 
                      _stat2.toString(), 
                      _stat3.toString(), 
                      primaryRed, 
                      labels: _isAdmin 
                        ? ["Eventos Criados", "Total Inscritos", "Presenças"] 
                        : ["Inscritos", "Presenças", "Certificados"]
                    ),
                    
                    const SizedBox(height: 30),
                    _buildMenuContainer(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- WIDGETS AUXILIARES (UI) ---

  PreferredSizeWidget _buildAppBar(BuildContext context, Map<String, dynamic> dados) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: const Text("Perfil", style: TextStyle(fontFamily: 'Times New Roman', fontWeight: FontWeight.w500, fontSize: 22, color: Colors.black87)),
      actions: [
        IconButton(
          onPressed: () async {
            bool? atualizou = await Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(dadosAtuais: dados)));
            if (atualizou == true) setState(() {});
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red[50]),
            child: Icon(Icons.edit, size: 20, color: primaryRed),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildHeader(String nome, String email, String? fotoUrl) {
    return Column(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: primaryRed.withOpacity(0.1),
          backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl) : null,
          child: fotoUrl == null 
            ? Text(nome[0].toUpperCase(), style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: primaryRed)) 
            : null,
        ),
        const SizedBox(height: 15),
        Text(nome, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(email, style: TextStyle(fontSize: 14, color: textGrey)),
        if (_isAdmin) _buildAdminBadge(),
      ],
    );
  }

  Widget _buildAdminBadge() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
      child: Text("ORGANIZADOR", style: TextStyle(color: Colors.grey[700], fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _buildStatsContainer(String v1, String v2, String v3, Color color, {required List<String> labels}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(labels[0], v1, color),
          _buildVerticalDivider(),
          _buildStatItem(labels[1], v2, color),
          _buildVerticalDivider(),
          _buildStatItem(labels[2], v3, color),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 5),
          Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() => Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.2));

  Widget _buildMenuContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          if (_isAdmin) ...[
            _buildMenuItem(Icons.add_circle_outline, "Criar Novo Evento", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEventScreen()))),
            _buildMenuItem(Icons.playlist_add_check, "Gerenciar Presença", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckInScreen()))),
            const Divider(),
          ],
          _buildMenuItem(Icons.person_outline, "Dados Pessoais", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalDataScreen()))),
          _buildMenuItem(Icons.bookmark_border, "Eventos Salvos", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedEventsScreen()))),
          _buildMenuItem(Icons.logout, "Sair da conta", color: Colors.redAccent, onTap: () async {
            await authService.deslogarUsuario();
            if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()), (route) => false);
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap, Color color = Colors.black87}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color == Colors.black87 ? Colors.grey[600] : color, size: 22),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }
}
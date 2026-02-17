import 'package:flutter/material.dart';
import '../servicos/autenticacao_servico.dart';
import 'onboarding_screen.dart';
import 'personal_data_screen.dart';
import 'create_event_screen.dart';
import 'edit_profile_screen.dart';
import 'home_screen.dart';
import 'saved_events_screen.dart';
import 'checkin_screen.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'diary_screen.dart'; 
import 'certificates_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AutenticacaoServico authService = AutenticacaoServico();
  final Color primaryRed = const Color(0xFF9A202F);
  final Color textGrey = const Color(0xFF666666);

  int _totalInscricoesParticipante = 0;
  int _totalInscritosMeusEventos = 0; 
  int _totalEventosCriados = 0;
  int _totalPresencasReal = 0; // Novo: Conta check-ins confirmados

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: authService.getDadosUsuarioLogado(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator(color: primaryRed)),
            bottomNavigationBar: const CustomBottomBar(activeIndex: 3),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text("Erro ao carregar dados do perfil.")),
            bottomNavigationBar: CustomBottomBar(activeIndex: 3),
          );
        }

        var dados = snapshot.data!;
        String nome = dados['nome'] ?? "Usuário";
        String email = dados['email'] ?? "Sem e-mail";
        String? fotoUrl = dados['fotoUrl'];
        String uid = FirebaseAuth.instance.currentUser!.uid;
        
        bool isAdmin = (dados['role'] == 'admin') || (email.endsWith('@ufop.edu.br'));

        return FutureBuilder(
          future: _carregarEstatisticas(uid, isAdmin),
          builder: (context, snapshotStats) {
            
            ImageProvider? imageProvider;
            if (fotoUrl != null && fotoUrl.isNotEmpty) {
              imageProvider = NetworkImage(fotoUrl);
            }

            return Scaffold(
              backgroundColor: Colors.white,
              bottomNavigationBar: const CustomBottomBar(activeIndex: 3),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                automaticallyImplyLeading: false, 
                title: const Text(
                  "Perfil",
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                    color: Colors.black87,
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () async {
                      bool? atualizou = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(dadosAtuais: dados),
                        ),
                      );
                      if (atualizou == true) setState(() {});
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 20),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red[50],
                      ),
                      child: Icon(Icons.edit, size: 20, color: primaryRed),
                    ),
                  )
                ],
              ),
              
              body: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        Center(
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 4),
                                  boxShadow: [
                                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 55,
                                  backgroundColor: primaryRed.withOpacity(0.1),
                                  backgroundImage: imageProvider,
                                  child: imageProvider == null
                                      ? Text(
                                          nome.isNotEmpty ? nome[0].toUpperCase() : "?",
                                          style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: primaryRed,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                nome,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              const SizedBox(height: 5),
                              Text(email, style: TextStyle(fontSize: 14, color: textGrey)),
                              
                              if (isAdmin)
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200], 
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "ORGANIZADOR",
                                    style: TextStyle(
                                      color: Colors.grey[700], 
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 35),

                        // --- ESTATÍSTICAS REAIS ---
                        if (isAdmin)
                          _buildStatsContainer(
                            _totalEventosCriados.toString(), 
                            _totalInscritosMeusEventos.toString(), 
                            _totalPresencasReal.toString(), 
                            primaryRed, 
                            labels: ["Eventos Criados", "Total Inscritos", "Presenças (Check-in)"]
                          )
                        else
                          _buildStatsContainer(
                            _totalInscricoesParticipante.toString(),
                            "0", // Presenças (teria que filtrar)
                            "0", // Certificados
                            primaryRed, 
                            labels: ["Inscritos", "Presenças", "Certificados"]
                          ),
                        
                        const SizedBox(height: 30),

                        // MENU DE OPÇÕES
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.withOpacity(0.1)),
                              boxShadow: [
                                BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                              ]
                          ),
                          child: Column(
                            children: [
                              
                              if (isAdmin) ...[
                                Padding(
                                  padding: const EdgeInsets.only(left: 20, top: 15, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Painel", style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ),
                                _buildMenuItem(
                                  Icons.add_circle_outline,
                                  "Criar Novo Evento",
                                  color: Colors.black87,
                                  onTap: () async {
                                    await Navigator.push(
                                      context, 
                                      MaterialPageRoute(builder: (context) => const CreateEventScreen())
                                    );
                                    if (mounted) setState(() {}); 
                                  },
                                ),
                                _buildDividerLine(),
                                
                                _buildMenuItem(
                                  Icons.playlist_add_check, 
                                  "Gerenciar Presença (Check-in)",
                                  onTap: () async {
                                    await Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckInScreen()));
                                    if (mounted) setState(() {}); // Atualiza números ao voltar
                                  },
                                ),
                                
                                _buildDividerLine(),
                                Container(height: 8, color: Colors.grey[50]), 
                              ],

                              Padding(
                                  padding: const EdgeInsets.only(left: 20, top: 15, bottom: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Minha Conta", style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ),

                              _buildMenuItem(
                                Icons.person_outline,
                                "Dados Pessoais",
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalDataScreen())),
                              ),
                              _buildDividerLine(),
                              _buildMenuItem(
                                Icons.bookmark_border, 
                                "Meus Eventos Salvos",
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedEventsScreen()));
                                }
                              ),
                              _buildDividerLine(),
                              
                              if (!isAdmin) ...[
                                 _buildMenuItem(Icons.history, "Histórico de Participação"),
                                 _buildDividerLine(),
                              ],

                              _buildMenuItem(
                                Icons.logout,
                                "Sair da conta",
                                color: Colors.redAccent,
                                onTap: () async {
                                   await authService.deslogarUsuario();
                                   if (mounted) {
                                     Navigator.pushAndRemoveUntil(
                                       context,
                                       MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                                       (route) => false,
                                     );
                                   }
                                },
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  // --- FUNÇÃO CORRIGIDA: CONTA DIRETAMENTE NA COLEÇÃO DE INSCRIÇÕES ---
  Future<void> _carregarEstatisticas(String uid, bool isAdmin) async {
    final firestore = FirebaseFirestore.instance;

    if (isAdmin) {
      // 1. Pegar todos os eventos criados por mim
      final eventosQuery = await firestore
          .collection('eventos')
          .where('organizadorUid', isEqualTo: uid)
          .get();

      int somaInscritos = 0;
      int somaPresencas = 0;

      // 2. Para cada evento, contar quantas inscrições reais existem
      for (var doc in eventosQuery.docs) {
        
        // Conta Total Inscritos
        var queryInscritos = await firestore
            .collection('inscricoes')
            .where('eventId', isEqualTo: doc.id)
            .count()
            .get();
        
        // Conta Presenças (Check-in feito)
        var queryPresencas = await firestore
            .collection('inscricoes')
            .where('eventId', isEqualTo: doc.id)
            .where('presencaConfirmada', isEqualTo: true)
            .count()
            .get();

        somaInscritos += queryInscritos.count ?? 0;
        somaPresencas += queryPresencas.count ?? 0;
      }

      _totalEventosCriados = eventosQuery.docs.length;
      _totalInscritosMeusEventos = somaInscritos;
      _totalPresencasReal = somaPresencas;

    } else {
      // PARTICIPANTE: Conta onde 'uidParticipante' é igual ao meu ID
      final minhasInscricoes = await firestore
          .collection('inscricoes')
          .where('uidParticipante', isEqualTo: uid)
          .count()
          .get();

      _totalInscricoesParticipante = minhasInscricoes.count ?? 0;
    }
  }

  Widget _buildStatsContainer(String v1, String v2, String v3, Color color, {required List<String> labels}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: _buildStatItem(labels[0], v1, color)),
          _buildVerticalDivider(),
          Expanded(child: _buildStatItem(labels[1], v2, color)),
          _buildVerticalDivider(),
          Expanded(child: _buildStatItem(labels[2], v3, color)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String count, Color color) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            label, 
            style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500), 
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 5),
        Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.2));
  }

  Widget _buildDividerLine() {
    return Divider(height: 1, color: Colors.grey.withOpacity(0.1), indent: 20, endIndent: 20);
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap, Color color = Colors.black87}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color == Colors.black87 ? Colors.grey[600] : color, size: 22),
      title: Text(
        title,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
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
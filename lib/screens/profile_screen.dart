import 'package:flutter/material.dart';
import '../servicos/autenticacao_servico.dart';
import 'onboarding_screen.dart';
import 'personal_data_screen.dart';
import 'create_event_screen.dart';
import 'edit_profile_screen.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AutenticacaoServico authService = AutenticacaoServico();
  final Color primaryRed = const Color(0xFF9A202F);
  final Color textGrey = const Color(0xFF666666);


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: authService.getDadosUsuarioLogado(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator(color: primaryRed)),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text("Erro ao carregar dados do perfil.")),
          );
        }

        var dados = snapshot.data!;
        String nome = dados['nome'] ?? "Usuário";
        String email = dados['email'] ?? "Sem e-mail";
        String? fotoUrl = dados['fotoUrl'];
        bool isAdmin = dados['role'] == 'admin'; // ou verifique o email @ufop

        // Tratamento da imagem (Rede ou Inicial)
        ImageProvider? imageProvider;
        if (fotoUrl != null && fotoUrl.isNotEmpty) {
          imageProvider = NetworkImage(fotoUrl);
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ), ),
            ),
            title: const Text(
              "Perfil",
              style: TextStyle(
                fontFamily: 'Times New Roman',
                fontWeight: FontWeight.w500,
                fontSize: 22,
                color: Colors.black87,
              ),
            ),
            // --- AQUI ESTÁ O LÁPIS ---
            actions: [
              GestureDetector(
                onTap: () async {

                  bool? atualizou = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(dadosAtuais: dados),
                    ),
                  );

                },
                child: Container(
                  margin: const EdgeInsets.only(right: 20),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red[50], // Fundo vermelhinho claro
                  ),
                  child: Icon(Icons.edit, size: 20, color: primaryRed),
                ),
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Foto de Perfil com Inicial do Nome
                  Center(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
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
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          email,
                          style: TextStyle(fontSize: 14, color: textGrey),
                        ),
                        if (isAdmin)
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "ORGANIZADOR",
                              style: TextStyle(
                                color: primaryRed,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  _buildStatsContainer("05", "02", "00", primaryRed),
                  const SizedBox(height: 30),

                  // Menu de Opções
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0,5))
                        ]
                    ),
                    child: Column(
                      children: [
                        // --- OPÇÃO EXCLUSIVA PARA ADMIN ---
                        if (isAdmin) ...[
                          _buildMenuItem(
                            Icons.add_circle_outline,
                            "Criar Novo Evento",
                            color: primaryRed,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CreateEventScreen()),
                              );
                            },
                          ),
                          _buildDividerLine(),
                        ],

                        _buildMenuItem(
                          Icons.person_outline,
                          "Dados Pessoais",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PersonalDataScreen()),
                            );
                          },
                        ),
                        _buildDividerLine(),
                        _buildMenuItem(Icons.bookmark_border, "Meus Eventos Salvos"),
                        _buildDividerLine(),
                        _buildMenuItem(Icons.history, "Histórico de Participação"),
                        _buildDividerLine(),

                        // LOGOUT
                        _buildMenuItem(
                          Icons.logout,
                          "Sair da conta",
                          color: Colors.redAccent,
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                                  (route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsContainer(String inscritos, String checkin, String certificados, Color color) {
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
          _buildStatItem("Inscritos", inscritos, color),
          _buildVerticalDivider(),
          _buildStatItem("Check-in", checkin, color),
          _buildVerticalDivider(),
          _buildStatItem("Certificados", certificados, color),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String count, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
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
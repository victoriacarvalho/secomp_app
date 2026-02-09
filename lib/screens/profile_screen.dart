import 'package:flutter/material.dart';
import '../servicos/autenticacao_servico.dart';
import 'onboarding_screen.dart';
import 'personal_data_screen.dart';
import 'create_event_screen.dart'; // IMPORTAÇÃO NECESSÁRIA

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AutenticacaoServico authService = AutenticacaoServico();
    const Color primaryRed = Color(0xFF9A202F);
    const Color textGrey = Color(0xFF666666);

    return FutureBuilder<Map<String, dynamic>?>(
      future: authService.getDadosUsuarioLogado(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
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
        bool isAdmin = dados['role'] == 'admin';

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
              onPressed: () => Navigator.pop(context),
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
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: primaryRed.withOpacity(0.1),
                          child: Text(
                            nome.isNotEmpty ? nome[0].toUpperCase() : "?",
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: primaryRed,
                            ),
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
                          style: const TextStyle(fontSize: 14, color: textGrey),
                        ),
                        if (isAdmin)
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
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
                  _buildStatsContainer(primaryRed),
                  const SizedBox(height: 30),

                  // Menu de Opções
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
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

  // --- Widgets Auxiliares permanecem os mesmos ---
  Widget _buildStatsContainer(Color color) {
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
          _buildStatItem("Inscritos", "05", color),
          _buildVerticalDivider(),
          _buildStatItem("Check-in", "02", color),
          _buildVerticalDivider(),
          _buildStatItem("Certificados", "00", color),
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
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {

  final bool isAdmin = true;

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFA93244);

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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: primaryRed),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Editar Perfil")));
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 1. FOTO E NOME
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.pink[50], // Fundo rosa claro da imagem
                      backgroundImage: const NetworkImage('https://i.pravatar.cc/300?img=12'), // Imagem ilustrativa
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Leonardo",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isAdmin ? "admin@secomp.com" : "leonardo@gmail.com", // Muda email se for admin
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    if (isAdmin)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: primaryRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text("Administrador", style: TextStyle(color: primaryRed, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 2. ESTATÍSTICAS (Container com sombra)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem("Agendados", "360", primaryRed),
                    _buildDivider(),
                    _buildStatItem("Check -in", "238", primaryRed),
                    _buildDivider(),
                    _buildStatItem("Salvos", "473", primaryRed),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 3. MENU DE OPÇÕES (Lista agrupada)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  // Na imagem o menu parece limpo, sem muita sombra, talvez uma borda sutil ou apenas layout
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(Icons.person_outline, "Meu perfil", onTap: (){}),
                    _buildDividerLine(),
                    _buildMenuItem(Icons.bookmark_border, "Eventos salvos", onTap: (){}),
                    _buildDividerLine(),
                    _buildMenuItem(Icons.rocket_launch_outlined, "Próximos eventos", onTap: (){}),

                    // --- ÁREA EXCLUSIVA DE ADMIN ---
                    if (isAdmin) ...[
                      _buildDividerLine(),
                      _buildMenuItem(
                          Icons.admin_panel_settings_outlined,
                          "Gerenciar Eventos",
                          isHighlight: true, // Destaque visual
                          onTap: (){}
                      ),
                      _buildDividerLine(),
                      _buildMenuItem(
                          Icons.qr_code_scanner,
                          "Leitor de QR Code",
                          isHighlight: true,
                          onTap: (){}
                      ),
                    ],
                    // -------------------------------

                    _buildDividerLine(),
                    _buildMenuItem(Icons.settings_outlined, "Configurações", onTap: (){}),
                    _buildDividerLine(),
                    _buildMenuItem(Icons.public, "Sobre", onTap: (){}),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets Auxiliares ---

  Widget _buildStatItem(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildDividerLine() {
    return Divider(height: 1, color: Colors.grey.withOpacity(0.1), indent: 20, endIndent: 20);
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap, bool isHighlight = false}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isHighlight ? const Color(0xFFA93244) : Colors.grey[600], size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isHighlight ? const Color(0xFFA93244) : Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }
}
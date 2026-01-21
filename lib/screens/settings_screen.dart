import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  bool _biometrics = true;

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
          "Configurações",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Geral", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),

            _buildSwitchTile("Notificações Push", "Receber alertas de eventos", _notificationsEnabled, (val) {
              setState(() => _notificationsEnabled = val);
            }),
            _buildSwitchTile("Modo Escuro", "Economizar bateria", _darkMode, (val) {
              setState(() => _darkMode = val);
            }),
            _buildSwitchTile("Biometria", "Login com impressão digital", _biometrics, (val) {
              setState(() => _biometrics = val);
            }),

            const SizedBox(height: 30),
            const Text("Conta", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),

            _buildActionTile(Icons.lock_outline, "Alterar Senha"),
            _buildActionTile(Icons.language, "Idioma"),
            _buildActionTile(Icons.help_outline, "Ajuda e Suporte"),

            const Spacer(),

            // Botão de Sair
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  // Lógica de logout iria aqui
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryRed),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                child: const Text("Sair da Conta", style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      activeColor: const Color(0xFFA93244),
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildActionTile(IconData icon, String title) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
        child: Icon(icon, color: Colors.black54, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () {},
    );
  }
}
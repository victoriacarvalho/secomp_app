import 'package:flutter/material.dart';
import '../servicos/autenticacao_servico.dart';
import 'home_screen.dart'; 

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final AutenticacaoServico _authService = AutenticacaoServico();
  final Color primaryRed = const Color(0xFF9A202F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Dados Pessoais",
          style: TextStyle(
            fontFamily: 'Times New Roman',
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _authService.getDadosUsuarioLogado(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryRed));
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Erro ao carregar dados."));
          }

          var dados = snapshot.data!;
          String nome = dados['nome'] ?? "Não informado";
          String email = dados['email'] ?? "Não informado";
          String curso = dados['curso'] ?? "Não informado";
          String matricula = dados['matricula'] ?? "Não informado"; 
          
          bool isAdmin = (dados['role'] == 'admin') || (email.endsWith('@ufop.edu.br'));

          // --- CORREÇÃO: Remove efeito visual de esticamento ---
          return ScrollConfiguration(
            behavior: NoOverscrollBehavior(),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(), 
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Informações da Conta",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 25),

                  _buildInfoLabel("Nome Completo"),
                  _buildInfoCard(Icons.person_outline, nome),
                  const SizedBox(height: 20),

                  _buildInfoLabel("E-mail Institucional"),
                  _buildInfoCard(Icons.email_outlined, email),
                  const SizedBox(height: 20),

                  // Dados exclusivos do perfil Participante
                  if (!isAdmin) ...[
                    _buildInfoLabel("Matrícula"),
                    _buildInfoCard(Icons.badge_outlined, matricula),
                    const SizedBox(height: 20),

                    _buildInfoLabel("Curso"),
                    _buildInfoCard(Icons.school_outlined, curso),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), 
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryRed, size: 22), 
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
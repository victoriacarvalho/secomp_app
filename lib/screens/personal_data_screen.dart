import 'package:flutter/material.dart';
import '../servicos/autenticacao_servico.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final AutenticacaoServico _authService = AutenticacaoServico();

  final Color primaryRed = const Color(0xFF9A202F);
  final Color lightGrey = const Color(0xFFF3F5F7);

  @override
  Widget build(BuildContext context) {
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
          "Dados Pessoais",
          style: TextStyle(
            fontFamily: 'Times New Roman',
            fontWeight: FontWeight.w500, // Ajustado para w500
            fontSize: 22,
            color: Colors.black87,       // Ajustado para black87
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _authService.getDadosUsuarioLogado(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryRed));
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Erro ao carregar dados do perfil."));
          }

          var dados = snapshot.data!;

          String nome = dados['nome'] ?? "Não informado";
          String email = dados['email'] ?? "Não informado";
          String curso = dados['curso'] ?? "Não informado";

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Informações da Conta",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'sans-serif'
                  ),
                ),
                const SizedBox(height: 25),

                _buildDataField("Nome Completo", nome, Icons.person_outline),
                const SizedBox(height: 20),

                _buildDataField("E-mail Institucional", email, Icons.email_outlined),
                const SizedBox(height: 20),

                _buildDataField("Curso", curso, Icons.school_outlined),

                const SizedBox(height: 50),

              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
              fontFamily: 'sans-serif'
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: lightGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: primaryRed),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'sans-serif'
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
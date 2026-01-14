import 'package:flutter/material.dart';

class SignUpAdmScreen extends StatefulWidget {
  const SignUpAdmScreen({super.key});

  @override
  State<SignUpAdmScreen> createState() => _SignUpAdmScreenState();
}

class _SignUpAdmScreenState extends State<SignUpAdmScreen> {
  // Cores padronizadas
  final Color primaryRed = const Color(0xFF9A202F);
  final Color lightGreyBackground = const Color(0xFFF3F5F7);
  final Color textGrey = const Color(0xFF666666);

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Botão Voltar
              _buildBackButton(context),

              const SizedBox(height: 30),

              // Cabeçalho Diferenciado
              Center(
                child: Column(
                  children: [
                    Text(
                      'Criar conta ADM',
                      style: TextStyle(
                        fontFamily: 'Times New Roman',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Acesso restrito a organizadores',
                      style: TextStyle(color: primaryRed, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Campo: Nome Completo
              _buildTextField(hint: 'Nome completo do organizador', icon: Icons.person_outline),

              const SizedBox(height: 15),

              // Campo: Email Institucional
              _buildTextField(hint: 'email@institucional.com', icon: Icons.email_outlined, type: TextInputType.emailAddress),

              const SizedBox(height: 15),

              // Campo: Senha
              _buildPasswordField(),

              const SizedBox(height: 15),

              // CAMPO EXCLUSIVO ADM: Token de Segurança
              _buildTextField(
                hint: 'Chave de Acesso SECOMP',
                icon: Icons.vpn_key_outlined,
                isImportant: true,
              ),

              const Padding(
                padding: EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  'Insira o código fornecido pela coordenação do ICEA.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 30),

              // Botão de Cadastro
              _buildSubmitButton(),

              const SizedBox(height: 20),

              // Link para Login
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Já é um organizador? ', style: TextStyle(color: textGrey)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text('Login', style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets Auxiliares para manter o padrão visual das imagens enviadas ---

  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: lightGreyBackground, shape: BoxShape.circle),
        child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
      ),
    );
  }

  Widget _buildTextField({required String hint, required IconData icon, TextInputType type = TextInputType.text, bool isImportant = false}) {
    return Container(
      decoration: BoxDecoration(
        color: lightGreyBackground,
        borderRadius: BorderRadius.circular(12),
        border: isImportant ? Border.all(color: primaryRed.withOpacity(0.3)) : null,
      ),
      child: TextField(
        keyboardType: type,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(color: lightGreyBackground, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
          hintText: 'Senha de acesso',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        onPressed: () {
          // Lógica para validar chave de acesso e criar conta ADM
        },
        child: const Text(
          'Cadastrar Organizador',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
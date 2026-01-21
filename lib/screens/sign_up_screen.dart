import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Cores extraídas da sua identidade visual
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

              // --- BOTÃO VOLTAR ---
              _buildBackButton(context),

              const SizedBox(height: 30),

              // --- CABEÇALHO ---
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Criar conta',
                      style: TextStyle(
                        fontFamily: 'Times New Roman',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crie uma conta para continuar',
                      style: TextStyle(color: textGrey, fontSize: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- CAMPOS DE ENTRADA ---
              _buildTextField(hint: 'Leonardo Smith'),
              const SizedBox(height: 15),
              _buildTextField(hint: 'www.uihut@gmail.com', type: TextInputType.emailAddress),
              const SizedBox(height: 15),
              _buildPasswordField(),

              const Padding(
                padding: EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  'Insira ao menos 8 caracteres',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 30),

              // --- BOTÃO LOGIN (CADASTRAR) ---
              _buildSubmitButton(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

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

  Widget _buildTextField({required String hint, TextInputType type = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(color: lightGreyBackground, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        keyboardType: type,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(color: lightGreyBackground, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        obscureText: !_isPasswordVisible,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: '**********',
          hintStyle: TextStyle(color: Colors.grey[500]),
          suffixIcon: IconButton(
            icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
        onPressed: () {},
        child: const Text(
          'Cadastrar',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }


  Widget _socialIcon(String assetPath) {
    return Container(
      height: 55,
      width: 55,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Image.asset(assetPath),
    );
  }
}
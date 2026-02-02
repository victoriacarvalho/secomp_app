import 'package:flutter/material.dart';
import '../servicos/autenticacao_servico.dart'; // Importando o seu serviço

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  
  final Color primaryRed = const Color(0xFF9A202F);
  final Color lightGreyBackground = const Color(0xFFF3F5F7);
  final Color textGrey = const Color(0xFF666666);
  final Color linkBlue = const Color(0xFF607D8B); // Cor azul acinzentada das imagens


  final AutenticacaoServico _authService = AutenticacaoServico();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  // --- ESTADOS ---
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE CADASTRO ---
  void _validarCadastro() async {
    String nome = _nomeController.text.trim();
    String email = _emailController.text.trim();
    String senha = _senhaController.text;

    // Validações UFOP
    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      _notificacao("Por favor, preencha todos os campos.", erro: true);
      return;
    }

    if (!email.endsWith("@aluno.ufop.edu.br")) {
      _notificacao("Use seu e-mail institucional @aluno.ufop.edu.br", erro: true);
      return;
    }

    if (senha.length < 8 || 
        !senha.contains(RegExp(r'[A-Z]')) || 
        !senha.contains(RegExp(r'[0-9]'))) {
      _notificacao("Senha inválida: use 8 caracteres, uma letra maiúscula e um número.", erro: true);
      return;
    }

    setState(() => _isLoading = true);

    String? resultado = await _authService.cadastrarUsuario(
      nome: nome,
      email: email,
      senha: senha,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (resultado != null) {
      _notificacao(resultado, erro: true);
    } else {
      _notificacao("Conta criada com sucesso!");
    }
  }

  void _notificacao(String mensagem, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: erro ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
              _buildBackButton(context),
              const SizedBox(height: 30),

              // CABEÇALHO
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

              // CAMPOS DE ENTRADA
              _buildTextField(hint: 'Nome Completo', controller: _nomeController),
              const SizedBox(height: 15),
              _buildTextField(
                hint: 'exemplo@aluno.ufop.edu.br',
                type: TextInputType.emailAddress,
                controller: _emailController,
              ),
              const SizedBox(height: 15),
              _buildPasswordField(),

              const SizedBox(height: 40),

              _buildSubmitButton(),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Já tem uma conta? ",
                    style: TextStyle(
                      color: textGrey, 
                      fontSize: 16,
                      fontFamily: 'sans-serif',
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "conecte-se", 
                      style: TextStyle(
                        color: primaryRed, 
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'sans-serif',
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildTextField({
    required String hint,
    TextInputType type = TextInputType.text,
    required TextEditingController controller,
  }) {
    return Container(
      decoration: BoxDecoration(color: lightGreyBackground, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
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
        controller: _senhaController,
        obscureText: !_isPasswordVisible,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Senha (8+ caracteres, A-Z, 0-9)',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
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
        onPressed: _isLoading ? null : _validarCadastro,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Cadastrar',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../servicos/autenticacao_servico.dart';
import 'home_screen.dart'; // Import necessário para o redirecionamento

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

  // Instância do serviço e Controllers
  final AutenticacaoServico _authService = AutenticacaoServico();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE CADASTRO MODIFICADA ---
  void _validarCadastroAdm() async {
    String nome = _nomeController.text.trim();
    String email = _emailController.text.trim();
    String senha = _senhaController.text;
    String token = _tokenController.text.trim();

    if (nome.isEmpty || email.isEmpty || senha.isEmpty || token.isEmpty) {
      _notificacao("Preencha todos os campos, incluindo a chave.", erro: true);
      return;
    }

    setState(() => _isLoading = true);

    // O serviço agora usa o UID do Auth para criar o doc no Firestore
    String? erro = await _authService.cadastrarAdm(
      nome: nome,
      email: email,
      senha: senha,
      tokenDigitado: token,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (erro != null) {
      _notificacao(erro, erro: true);
    } else {
      _notificacao("Organizador cadastrado com sucesso!");
      
      // REDIRECIONAMENTO AUTOMÁTICO: 
      // Como o usuário já está logado após o cadastro, mandamos direto para a Home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
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

              // Cabeçalho ADM
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Criar conta',
                      style: TextStyle(
                        fontFamily: 'Times New Roman',
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Acesso restrito a organizadores',
                      style: TextStyle(
                        color: primaryRed, 
                        fontWeight: FontWeight.w600, 
                        fontSize: 14,
                        fontFamily: 'sans-serif'
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              _buildTextField(hint: 'Nome completo do organizador', icon: Icons.person_outline, controller: _nomeController),
              const SizedBox(height: 15),
              _buildTextField(hint: 'email@institucional.com', icon: Icons.email_outlined, type: TextInputType.emailAddress, controller: _emailController),
              const SizedBox(height: 15),
              _buildPasswordField(),
              const SizedBox(height: 15),

              _buildTextField(
                hint: 'Chave de Acesso SECOMP',
                icon: Icons.vpn_key_outlined,
                controller: _tokenController,
              ),

              const Padding(
                padding: EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  'Insira o código fornecido pela coordenação do ICEA.',
                  style: TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'sans-serif'),
                ),
              ),

              const SizedBox(height: 30),
              _buildSubmitButton(),
              const SizedBox(height: 25),
              _buildFooter(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets Auxiliares ---

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
    required IconData icon, 
    required TextEditingController controller,
    TextInputType type = TextInputType.text, 
  }) {
    return Container(
      decoration: BoxDecoration(
        color: lightGreyBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
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
        controller: _senhaController,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
          hintText: 'Senha de acesso',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
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
        onPressed: _isLoading ? null : _validarCadastroAdm,
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'Cadastrar',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Já é um organizador? ', style: TextStyle(color: textGrey, fontSize: 16, fontFamily: 'sans-serif')),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text('Faça login', style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'sans-serif')),
        ),
      ],
    );
  }
}
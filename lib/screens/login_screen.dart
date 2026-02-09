import 'package:flutter/material.dart';
import '../servicos/autenticacao_servico.dart';
import 'home_screen.dart';
import 'forgot_password.dart';
import 'sign_up_screen.dart';
import 'sign_up_adm_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Instância do serviço e Controllers
  final AutenticacaoServico _authService = AutenticacaoServico();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  // Estados da tela
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Cores do projeto
  final Color primaryRed = const Color(0xFF9A202F);
  final Color lightGreyInput = const Color(0xFFF3F3F3);

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE LOGIN ---
  void _realizarLogin() async {
    String email = _emailController.text.trim();
    String senha = _senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      _notificacao("Por favor, preencha todos os campos.", erro: true);
      return;
    }

    setState(() => _isLoading = true);

    // Chama o serviço para verificar no Firebase
    String? erro = await _authService.logarUsuario(email: email, senha: senha);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (erro != null) {
      _notificacao(erro, erro: true);
    } else {
      // Se não houver erro, entra no app e limpa a pilha de navegação
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
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

  // --- POP-UP DE ESCOLHA DE CADASTRO ---
  void _showSignUpOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Como deseja se cadastrar?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Times New Roman',
                ),
              ),
              const SizedBox(height: 25),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_outline, color: primaryRed),
                ),
                title: const Text("Participante", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Para assistir palestras e workshops"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.admin_panel_settings_outlined, color: primaryRed),
                ),
                title: const Text("Organizador (ADM)", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Acesso restrito à equipe SECOMP"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpAdmScreen()));
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Botão de Voltar
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black54),
                ),
              ),

              const SizedBox(height: 40),

              const Center(
                child: Text(
                  'Faça login',
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Campo de Email
              _buildTextField(
                hintText: 'exemplo@aluno.ufop.edu.br',
                icon: Icons.email_outlined,
                controller: _emailController,
              ),

              const SizedBox(height: 20),

              // Campo de Senha
              _buildPasswordField(),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                  },
                  child: Text(
                    'Esqueceu sua senha?',
                    style: TextStyle(color: primaryRed, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Botão Login com indicador de progresso
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: _isLoading ? null : _realizarLogin,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Login',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                ),
              ),

              const SizedBox(height: 40),

              // Rodapé: Criar conta
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Não tem uma conta? ", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  GestureDetector(
                    onTap: () => _showSignUpOptions(context),
                    child: Text(
                      "Criar conta",
                      style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold, fontSize: 16),
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

  Widget _buildTextField({required String hintText, required IconData icon, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: lightGreyInput,
        prefixIcon: Icon(icon, color: Colors.grey),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _senhaController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: lightGreyInput,
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
        hintText: 'Senha de acesso',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    );
  }
}
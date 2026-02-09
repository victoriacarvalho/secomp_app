import 'package:flutter/material.dart';
import '../servicos/autenticacao_servico.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final Color primaryRed = const Color(0xFF9A202F);
  final Color lightGreyBackground = const Color(0xFFF3F5F7);
  final Color textGrey = const Color(0xFF666666);

  final AutenticacaoServico _authService = AutenticacaoServico();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  String? _cursoSelecionado;
  final List<String> _cursos = [
    "Sistemas de Informação",
    "Engenharia da Computação",
    "Engenharia de Produção"
  ];

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _validarCadastro() async {
    String nome = _nomeController.text.trim();
    String email = _emailController.text.trim();
    String senha = _senhaController.text;

    if (nome.isEmpty || email.isEmpty || senha.isEmpty || _cursoSelecionado == null) {
      _notificacao("Por favor, preencha todos os campos e selecione seu curso.", erro: true);
      return;
    }
    
    if (!email.endsWith("@aluno.ufop.edu.br")) {
      _notificacao("Use seu e-mail institucional @aluno.ufop.edu.br", erro: true);
      return;
    }

    if (senha.length < 8 || !senha.contains(RegExp(r'[A-Z]')) || !senha.contains(RegExp(r'[0-9]'))) {
      _notificacao("Senha inválida: 8 caracteres, uma letra maiúscula e um número.", erro: true);
      return;
    }

    setState(() => _isLoading = true);

    String? resultado = await _authService.cadastrarUsuario(
      nome: nome, 
      email: email, 
      senha: senha,
      curso: _cursoSelecionado!, 
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (resultado != null) {
      _notificacao(resultado, erro: true);
    } else {
      _notificacao("Conta criada com sucesso!");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  void _notificacao(String mensagem, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: erro ? Colors.redAccent : Colors.green, behavior: SnackBarBehavior.floating),
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
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Criar conta',
                      style: TextStyle(
                        fontFamily: 'Times New Roman', 
                        fontSize: 32, 
                        fontWeight: FontWeight.w500, 
                        color: Colors.black87
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Subtítulo padronizado com a tela ADM
                    Text(
                      'Crie uma conta para participar', 
                      style: TextStyle(
                        color: primaryRed, 
                        fontSize: 14, 
                        fontWeight: FontWeight.w600, 
                        fontFamily: 'sans-serif'
                      )
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              _buildTextField(hint: 'Nome Completo', icon: Icons.person_outline, controller: _nomeController),
              const SizedBox(height: 15),
              
              _buildTextField(hint: 'exemplo@aluno.ufop.edu.br', icon: Icons.email_outlined, type: TextInputType.emailAddress, controller: _emailController),
              const SizedBox(height: 15),

              // Campo de Seleção de Curso com altura e alinhamento corrigidos
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: lightGreyBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _cursoSelecionado,
                    hint: const Row(
                      children: [
                        Icon(Icons.school_outlined, color: Colors.grey),
                        SizedBox(width: 10),
                        Text("Selecione seu curso", style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    // Ajuste de altura para alinhar com TextFields
                    itemHeight: 60,
                    items: _cursos.map((String curso) {
                      return DropdownMenuItem<String>(
                        value: curso,
                        child: Text(curso, style: const TextStyle(fontSize: 15)),
                      );
                    }).toList(),
                    onChanged: (String? novoValor) {
                      setState(() => _cursoSelecionado = novoValor);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 15),
              _buildPasswordField(),
              const SizedBox(height: 40),
              
              _buildSubmitButton('Cadastrar'),
              const SizedBox(height: 25),
              _buildFooter(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) => InkWell(
    onTap: () => Navigator.pop(context),
    borderRadius: BorderRadius.circular(50),
    child: Container(
      padding: const EdgeInsets.all(12), 
      decoration: BoxDecoration(color: lightGreyBackground, shape: BoxShape.circle), 
      child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black)
    ),
  );

  Widget _buildTextField({required String hint, required IconData icon, required TextEditingController controller, TextInputType type = TextInputType.text}) => Container(
    decoration: BoxDecoration(color: lightGreyBackground, borderRadius: BorderRadius.circular(12)),
    child: TextField(
      controller: controller, 
      keyboardType: type, 
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey), 
        hintText: hint, 
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14), 
        border: InputBorder.none, 
        contentPadding: const EdgeInsets.symmetric(vertical: 18)
      ),
    ),
  );

  Widget _buildPasswordField() => Container(
    decoration: BoxDecoration(color: lightGreyBackground, borderRadius: BorderRadius.circular(12)),
    child: TextField(
      controller: _senhaController, 
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey), 
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)
        ),
        hintText: 'Senha (8+ caracteres, A-Z, 0-9)', 
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14), 
        border: InputBorder.none, 
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    ),
  );

  Widget _buildSubmitButton(String label) => SizedBox(
    width: double.infinity, 
    height: 55,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryRed, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), 
        elevation: 0
      ),
      onPressed: _isLoading ? null : _validarCadastro,
      child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white) 
          : Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    ),
  );

  Widget _buildFooter() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text("Já tem uma conta? ", style: TextStyle(color: textGrey, fontSize: 16, fontFamily: 'sans-serif')),
      GestureDetector(
        onTap: () => Navigator.pop(context), 
        child: Text("Faça login", style: TextStyle(color: primaryRed, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'sans-serif'))
      ),
    ],
  );
}
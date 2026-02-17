import 'package:flutter/material.dart';
import '../servicos/autenticacao_servico.dart';
import 'home_screen.dart'; // Importante para o NoOverscrollBehavior

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
  final TextEditingController _matriculaController = TextEditingController(); 
  final TextEditingController _senhaController = TextEditingController();

  String? _cursoSelecionado;
  final List<String> _cursos = [
    "Sistemas de Informação",
    "Engenharia da Computação",
    "Engenharia de Produção",
    "Engenharia Elétrica"
  ];

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _matriculaController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // Validação e envio dos dados para o Firebase
  void _validarCadastro() async {
    String nome = _nomeController.text.trim();
    String email = _emailController.text.trim();
    String matricula = _matriculaController.text.trim();
    String senha = _senhaController.text;

    if (nome.isEmpty || email.isEmpty || matricula.isEmpty || senha.isEmpty || _cursoSelecionado == null) {
      _notificacao("Por favor, preencha todos os campos.", erro: true);
      return;
    }
    
    if (!email.endsWith("@aluno.ufop.edu.br")) {
      _notificacao("Use seu e-mail institucional @aluno.ufop.edu.br", erro: true);
      return;
    }

    if (senha.length < 8 || !senha.contains(RegExp(r'[A-Z]')) || !senha.contains(RegExp(r'[0-9]'))) {
      _notificacao("Senha deve ter 8 caracteres, uma maiúscula e um número.", erro: true);
      return;
    }

    setState(() => _isLoading = true);

    String? resultado = await _authService.cadastrarUsuario(
      nome: nome, 
      email: email, 
      matricula: matricula,
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
        // --- CORREÇÃO: Remove efeito visual de esticamento ---
        child: ScrollConfiguration(
          behavior: NoOverscrollBehavior(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(), // Trava física do scroll
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
                        style: TextStyle(fontFamily: 'Times New Roman', fontSize: 32, fontWeight: FontWeight.w500, color: Colors.black87),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Crie uma conta para participar', 
                        style: TextStyle(color: primaryRed, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                _buildTextField(hint: 'Nome Completo', icon: Icons.person_outline, controller: _nomeController),
                const SizedBox(height: 15),
                _buildTextField(hint: 'exemplo@aluno.ufop.edu.br', icon: Icons.email_outlined, type: TextInputType.emailAddress, controller: _emailController),
                const SizedBox(height: 15),
                _buildTextField(hint: 'Matrícula', icon: Icons.badge_outlined, type: TextInputType.number, controller: _matriculaController),
                const SizedBox(height: 15),

                // Dropdown de Curso
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: lightGreyBackground, borderRadius: BorderRadius.circular(12)),
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
                      items: _cursos.map((String curso) {
                        return DropdownMenuItem<String>(value: curso, child: Text(curso, style: const TextStyle(fontSize: 15)));
                      }).toList(),
                      onChanged: (val) => setState(() => _cursoSelecionado = val),
                    ),
                  ),
                ),

                const SizedBox(height: 15),
                _buildPasswordField(),
                const SizedBox(height: 40),
                
                _buildSubmitButton('CADASTRAR'),
                const SizedBox(height: 25),
                _buildFooter(),
                const SizedBox(height: 20),
              ],
            ),
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
      style: ElevatedButton.styleFrom(backgroundColor: primaryRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0),
      onPressed: _isLoading ? null : _validarCadastro,
      child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white) 
          : Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    ),
  );

  Widget _buildFooter() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text("Já tem uma conta? ", style: TextStyle(color: textGrey, fontSize: 16)),
      GestureDetector(
        onTap: () => Navigator.pop(context), 
        child: Text("Faça login", style: TextStyle(color: primaryRed, fontSize: 16, fontWeight: FontWeight.bold))
      ),
    ],
  );
}
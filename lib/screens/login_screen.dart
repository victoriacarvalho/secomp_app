import 'package:flutter/material.dart';
import 'home_screen.dart'; // Para navegar ao clicar em "Login"

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true; // Controla se a senha está oculta

  // Cores do projeto
  final Color primaryRed = const Color(0xFF9A202F);
  final Color lightGreyInput = const Color(0xFFF3F3F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView( // Permite rolar se o teclado cobrir a tela
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Botão de Voltar (Círculo)
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

              // Título e Subtítulo
              Center(
                child: Column(
                  children: [
                    Text(
                      'Faça login',
                      style: TextStyle(
                        fontFamily: 'Times New Roman',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Faça login para continuar',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // Campo de Email
              _buildTextField(
                hintText: 'www.uihut@gmail.com', // Exemplo do design
                icon: null,
              ),

              const SizedBox(height: 20),

              // Campo de Senha
              TextField(
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: lightGreyInput,
                  hintText: '**********',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              // Esqueceu sua senha?
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Esqueceu sua senha?',
                    style: TextStyle(color: primaryRed, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Botão LOGIN
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    // Navega para a Home
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Início')),
                    );
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Criar conta
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Não tem uma conta? ", style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () {
                      // Ação de criar conta
                    },
                    child: Text(
                      "Criar conta",
                      style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // "Ou conecte-se"
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text("Ou conecte-se", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),

              const SizedBox(height: 30),

              // Botões Sociais (Simulados)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton(Colors.blue[800]!, Icons.facebook),
                  const SizedBox(width: 20),
                  _socialButton(Colors.purple, Icons.camera_alt), // Simulando Instagram
                  const SizedBox(width: 20),
                  _socialButton(Colors.lightBlue, Icons.alternate_email), // Simulando Twitter
                ],
              ),

              const SizedBox(height: 20), // Espaço final
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para campo de texto simples
  Widget _buildTextField({required String hintText, IconData? icon}) {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: lightGreyInput,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }

  // Widget auxiliar para botões sociais
  Widget _socialButton(Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
          ]
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}
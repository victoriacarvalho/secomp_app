import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final TextEditingController _emailController = TextEditingController();


  final Color primaryRed = const Color(0xFF9A202F);
  final Color lightGreyBackground = const Color(0xFFF3F5F7); // Fundo do input
  final Color textGrey = const Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco conforme a imagem
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // --- BOTÃO VOLTAR ---
              InkWell(
                onTap: () {
                  Navigator.pop(context); // Volta para a tela anterior
                },
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: lightGreyBackground, // Círculo cinza claro
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // --- TEXTOS ---
              Center(
                child: Column(
                  children: [
                    Text(
                      'Esqueceu a senha?',
                      style: TextStyle(
                        fontFamily: 'Times New Roman',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Insira seu e-mail cadastrado para resetar a senha',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: textGrey,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- CAMPO DE TEXTO (INPUT) ---
              Container(
                decoration: BoxDecoration(
                  color: lightGreyBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'www.uihut@gmail.com', // Placeholder da imagem
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none, // Remove a linha inferior padrão
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- BOTÃO RESETAR SENHA ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0, // A imagem parece flat, sem sombra
                  ),
                  onPressed: () {
                    // Lógica de resetar senha aqui
                    print("Email para reset: ${_emailController.text}");
                  },
                  child: const Text(
                    'Resetar senha',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
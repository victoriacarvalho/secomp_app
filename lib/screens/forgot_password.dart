import 'package:flutter/material.dart';
import '../servicos/autenticacao_servico.dart'; 

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AutenticacaoServico _authService = AutenticacaoServico();
  bool _isLoading = false; 

  final Color primaryRed = const Color(0xFF9A202F);
  final Color lightGreyBackground = const Color(0xFFF3F5F7);
  final Color textGrey = const Color(0xFF666666);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Envia e-mail de recuperação via Firebase
  void _processarRecuperacao() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      _notificacao("Por favor, insira seu e-mail.", erro: true);
      return;
    }

    setState(() => _isLoading = true);
    String? erro = await _authService.recuperarSenha(email: email);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (erro != null) {
      _notificacao(erro, erro: true);
    } else {
      _showSuccessDialog();
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

  // Pop-up informativo de sucesso
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 60, width: 60,
                  decoration: BoxDecoration(color: primaryRed, shape: BoxShape.circle),
                  child: const Icon(Icons.mark_email_read_outlined, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Verifique seu e-mail',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Times New Roman', fontSize: 28, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enviamos as instruções para: \n${_emailController.text}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: textGrey, height: 1.5),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Fecha dialog
                      Navigator.pop(context); // Volta para Login
                    },
                    child: const Text("Voltar para Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
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
        // --- CORREÇÃO: Remove efeito de esticamento visual ---
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildBackButton(),
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildEmailField(),
                const SizedBox(height: 30),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
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

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Esqueceu a senha?',
            style: TextStyle(fontFamily: 'Times New Roman', fontSize: 32, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Text(
            'Insira seu e-mail cadastrado para trocar de senha',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: textGrey, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(color: lightGreyBackground, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
          hintText: 'exemplo@email.com',
          hintStyle: TextStyle(color: Colors.grey[500]),
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
        onPressed: _isLoading ? null : _processarRecuperacao,
        child: _isLoading
            ? const SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'CONFIRMAR',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
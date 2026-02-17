import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionScreen extends StatefulWidget {
  final String eventTitle;
  final String eventId;

  const SubscriptionScreen({
    super.key,
    required this.eventTitle,
    required this.eventId,
  });

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para captura de dados
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _matriculaController = TextEditingController();

  bool _isLoading = false;
  final Color primaryColor = const Color(0xFFA93244);

  // --- LÓGICA DE INSCRIÇÃO COM TRANSAÇÃO ---
  void _confirmarInscricao() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showError("Usuário não identificado.");
      setState(() => _isLoading = false);
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final eventRef = firestore.collection('eventos').doc(widget.eventId);

      // Transação para garantir que a vaga não seja ocupada simultaneamente
      await firestore.runTransaction((transaction) async {
    
        DocumentSnapshot eventSnapshot = await transaction.get(eventRef);
        if (!eventSnapshot.exists) {
          throw Exception("Evento não encontrado.");
        }

        var eventData = eventSnapshot.data() as Map<String, dynamic>;
        int vagasAtuais = (eventData['vagas'] is int)
            ? eventData['vagas']
            : (int.tryParse(eventData['vagas'].toString()) ?? 0);

        if (vagasAtuais <= 0) {
          throw Exception("Vagas esgotadas para este evento.");
        }
=
        final queryDuplicidade = await firestore
            .collection('inscricoes')
            .where('eventId', isEqualTo: widget.eventId)
            .where('matricula', isEqualTo: _matriculaController.text.trim())
            .get();

        if (queryDuplicidade.docs.isNotEmpty) {
          throw Exception("Esta matrícula já está inscrita neste evento.");
        }

        final inscricaoRef = firestore.collection('inscricoes').doc();
        final novaInscricao = {
          'eventId': widget.eventId,
          'eventTitle': widget.eventTitle,
          'uidParticipante': user.uid,
          'nomeUsuario': _nomeController.text.trim(),
          'emailUsuario': _emailController.text.trim(),
          'matricula': _matriculaController.text.trim(),
          'dataInscricao': FieldValue.serverTimestamp(),
          'presencaConfirmada': false,
        };

        transaction.set(inscricaoRef, novaInscricao);
        transaction.update(eventRef, {
          'vagas': FieldValue.increment(-1),
          'numeroInscritos': FieldValue.increment(1),
        });
      });

      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pop(context, true); // Sucesso: retorna para atualizar a tela anterior

    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      String msg = e.toString().replaceAll("Exception: ", "");
      _showError(msg);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _matriculaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Inscrição", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      // --- REMOVE O EFEITO DE ESTICAMENTO (OVERSCROLL) ---
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Inscreva-se em:\n${widget.eventTitle}",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Confirme seus dados para garantir sua vaga e receber o certificado.",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 30),

                _buildLabel("Nome Completo"),
                _buildTextField(_nomeController, "Seu nome completo", Icons.person),

                _buildLabel("E-mail Institucional"),
                _buildTextField(_emailController, "email@aluno.ufop.edu.br", Icons.email, isEmail: true),

                _buildLabel("Matrícula"),
                _buildTextField(_matriculaController, "Ex: 20.1.0000", Icons.badge, isNumber: true),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _confirmarInscricao,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text("CONFIRMAR INSCRIÇÃO", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 15.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false, bool isEmail = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber
            ? TextInputType.number
            : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return "Campo obrigatório";
          if (isEmail && !value.contains('@')) return "E-mail inválido";
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}
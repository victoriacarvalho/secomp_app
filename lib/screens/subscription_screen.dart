import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../servicos/notificacao_servico.dart';

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
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _matriculaController = TextEditingController();

  bool _isLoading = false;
  final Color primaryColor = const Color(0xFFA93244);

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

      await firestore.runTransaction((transaction) async {
        DocumentSnapshot eventSnapshot = await transaction.get(eventRef);
        if (!eventSnapshot.exists) {
          throw Exception("Evento não encontrado.");
        }

        var eventData = eventSnapshot.data() as Map<String, dynamic>;
        
        // Dados para as notificações
        DateTime dataEvento = (eventData['data'] as Timestamp).toDate();
        String organizadorId = eventData['organizadorUid'] ?? ""; 

        int vagasAtuais = (eventData['vagas'] is int)
            ? eventData['vagas']
            : (int.tryParse(eventData['vagas'].toString()) ?? 0);

        if (vagasAtuais <= 0) {
          throw Exception("Vagas esgotadas.");
        }

        final inscricaoRef = firestore.collection('inscricoes').doc();
        
        final novaInscricao = {
          'eventId': widget.eventId,
          'eventTitle': widget.eventTitle,
          'uidParticipante': user.uid,
          'organizadorUid': organizadorId,
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

        // --- AGENDAMENTO DE NOTIFICAÇÕES AUTOMÁTICAS ---
        await NotificacaoServico.agendarNotificacoesEvento(
          idBase: widget.eventId.hashCode,
          titulo: widget.eventTitle,
          dataEvento: dataEvento,
        );
      });

      if (!mounted) return;
      setState(() => _isLoading = false);
      
      // Feedback de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inscrição realizada e lembretes agendados!"), backgroundColor: Colors.green),
      );
      
      Navigator.pop(context, true);

    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(e.toString().replaceAll("Exception: ", ""));
    }

    await NotificacaoServico.listarAgendamentos();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Inscrever-se em: ${widget.eventTitle}", 
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              _buildTextField(_nomeController, "Nome Completo", Icons.person),
              const SizedBox(height: 15),
              _buildTextField(_emailController, "E-mail Institucional", Icons.email, isEmail: true),
              const SizedBox(height: 15),
              _buildTextField(_matriculaController, "Matrícula", Icons.badge, isNumber: true),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmarInscricao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("CONFIRMAR INSCRIÇÃO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false, bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (value) => (value == null || value.isEmpty) ? "Campo obrigatório" : null,
    );
  }
}
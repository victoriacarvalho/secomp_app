import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../servicos/certificado_helper.dart'; // Import do helper
import 'manage_subscribers_screen.dart'; // Import da tela de gestão
import 'home_screen.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});
  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  final Color primaryColor = const Color(0xFFA93244);
  bool _isOrganizador = false;
  String _userId = "";

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  void _checkUserRole() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
        if (user.email != null && user.email!.endsWith("@ufop.edu.br")) {
          _isOrganizador = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CustomBottomBar(activeIndex: 2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text("Certificados", style: TextStyle(fontFamily: 'Times New Roman', fontWeight: FontWeight.bold)),
      ),
      body: _isOrganizador ? _buildOrganizerView() : _buildParticipantView(),
    );
  }

  Widget _buildParticipantView() {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('inscricoes')
            .where('uidParticipante', isEqualTo: _userId) // Filtra pelo ID do aluno logado
            .where('presencaConfirmada', isEqualTo: true) // Só mostra se o ADM confirmou a presença
            .snapshots(),
        builder: (context, snapshot) {
          // Exibe aviso caso não existam certificados liberados
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildAvisoVazio();
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              // Extrai os dados de cada inscrição confirmada
              var insc = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return _buildCardDownload(insc);
            },
          );
        },
      );
    }

    // Widget auxiliar para exibir cada card de certificado disponível
    Widget _buildCardDownload(Map<String, dynamic> insc) {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          leading: const Icon(Icons.workspace_premium, color: Color(0xFFA93244), size: 40),
          title: Text(
            insc['eventTitle'] ?? "Evento",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text("Certificado disponível para download"),
          trailing: IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.green, size: 30),
            onPressed: () {
              // Chama o helper para gerar o PDF dinâmico
              CertificadoHelper.gerarEVisualizar(
                nomeAluno: insc['nomeUsuario'] ?? "Participante",
                nomeEvento: insc['eventTitle'] ?? "Evento",
                matricula: insc['matricula'] ?? "S/M",
              );
            },
          ),
        ),
      );
    }

  Widget _buildAvisoVazio() {
    return const Center(child: Text("Participe dos eventos para liberar seus certificados."));
  }

  Widget _buildOrganizerView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('eventos')
          .where('organizadorUid', isEqualTo: _userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var dados = docs[index].data() as Map<String, dynamic>;
            return _buildAdminCard(eventId: docs[index].id, titulo: dados['titulo'] ?? "Sem título");
          },
        );
      },
    );
  }

  Widget _buildAdminCard({required String eventId, required String titulo}) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => ManageSubscribersScreen(eventId: eventId, eventTitle: titulo)
      )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text("Clique para gerenciar presença", style: TextStyle(color: Colors.blue, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
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
        title: const Text(
          "Certificados",
          style: TextStyle(fontFamily: 'Times New Roman', fontWeight: FontWeight.w500, fontSize: 24, color: Colors.black87),
        ),
      ),
      body: _isOrganizador ? _buildOrganizerView() : _buildParticipantView(),
    );
  }

  // --- VISÃO DO ALUNO (PARTICIPANTE) ---
  Widget _buildParticipantView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Meus Certificados", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('inscricoes')
                .where('userId', isEqualTo: _userId)
                .where('presencaConfirmada', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildAvisoVazio();
              }
              return _buildBotaoDownload();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvisoVazio() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.school_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text("Participe dos eventos para liberar seus certificados.", style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildBotaoDownload() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          const url = 'https://docs.google.com/document/d/1lQ7tJBdwOFare6h-BfwCL1ed4ekBGy9mYwCW_EssByM/export?format=pdf';
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          }
        },
        icon: const Icon(Icons.download_rounded, color: Colors.white),
        label: const Text("BAIXAR CERTIFICADOS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], padding: const EdgeInsets.symmetric(vertical: 15)),
      ),
    );
  }

  // --- VISÃO DO ORGANIZADOR ---
  Widget _buildOrganizerView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('eventos').where('organizadorUid', isEqualTo: _userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Nenhum evento criado."));
        }
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
    return Container(
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
          const SizedBox(height: 10),
          FutureBuilder<AggregateQuerySnapshot>(
            future: FirebaseFirestore.instance.collection('inscricoes').where('eventId', isEqualTo: eventId).where('presencaConfirmada', isEqualTo: true).count().get(),
            builder: (context, snap) {
              int total = snap.data?.count ?? 0;
              return Text("$total participantes presentes", style: TextStyle(color: Colors.grey[600]));
            },
          ),
        ],
      ),
    );
  }
}
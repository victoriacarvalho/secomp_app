import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Verifica se o usuário logado é organizador (email @ufop.edu.br)
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
      
      // Barra de navegação inferior padronizada
      bottomNavigationBar: const CustomBottomBar(activeIndex: 2),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Certificados",
          style: TextStyle(
            fontFamily: 'Times New Roman',
            fontWeight: FontWeight.w500,
            fontSize: 24,
            color: Colors.black87,
          ),
        ),
      ),

      // Exibe view diferente dependendo do papel do usuário
      body: _isOrganizador ? _buildOrganizerView() : _buildParticipantView(),
    );
  }

  // Tela do Participante
  Widget _buildParticipantView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text(
            "Seus certificados aparecerão aqui.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }


  // Tela do Organizador
  Widget _buildOrganizerView() {
    // Escuta eventos criados pelo usuário atual
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('eventos')
          .where('organizadorUid', isEqualTo: _userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_note, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 20),
                const Text("Você ainda não criou eventos.", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        var docs = snapshot.data!.docs;

        // Remove efeito de esticamento
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: ListView.builder(
            physics: const ClampingScrollPhysics(), // Trava a física do scroll
            padding: const EdgeInsets.all(20),
            itemCount: docs.length + 1, // +1 para o cabeçalho
            itemBuilder: (context, index) {
              if (index == 0) {
                // Cabeçalho da lista
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Gerenciar Emissão",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Libere os certificados apenas para quem realizou o check-in.",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }

              // Cards dos eventos
              var doc = docs[index - 1];
              var dados = doc.data() as Map<String, dynamic>;
              String eventId = doc.id;
              
              // Por enquanto, sempre pendente (lógica de envio futura)
              bool isEmitido = false; 

              return _buildAdminCard(
                eventId: eventId,
                titulo: dados['titulo'] ?? "Evento sem título",
                isEmitido: isEmitido,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAdminCard({
    required String eventId,
    required String titulo,
    required bool isEmitido,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título e Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isEmitido ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Text(
                  isEmitido ? "Emitido" : "Pendente",
                  style: TextStyle(
                    color: isEmitido ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12
                  ),
                ),
              )
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Apenas participantes com PRESENÇA CONFIRMADA
          FutureBuilder<AggregateQuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('inscricoes')
                .where('eventId', isEqualTo: eventId)
                .where('presencaConfirmada', isEqualTo: true) 
                .count()
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Calculando...", style: TextStyle(color: Colors.grey, fontSize: 12));
              }
              int total = snapshot.data?.count ?? 0;
              return Text(
                "$total participantes presentes", 
                style: TextStyle(color: Colors.grey[600])
              );
            },
          ),

          const SizedBox(height: 15),
          
          // Botão de Ação (Apenas visual por enquanto)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(
                     content: Text("A lógica de envio será implementada posteriormente."),
                     backgroundColor: Colors.grey,
                     duration: Duration(seconds: 2),
                   )
                );
              },
              icon: const Icon(Icons.send, size: 18, color: Colors.white,),
              label: const Text(
                "EMITIR CERTIFICADOS", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
            ),
          )
        ],
      ),
    );
  }
}
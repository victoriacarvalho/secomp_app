import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final String _organizadorUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Gerenciar Presença",
          style: TextStyle(fontFamily: 'Times New Roman', fontWeight: FontWeight.w500, fontSize: 22, color: Colors.black87),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Busca eventos do organizador logado
        stream: FirebaseFirestore.instance
            .collection('eventos')
            .where('organizadorUid', isEqualTo: _organizadorUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Você não possui eventos ativos."));
          }

          var docs = snapshot.data!.docs;

          // --- CORREÇÃO: Remove efeito de esticamento ---
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
            child: ListView.builder(
              physics: const ClampingScrollPhysics(), // Trava a física
              padding: const EdgeInsets.all(20),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var dados = docs[index].data() as Map<String, dynamic>;
                String eventId = docs[index].id;

                return _buildEventCard(context, eventId, dados['titulo'] ?? "Sem Título");
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, String eventId, String titulo) {
    return GestureDetector(
      onTap: () {
        // Abre lista de participantes
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => ParticipantListScreen(eventId: eventId, eventTitle: titulo))
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFA93244).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.checklist, color: Color(0xFFA93244)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  const Text("Toque para abrir a lista", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// --- TELA DA LISTA DE CHAMADA ---
class ParticipantListScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;

  const ParticipantListScreen({super.key, required this.eventId, required this.eventTitle});

  @override
  State<ParticipantListScreen> createState() => _ParticipantListScreenState();
}

class _ParticipantListScreenState extends State<ParticipantListScreen> {
  String _searchQuery = "";

  // Atualiza presença no Firebase
  void _togglePresenca(String inscricaoId, bool atual) {
    FirebaseFirestore.instance.collection('inscricoes').doc(inscricaoId).update({
      'presencaConfirmada': !atual,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text("Lista de Presença", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(widget.eventTitle, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barra de Pesquisa
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar participante...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
            ),
          ),

          // Lista de Inscritos
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('inscricoes')
                  .where('eventId', isEqualTo: widget.eventId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                var docs = snapshot.data!.docs;

                // Filtro local
                var filteredDocs = docs.where((doc) {
                  var dados = doc.data() as Map<String, dynamic>;
                  String nome = (dados['nomeUsuario'] ?? "").toString().toLowerCase();
                  return nome.contains(_searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text("Nenhum participante encontrado."));
                }

                // Remove efeito de esticamento ---
                return ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
                  child: ListView.builder(
                    physics: const ClampingScrollPhysics(), 
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      var doc = filteredDocs[index];
                      var dados = doc.data() as Map<String, dynamic>;
                      bool isPresente = dados['presencaConfirmada'] == true;

                      return ListTile(
                        title: Text(dados['nomeUsuario'] ?? "Anônimo", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(dados['emailUsuario'] ?? "Sem email"),
                        trailing: Switch(
                          value: isPresente,
                          activeColor: const Color(0xFFA93244),
                          onChanged: (val) => _togglePresenca(doc.id, isPresente),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
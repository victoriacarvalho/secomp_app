import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageSubscribersScreen extends StatelessWidget {
  final String eventId;
  final String eventTitle;

  const ManageSubscribersScreen({
    super.key, 
    required this.eventId, 
    required this.eventTitle
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(eventTitle),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('inscricoes')
            .where('eventId', isEqualTo: eventId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Nenhum participante inscrito."));
          }

          var docs = snapshot.data!.docs;
          final user = FirebaseAuth.instance.currentUser;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              bool estaPresente = data['presencaConfirmada'] ?? false;
              String docId = docs[index].id;
              
              // Verifica se o usuário atual é o organizador deste evento específico
              bool euSouOOrganizador = (user != null && user.uid == data['organizadorUid']);

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFA93244).withValues(alpha: 0.1),
                    child: Text(
                      data['nomeUsuario']?.isNotEmpty == true ? data['nomeUsuario'][0].toUpperCase() : "?",
                      style: const TextStyle(color: Color(0xFFA93244), fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    data['nomeUsuario'] ?? "Usuário",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(data['emailUsuario'] ?? ""),
                  trailing: euSouOOrganizador 
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: estaPresente ? Colors.green : const Color(0xFFA93244),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection('inscricoes')
                                .doc(docId)
                                .update({'presencaConfirmada': !estaPresente});
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Erro ao confirmar: $e"), backgroundColor: Colors.red),
                            );
                          }
                        },
                        child: Text(estaPresente ? "PRESENTE" : "CONFIRMAR"),
                      )
                    : (estaPresente 
                        ? const Icon(Icons.check_circle, color: Colors.green) 
                        : const Icon(Icons.access_time, color: Colors.orange)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
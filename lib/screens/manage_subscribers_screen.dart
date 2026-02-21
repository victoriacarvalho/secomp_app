import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        title: Text("Inscritos: $eventTitle"),
        centerTitle: true,
      ),
      // O StreamBuilder é o segredo: ele reconstrói a tela toda vez que o banco muda
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              bool estaPresente = data['presencaConfirmada'] ?? false;
              String docId = docs[index].id;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(
                    data['nomeUsuario'] ?? "Usuário",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(data['emailUsuario'] ?? ""),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: estaPresente ? Colors.green : const Color(0xFFA93244),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      // Tenta atualizar o campo no Firestore
                      try {
                        await FirebaseFirestore.instance
                            .collection('inscricoes')
                            .doc(docId)
                        // Inverte o valor atual (se true vira false, se false vira true)
                            .update({'presencaConfirmada': !estaPresente});
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Erro ao confirmar: $e"), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: Text(estaPresente ? "PRESENTE" : "CONFIRMAR"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
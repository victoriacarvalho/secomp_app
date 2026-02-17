import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../servicos/autenticacao_servico.dart';
import 'home_screen.dart'; 
import 'event_detail_screen.dart';

class SavedEventsScreen extends StatelessWidget {
  const SavedEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AutenticacaoServico authService = AutenticacaoServico();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Eventos Salvos",
          style: TextStyle(
            fontFamily: 'Times New Roman', 
            fontWeight: FontWeight.w500,    
            fontSize: 24,                   
            color: Colors.black87,         
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Obtém stream de IDs salvos pelo usuário logado
        stream: authService.getEventosSalvosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  const Text("Nenhum evento salvo ainda.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          var savedDocs = snapshot.data!.docs;

          //  Remove efeito visual de esticamento 
          return ScrollConfiguration(
            behavior: NoOverscrollBehavior(),
            child: ListView.builder(
              physics: const ClampingScrollPhysics(), 
              padding: const EdgeInsets.all(20),
              itemCount: savedDocs.length,
              itemBuilder: (context, index) {
                String eventId = savedDocs[index].id;

                // Busca dados detalhados de cada evento salvo
                return FutureBuilder<DocumentSnapshot>(
                  future: authService.getEventoById(eventId),
                  builder: (context, eventSnapshot) {
                    if (!eventSnapshot.hasData || !eventSnapshot.data!.exists) {
                      return const SizedBox(); 
                    }

                    var dados = eventSnapshot.data!.data() as Map<String, dynamic>;
                    dados['id'] = eventSnapshot.data!.id;
                    
                    if (dados['data'] is Timestamp) {
                      dados['data'] = (dados['data'] as Timestamp).toDate();
                    }

                    return _buildSavedCard(context, dados);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSavedCard(BuildContext context, Map<String, dynamic> event) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => EventDetailScreen(eventData: event)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            // Capa do Evento
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
              child: SizedBox(
                width: 100,
                height: 100,
                child: EventImage(
                  imageUrl: event['imageUrl'], 
                  fit: BoxFit.cover
                ),
              ),
            ),
            // Informações do Evento
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['titulo'] ?? "Sem título",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(child: Text(
                          event['isOnline'] == true ? "Online" : (event['local'] ?? "Local"), 
                          style: const TextStyle(fontSize: 12, color: Colors.grey), 
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis
                        )),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text("Ver detalhes", style: TextStyle(color: Color(0xFFA93244), fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 15.0),
              child: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}
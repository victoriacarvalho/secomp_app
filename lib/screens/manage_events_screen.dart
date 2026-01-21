import 'package:flutter/material.dart';
import 'manage_event_detail_screen.dart';
import 'create_event_screen.dart';

class ManageEventsScreen extends StatelessWidget {
  const ManageEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFA93244);

    // Lista simulada de eventos para administração
    final List<Map<String, dynamic>> adminEvents = [
      {'title': 'Mineração de dados', 'status': 'Ativo', 'registrations': 340},
      {'title': 'Workshop Flutter', 'status': 'Ativo', 'registrations': 120},
      {'title': 'Intro ao Python', 'status': 'Rascunho', 'registrations': 0},
      {'title': 'Segurança Web', 'status': 'Cancelado', 'registrations': 45},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Gerenciar Eventos",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // --- MUDANÇA AQUI ---
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateEventScreen())
          );
        },
        backgroundColor: primaryRed,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Novo Evento", style: TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: adminEvents.length,
        itemBuilder: (context, index) {
          final event = adminEvents[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ]
            ),
            child: Row(
              children: [
                // Ícone/Imagem
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.event_note, color: Colors.blue),
                ),
                const SizedBox(width: 15),
                // Textos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: event['status'] == 'Ativo' ? Colors.green[100] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(4)
                            ),
                            child: Text(
                                event['status'],
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: event['status'] == 'Ativo' ? Colors.green[800] : Colors.grey[800]
                                )
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text("${event['registrations']} inscritos", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                ),
                // Ações
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                  onPressed: () {
                    // --- AQUI ---
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ManageEventDetailScreen())
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  onPressed: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
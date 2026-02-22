import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_detail_screen.dart';
import '../widgets/event_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Buscar eventos...",
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('eventos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filtra os documentos localmente para permitir busca por partes da palavra
          var docs = snapshot.data!.docs.where((doc) {
            var titulo = (doc['titulo'] as String).toLowerCase();
            return titulo.contains(_searchQuery);
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text("Nenhum evento encontrado."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var dados = docs[index].data() as Map<String, dynamic>;
              dados['id'] = docs[index].id;
              
              return ListTile(
                contentPadding: const EdgeInsets.only(bottom: 15),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: EventImage(imageUrl: dados['imageUrl']),
                  ),
                ),
                title: Text(dados['titulo'] ?? "Sem título", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(dados['local'] ?? "A definir"),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EventDetailScreen(eventData: dados)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
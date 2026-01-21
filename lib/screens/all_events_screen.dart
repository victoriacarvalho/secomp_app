import 'package:flutter/material.dart';
import 'event_detail_screen.dart'; // Para navegar aos detalhes ao clicar no card

class AllEventsScreen extends StatelessWidget {
  const AllEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de dados simulados (Mock Data) para preencher a tela
    final List<Map<String, String>> events = [
      {
        'title': 'Mineração de dados',
        'location': 'Sala C203',
        'slots': '30 vagas',
        'image': 'https://picsum.photos/300/300?random=10',
      },
      {
        'title': 'Análise de dados',
        'location': 'Sala H102',
        'slots': '25 vagas',
        'image': 'https://picsum.photos/300/300?random=11',
      },
      {
        'title': 'Avanço da IA',
        'location': 'Auditório',
        'slots': '60 vagas',
        'image': 'https://picsum.photos/300/300?random=12',
      },
      {
        'title': 'Mercado de trabalho',
        'location': 'Auditório',
        'slots': '60 vagas',
        'image': 'https://picsum.photos/300/300?random=13',
      },
      {
        'title': 'Flutter para Iniciantes',
        'location': 'Lab 04',
        'slots': '20 vagas',
        'image': 'https://picsum.photos/300/300?random=14',
      },
      {
        'title': 'Segurança Digital',
        'location': 'Sala B101',
        'slots': '40 vagas',
        'image': 'https://picsum.photos/300/300?random=15',
      },
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
          "Eventos Populares",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Todos os eventos",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // GRID DE EVENTOS
            Expanded(
              child: GridView.builder(
                itemCount: events.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 colunas
                  crossAxisSpacing: 15, // Espaço horizontal entre cards
                  mainAxisSpacing: 15, // Espaço vertical entre cards
                  childAspectRatio: 0.7, // Ajuste da altura do card (0.7 deixa mais alto)
                ),
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _buildGridCard(context, event);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, Map<String, String> event) {
    return GestureDetector(
      onTap: () {
        // Navega para os detalhes do evento
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(
              title: event['title']!,
              location: event['location']!,
              points: "50", // Valor padrão
              imagePath: 'public/campus.png', // Imagem estática para detalhes
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. IMAGEM + CORAÇÃO
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(20)), // Arredonda tudo
                  child: Image.network(
                    event['image']!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4), // Fundo translúcido
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),

            // 2. INFORMAÇÕES
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title']!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event['location']!,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    event['slots']!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),

                  // Preço colorido (RichText para misturar cores)
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 14),
                      children: [
                        TextSpan(
                          text: "R\$0",
                          style: TextStyle(
                              color: Color(0xFFA93244), // Vermelho Vinho
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        TextSpan(
                          text: "/pessoa",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
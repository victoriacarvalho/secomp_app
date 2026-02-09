import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Para TapGestureRecognizer
import 'dart:io'; // Para File
import 'package:cloud_firestore/cloud_firestore.dart'; // Para Timestamp
import 'package:intl/intl.dart'; // Para DateFormat

class EventDetailScreen extends StatelessWidget {
  final Map<String, dynamic> eventData;

  const EventDetailScreen({
    super.key,
    required this.eventData,
  });

  // Cores do projeto
  final Color primaryRed = const Color(0xFF9A202F);

  // --- FUNÇÃO PARA MOSTRAR A DESCRIÇÃO COMPLETA ---
  void _showFullDescription(BuildContext context, String description) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sobre o evento',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Text(
                        description,
                        style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                          backgroundColor: primaryRed,
                          side: BorderSide(color: primaryRed),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                      ),
                      child: const Text("Fechar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- EXTRAÇÃO DE DADOS DO MAP ---
    final String title = eventData['titulo'] ?? 'Sem Título';
    final String description = eventData['descricao'] ?? 'Sem descrição detalhada.';
    final String palestrante = eventData['palestrantePrincipal'] ?? 'Organização';
    final int vagas = eventData['vagas'] ?? 0;

    // Tratamento de Data
    final Timestamp? timestamp = eventData['data'];
    final String dataFormatada = timestamp != null
        ? DateFormat("dd/MM 'às' HH:mm", "pt_BR").format(timestamp.toDate())
        : "Data a definir";

    // Tratamento Online/Presencial
    final bool isOnline = eventData['isOnline'] ?? false;
    final String location = isOnline
        ? "Evento Online"
        : (eventData['local'] ?? "Local a definir");

    // Tratamento de Imagem
    final String? imageUrl = eventData['imageUrl'];
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;

    // Tratamento de Convidados (Lista)
    final List<dynamic> convidados = eventData['palestrantesConvidados'] ?? [];

    final double imageHeight = MediaQuery.of(context).size.height * 0.45;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. CAMADA DE FUNDO (Imagem)
          Container(
            height: imageHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300], // Cor de fundo caso falhe
              image: DecorationImage(
                image: hasImage
                    ? (imageUrl!.startsWith('http')
                    ? NetworkImage(imageUrl)
                    : FileImage(File(imageUrl)) as ImageProvider)
                    : const AssetImage('assets/images/event_placeholder.jpg'),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  // Evita crash se a imagem falhar
                  print("Erro ao carregar imagem: $exception");
                },
              ),
            ),
            child: !hasImage
                ? Icon(Icons.event, size: 80, color: Colors.grey[400])
                : null,
          ),

          // 2. CAMADA DE CONTEÚDO (Scroll)
          SingleChildScrollView(
            child: Column(
              children: [
                // Espaço transparente para mostrar a imagem
                SizedBox(height: imageHeight - 40),

                // O cartão branco arredondado
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5)),
                    ],
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Título e Palestrante
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    title,
                                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.1)
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(Icons.person, size: 16, color: primaryRed),
                                    const SizedBox(width: 5),
                                    Text(
                                        palestrante,
                                        style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Badge de Data
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: primaryRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                Text(
                                    timestamp != null ? DateFormat('dd').format(timestamp.toDate()) : "--",
                                    style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold, fontSize: 20)
                                ),
                                Text(
                                    timestamp != null ? DateFormat('MMM').format(timestamp.toDate()).toUpperCase() : "--",
                                    style: TextStyle(color: primaryRed, fontSize: 12, fontWeight: FontWeight.bold)
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Ícones de Informação
                      Row(
                        children: [
                          Icon(isOnline ? Icons.videocam_outlined : Icons.location_on_outlined, color: Colors.grey, size: 20),
                          const SizedBox(width: 4),
                          Expanded(child: Text(location, style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis)),

                          const SizedBox(width: 10),

                          const Icon(Icons.access_time, color: Colors.grey, size: 20),
                          const SizedBox(width: 4),
                          Text(timestamp != null ? DateFormat('HH:mm').format(timestamp.toDate()) : "--:--", style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.people_outline, color: Colors.grey, size: 20),
                          const SizedBox(width: 4),
                          Text('$vagas Vagas', style: const TextStyle(color: Colors.grey)),
                          const Spacer(),
                          Text('Grátis', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Link do Evento (Se for Online)
                      if (isOnline && eventData['link'] != null && eventData['link'].toString().isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue[200]!)
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.link, color: Colors.blue),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  eventData['link'],
                                  style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                      ],

                      // Palestrantes Convidados
                      if (convidados.isNotEmpty) ...[
                        const Text("Convidados", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: convidados.map((nome) => Chip(
                            label: Text(nome.toString()),
                            backgroundColor: Colors.grey[100],
                            avatar: CircleAvatar(
                              backgroundColor: primaryRed,
                              child: Text(nome.toString()[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 25),
                      ],

                      // Descrição
                      const Text('Sobre o evento', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),

                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.6),
                          children: [
                            TextSpan(text: description.length > 100 ? "${description.substring(0, 100)}... " : description),
                            if (description.length > 100)
                              TextSpan(
                                text: 'Leia mais',
                                style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _showFullDescription(context, description);
                                  },
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Botão Inscrever
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryRed,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            // Feedback visual
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Inscrição realizada com sucesso!")),
                            );
                          },
                          child: const Text('Inscrever-se', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. CAMADA DE BOTÕES (VOLTAR)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton(
                      Icons.arrow_back_ios_new,
                          () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      }
                  ),
                  _buildCircleButton(Icons.share, () {

                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
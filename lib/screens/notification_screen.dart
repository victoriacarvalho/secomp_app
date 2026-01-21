import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Dados simulados baseados na imagem
  // "isNew" define se tem o fundo azulzinho de não lida
  List<Map<String, dynamic>> notifications = [
    {
      'title': 'Evento iniciando',
      'body': 'Check-in disponível para o evento de IA.',
      'time': 'Seg, 12:40',
      'avatar': 'https://i.pravatar.cc/150?u=10',
      'isNew': true,
    },
    {
      'title': 'Evento iniciando',
      'body': 'Check-in disponível para o evento de Flutter.',
      'time': 'Seg, 12:40',
      'avatar': 'https://i.pravatar.cc/150?u=20',
      'isNew': true,
    },
    {
      'title': 'Evento iniciando',
      'body': 'Check-in disponível para o evento de Design.',
      'time': 'Seg, 12:40',
      'avatar': 'https://i.pravatar.cc/150?u=30',
      'isNew': false, // Já lida (fundo branco)
    },
    {
      'title': 'Evento iniciando',
      'body': 'Check-in disponível para o evento de Python.',
      'time': 'Seg, 12:40',
      'avatar': 'https://i.pravatar.cc/150?u=40',
      'isNew': false,
    },
    {
      'title': 'Evento iniciando',
      'body': 'Check-in disponível para o evento de Redes.',
      'time': 'Seg, 12:40',
      'avatar': 'https://i.pravatar.cc/150?u=50',
      'isNew': false,
    },
    {
      'title': 'Evento iniciando',
      'body': 'Check-in disponível para o evento de Java.',
      'time': 'Seg, 12:40',
      'avatar': 'https://i.pravatar.cc/150?u=60',
      'isNew': false,
    },
  ];

  final Color primaryRed = const Color(0xFFA93244);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // Botão Voltar (Circular cinza claro)
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey[100],
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          "Notificações",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
        actions: [
          // Botão Limpar
          TextButton(
            onPressed: () {
              setState(() {
                notifications.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Notificações limpas!")),
              );
            },
            child: Text(
              "Limpar",
              style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Título da Seção "Não lidas"
          if (notifications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Text(
                "Não lidas",
                style: TextStyle(
                    color: primaryRed,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),

          // Lista de Notificações
          Expanded(
            child: notifications.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text("Nenhuma notificação", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
                : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return _buildNotificationItem(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> item) {
    return Container(
      color: item['isNew'] ? Colors.blue[50] : Colors.white, // Fundo azul se for nova
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(item['avatar']),
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(width: 15),

          // Conteúdo de Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Linha do Título e Hora
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      item['time'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // Descrição
                Text(
                  item['body'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
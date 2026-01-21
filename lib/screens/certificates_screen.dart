import 'package:flutter/material.dart';
import 'certificate_detail_screen.dart';
import 'diary_screen.dart'; // Importante para navegar para a agenda

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dados simulados
    final List<Map<String, dynamic>> chats = [
      {
        'name': 'José da Silva',
        'message': 'Olá, seu certificado Avanço da IA foi emitido',
        'time': '09:46',
        'avatar': 'https://i.pravatar.cc/150?u=1',
        'statusColor': Colors.amber,
        'isRead': true,
        'checkColor': Colors.grey,
      },
      {
        'name': 'Ana Maria',
        'message': 'Emitindo...',
        'time': '08:42',
        'avatar': 'https://i.pravatar.cc/150?u=2',
        'statusColor': Colors.grey,
        'isRead': true,
        'checkColor': Colors.green,
        'isHighlight': true,
      },
      {
        'name': 'Igor M.',
        'message': 'Olá, seu certificado Instalação DEBIAN foi emitido',
        'time': 'Yesterday',
        'avatar': 'https://i.pravatar.cc/150?u=3',
        'statusColor': Colors.green,
        'isRead': true,
        'checkColor': Colors.grey,
      },
      {
        'name': 'Helen',
        'message': 'Olá, seu certificado Análise de dados foi emitido',
        'time': '07:56',
        'avatar': 'https://i.pravatar.cc/150?u=4',
        'statusColor': Colors.red,
        'isRead': true,
        'checkColor': Colors.grey,
      },
      {
        'name': 'Carlos',
        'message': 'Olá, seu certificado Machine L. foi emitido',
        'time': '05:52',
        'avatar': 'https://i.pravatar.cc/150?u=5',
        'statusColor': Colors.green,
        'isRead': true,
        'checkColor': Colors.green,
      },
    ];

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
          "Certificados",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Text(
              "Meus certificados",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: "Busque por nome do evento",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView.separated(
              itemCount: chats.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 80, endIndent: 20),
              itemBuilder: (context, index) {
                return _buildChatTile(context, chats[index]);
              },
            ),
          ),
        ],
      ),
      // AQUI ESTAVA O ERRO: Agora a classe existe logo abaixo
      bottomNavigationBar: const CustomBottomBar(),
    );
  }

  Widget _buildChatTile(BuildContext context, Map<String, dynamic> chat) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              name: chat['name'],
              avatarUrl: chat['avatar'],
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(chat['avatar']),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: chat['statusColor'],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Row(
                        children: [
                          if (chat['isRead'])
                            Icon(Icons.done_all, size: 16, color: chat['checkColor']),
                          const SizedBox(width: 5),
                          Text(
                            chat['time'],
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    chat['message'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: (chat['isHighlight'] ?? false) ? Colors.blue : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- CLASSE DA BARRA INFERIOR (Copiada aqui para funcionar o import) ---

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5)
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Botão INÍCIO (Volta para Home)
          _buildNavItem(
              Icons.home_outlined,
              "Início",
              false,
              onTap: () {
                // Volta até a primeira tela (Home)
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
          ),

          // Botão AGENDA (Vai para Agenda)
          _buildNavItem(
              Icons.calendar_month,
              "Agenda",
              false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AgendaScreen()),
                );
              }
          ),

          // Botão BUSCA
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFA93244),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Color(0x40A93244), blurRadius: 10, offset: Offset(0, 5))
              ],
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 30),
          ),

          // Botão CERTIFICADOS (Ativo)
          _buildNavItem(
            Icons.chat_bubble_outline,
            "Certificados",
            true, // Ativo
          ),

          // Botão PERFIL
          _buildNavItem(
            Icons.person_outline,
            "Perfil",
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? const Color(0xFFA93244) : Colors.grey, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                  color: isActive ? const Color(0xFFA93244) : Colors.grey,
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ],
        ),
      ),
    );
  }
}
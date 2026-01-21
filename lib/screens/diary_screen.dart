import 'package:flutter/material.dart';
import 'event_detail_screen.dart'; // Certifique-se de que este arquivo existe

class AgendaScreen extends StatelessWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Cor de fundo suave
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        // --- 1. BOTÃO DE VOLTAR (Topo) ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Fecha a tela atual e volta para a Home
          },
        ),
        title: const Text(
          "Agenda",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
        actions: [
          // --- 2. BOTÃO DE NOTIFICAÇÕES ---
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, size: 28, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Sem novas notificações")),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),

      // --- BARRA INFERIOR REINTEGRADA ---
      bottomNavigationBar: const CustomBottomBar(),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 3. CALENDÁRIO INTERATIVO ---
              const CalendarStrip(),

              const SizedBox(height: 30),

              // Cabeçalho da Lista
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Meus eventos",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  // --- 4. BOTÃO VER TUDO ---
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Carregando lista completa...")),
                      );
                    },
                    child: const Text(
                      "Ver tudo",
                      style: TextStyle(color: Color(0xFFA93244)),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 10),

              // --- 5. CARDS COM NAVEGAÇÃO ---
              const EventCard(
                title: "Gestão de Carreira",
                date: "26 Janeiro 2026",
                location: "Auditório ICEA",
                imageUrl: "https://picsum.photos/200/200?random=1",
                points: "60",
              ),
              const EventCard(
                title: "Instalação DEBIAN",
                date: "26 Fevereiro 2026",
                location: "Sala H102",
                imageUrl: "https://picsum.photos/200/200?random=2",
                points: "40",
              ),
              const EventCard(
                title: "Mineração de dados",
                date: "26 Março 2026",
                location: "Sala C203",
                imageUrl: "https://picsum.photos/200/200?random=3",
                points: "80",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGETS AUXILIARES
// ---------------------------------------------------------------------------

// Calendário agora é Stateful para gerenciar qual dia está clicado
class CalendarStrip extends StatefulWidget {
  const CalendarStrip({super.key});

  @override
  State<CalendarStrip> createState() => _CalendarStripState();
}

class _CalendarStripState extends State<CalendarStrip> {
  // Índice inicial (Dia 22 selecionado)
  int _selectedIndex = 4;

  // Dados dos dias
  final List<Map<String, String>> _days = [
    {'day': 'S', 'date': '18'},
    {'day': 'M', 'date': '19'},
    {'day': 'T', 'date': '20'},
    {'day': 'W', 'date': '21'},
    {'day': 'T', 'date': '22'},
    {'day': 'F', 'date': '23'},
    {'day': 'S', 'date': '24'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cabeçalho do Mês
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("22 Outubro", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      // Lógica futura
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      // Lógica futura
                    },
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),

          // Lista Horizontal de Dias
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_days.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: DayItem(
                  day: _days[index]['day']!,
                  date: _days[index]['date']!,
                  isSelected: _selectedIndex == index,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class DayItem extends StatelessWidget {
  final String day;
  final String date;
  final bool isSelected;

  const DayItem({super.key, required this.day, required this.date, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(day, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 35,
          height: 45,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFA93244) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            date,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String location;
  final String imageUrl;
  final String points;

  const EventCard({
    super.key,
    required this.title,
    required this.date,
    required this.location,
    required this.imageUrl,
    this.points = "50",
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(
              title: title,
              location: location,
              points: points,
              imagePath: 'public/campus.png',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(imageUrl, width: 70, height: 70, fit: BoxFit.cover),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- BARRA INFERIOR CUSTOMIZADA ---
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
          // Botão INÍCIO: Volta para a tela anterior (Home)
          _buildNavItem(
            Icons.home_outlined,
            "Início",
            false,
            onTap: () => Navigator.pop(context),
          ),

          // Botão AGENDA: Ativo (sem ação pois já estamos aqui)
          _buildNavItem(Icons.calendar_month, "Agenda", true),

          // Botão BUSCA
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Busca clicada")));
            },
            child: Container(
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
          ),

          // Botão CERTIFICADOS
          _buildNavItem(
            Icons.chat_bubble_outline,
            "Certificados",
            false,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Certificados"))),
          ),

          // Botão PERFIL
          _buildNavItem(
            Icons.person_outline,
            "Perfil",
            false,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perfil"))),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent, // Aumenta área de toque
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
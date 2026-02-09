import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../servicos/autenticacao_servico.dart';
import 'event_detail_screen.dart';
import 'certificates_screen.dart';
import 'profile_screen.dart';

class AgendaScreen extends StatelessWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          "Agenda",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, size: 28, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      bottomNavigationBar: const CustomBottomBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CORREÇÃO: Removido o 'const' aqui
              const CalendarStrip(),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Meus eventos",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Ver tudo", style: TextStyle(color: Color(0xFFA93244))),
                  )
                ],
              ),
              const SizedBox(height: 10),

              // --- LISTA DE EVENTOS DO BANCO ---
              StreamBuilder<QuerySnapshot>(
                stream: AutenticacaoServico().getEventos(),
                builder: (context, snapshot) {
                  // 1. Carregando
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(color: Color(0xFFA93244)),
                        )
                    );
                  }

                  // 2. Sem dados
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("Nenhum evento encontrado na agenda.", style: TextStyle(color: Colors.grey)),
                      ),
                    );
                  }

                  var docs = snapshot.data!.docs;

                  // 3. Lista de Cards
                  return Column(
                    children: docs.map((doc) {
                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

                      // Formatação da Data (Timestamp -> String)
                      String dataExibicao = "--/--";
                      if (data['data'] != null) {
                        try {
                          Timestamp ts = data['data'];
                          // Ex: "26 Fevereiro 2026"
                          dataExibicao = DateFormat("dd MMMM yyyy", "pt_BR").format(ts.toDate());
                        } catch (e) {
                          dataExibicao = "Data Inválida";
                        }
                      }

                      return EventCard(
                        eventData: data,
                        displayDate: dataExibicao,
                      );
                    }).toList(),
                  );
                },
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

class CalendarStrip extends StatefulWidget {
  const CalendarStrip({super.key});

  @override
  State<CalendarStrip> createState() => _CalendarStripState();
}

class _CalendarStripState extends State<CalendarStrip> {
  int _selectedIndex = 4; // Simula o dia atual selecionado

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Outubro 2026", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
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
  final Map<String, dynamic> eventData;
  final String displayDate;

  const EventCard({
    super.key,
    required this.eventData,
    required this.displayDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(eventData: eventData),
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
            // Imagem do Evento
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                eventData['imageUrl'] != null && eventData['imageUrl'].toString().isNotEmpty
                    ? eventData['imageUrl']
                    : 'https://via.placeholder.com/150', // Imagem padrão se nulo
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 15),

            // Informações do Evento
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(displayDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    eventData['titulo'] ?? 'Sem título',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          eventData['isOnline'] == true ? "Online" : (eventData['local'] ?? 'A definir'),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
          _buildNavItem(Icons.home_outlined, "Início", false, onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }),
          _buildNavItem(Icons.calendar_month, "Agenda", true, onTap: () {}),
          GestureDetector(
            onTap: () {},
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
          _buildNavItem(Icons.chat_bubble_outline, "Certificados", false, onTap: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CertificatesScreen()));
          }),
          _buildNavItem(Icons.person_outline, "Perfil", false, onTap: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
          }),
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
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../servicos/autenticacao_servico.dart';
import 'event_detail_screen.dart';
import 'home_screen.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final AutenticacaoServico _authService = AutenticacaoServico();
  final Color primaryColor = const Color(0xFFA93244);


  late DateTime _dataHoje;
  List<DateTime> _diasDaSemana = [];
  int _diaSelecionadoIndex = 0;

  @override
  void initState() {
    super.initState();
    _inicializarCalendario();
  }

  void _inicializarCalendario() {
    _dataHoje = DateTime.now();
    _diasDaSemana = [];


    for (int i = 0; i < 7; i++) {
      _diasDaSemana.add(_dataHoje.add(Duration(days: i)));
    }
  }


  String _capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1);
  }

  @override
  Widget build(BuildContext context) {

    String mesAnoAtual = DateFormat("MMMM yyyy", "pt_BR").format(_diasDaSemana[_diaSelecionadoIndex]);
    mesAnoAtual = _capitalizar(mesAnoAtual);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
          onPressed: () {

            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          },
        ),
        title: const Text("Agenda", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
            child: const Icon(Icons.notifications_none, size: 20, color: Colors.black),
          )
        ],
      ),
      bottomNavigationBar: const CustomBottomBar(activeIndex: 1),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // 1. CALENDÁRIO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(mesAnoAtual, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    const Icon(Icons.chevron_left, color: Colors.grey),
                    const SizedBox(width: 15),
                    Icon(Icons.chevron_right, color: Colors.grey[800]),
                  ],
                )
              ],
            ),

            const SizedBox(height: 20),

            // 2. TIRA DE DIAS
            _buildDaysStrip(),

            const SizedBox(height: 30),

            // 3. TÍTULO DA LISTA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Todos os eventos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Ver tudo", style: TextStyle(color: primaryColor, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 15),

            // 4. LISTA DE EVENTOS
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _authService.getEventosStream(),
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }


                  if (snapshot.hasError) {
                    return const Center(child: Text("Erro ao carregar agenda"));
                  }


                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("Nenhum evento encontrado."));
                  }

                  var docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var doc = docs[index];
                      var dados = doc.data() as Map<String, dynamic>;


                      dados['id'] = doc.id;
                      if (dados['data'] is Timestamp) {
                        dados['data'] = (dados['data'] as Timestamp).toDate();
                      }

                      return _buildScheduleCard(dados);
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDaysStrip() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_diasDaSemana.length, (index) {
        DateTime diaData = _diasDaSemana[index];
        bool isSelected = index == _diaSelecionadoIndex;

        String nomeDia = DateFormat('E', 'pt_BR').format(diaData)[0].toUpperCase();
        String numeroDia = DateFormat('d').format(diaData);

        return GestureDetector(
          onTap: () {
            setState(() {
              _diaSelecionadoIndex = index;

            });
          },
          child: Column(
            children: [
              Text(nomeDia, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 35, height: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                    numeroDia,
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold
                    )
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> event) {
    String imageUrl = event['imageUrl'] ?? "";
    ImageProvider imagemBg;


    if (imageUrl.startsWith('http')) {
      imagemBg = NetworkImage(imageUrl);
    } else if (imageUrl.isNotEmpty) {
      imagemBg = FileImage(File(imageUrl));
    } else {
      imagemBg = const AssetImage('assets/images/event_placeholder.jpg');
    }

    DateTime? data = event['data'] as DateTime?;
    String dateStr = data != null ? DateFormat("dd MMMM yyyy", "pt_BR").format(data) : "Data a definir";

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(eventData: event))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image(image: imagemBg, width: 70, height: 70, fit: BoxFit.cover),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 5),
                      Text(dateStr, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(event['titulo'] ?? "Sem título", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                          event['isOnline'] == true ? "Online" : (event['local'] ?? "Local a definir"),
                          style: TextStyle(fontSize: 12, color: Colors.grey[400])
                      ),
                    ],
                  )
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey)
          ],
        ),
      ),
    );
  }
}
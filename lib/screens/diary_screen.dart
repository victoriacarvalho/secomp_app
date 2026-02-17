import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Controle de datas para a tira de dias
  late DateTime _dataInicialSemana;
  late DateTime _diaSelecionado;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    
    DateTime hoje = DateTime.now();
    _dataInicialSemana = hoje;
    _diaSelecionado = hoje;
  }

  // Navegação entre semanas
  void _mudarSemana(int semanas) {
    setState(() {
      _dataInicialSemana = _dataInicialSemana.add(Duration(days: 7 * semanas));
    });
  }

  String _capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    String mesAnoAtual = DateFormat("MMMM yyyy", "pt_BR").format(_dataInicialSemana);
    mesAnoAtual = _capitalizar(mesAnoAtual);

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CustomBottomBar(activeIndex: 1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen())),
        ),
        title: const Text(
          "Agenda", 
          style: TextStyle(fontFamily: 'Times New Roman', fontWeight: FontWeight.w500, fontSize: 24, color: Colors.black87)
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // 1. Cabeçalho do Calendário e Controles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(mesAnoAtual, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.chevron_left, color: Colors.grey), onPressed: () => _mudarSemana(-1)),
                    const SizedBox(width: 5),
                    IconButton(icon: Icon(Icons.chevron_right, color: Colors.grey[800]), onPressed: () => _mudarSemana(1)),
                  ],
                )
              ],
            ),

            const SizedBox(height: 20),

            // 2. Seletor Horizontal de Dias
            _buildDaysStrip(),

            const SizedBox(height: 30),

            // 3. Informações do Dia Selecionado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Eventos do dia", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(DateFormat('dd/MM').format(_diaSelecionado), style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 15),

            // 4. Lista de Eventos Filtrada
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _authService.getEventosStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError) return const Center(child: Text("Erro ao carregar agenda"));
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _buildEmptyState("Sem eventos registrados.");

                  // Filtragem em tempo real pelo dia selecionado
                  var eventosDoDia = snapshot.data!.docs.where((doc) {
                    var dados = doc.data() as Map<String, dynamic>;
                    if (dados['data'] is! Timestamp) return false;
                    DateTime dataEvento = (dados['data'] as Timestamp).toDate();
                    return _isSameDay(dataEvento, _diaSelecionado);
                  }).toList();

                  if (eventosDoDia.isEmpty) return _buildEmptyState("Nada agendado para este dia.");

                  // Remove esticamento visual da lista
                  return ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
                    child: ListView.builder(
                      physics: const ClampingScrollPhysics(), 
                      itemCount: eventosDoDia.length,
                      itemBuilder: (context, index) {
                        var doc = eventosDoDia[index];
                        var dados = doc.data() as Map<String, dynamic>;
                        dados['id'] = doc.id;
                        dados['data'] = (dados['data'] as Timestamp).toDate();

                        return _buildScheduleCard(dados);
                      },
                    ),
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
    List<DateTime> diasVisiveis = List.generate(7, (index) => _dataInicialSemana.add(Duration(days: index)));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: diasVisiveis.map((diaData) {
        bool isSelected = _isSameDay(diaData, _diaSelecionado);
        String nomeDia = DateFormat('E', 'pt_BR').format(diaData)[0].toUpperCase();
        String numeroDia = DateFormat('d').format(diaData);

        return GestureDetector(
          onTap: () => setState(() => _diaSelecionado = diaData),
          child: Column(
            children: [
              Text(nomeDia, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 35, height: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: isSelected ? primaryColor : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                child: Text(numeroDia, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> event) {
    DateTime data = event['data'] as DateTime;
    String horaStr = DateFormat("HH:mm").format(data);

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
            SizedBox(
              width: 70, height: 70,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: EventImage(imageUrl: event['imageUrl'], fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 5),
                      Text(horaStr, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(event['titulo'] ?? "Sem título", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event['isOnline'] == true ? "Online" : (event['local'] ?? "Local a definir"),
                          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                          overflow: TextOverflow.ellipsis,
                        ),
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

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(msg, style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}
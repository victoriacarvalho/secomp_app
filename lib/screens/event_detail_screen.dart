import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'subscription_screen.dart';
import 'edit_event_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const EventDetailScreen({super.key, required this.eventData});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final Color primaryColor = const Color(0xFFA93244);

  late int _vagasAtuais;
  bool _isInscrito = false;
  bool _isCriador = false;

  @override
  void initState() {
    super.initState();
    _inicializarDados();
  }

  void _inicializarDados() {

    var vagasRaw = widget.eventData['vagas'];
    if (vagasRaw is int) {
      _vagasAtuais = vagasRaw;
    } else {
      _vagasAtuais = int.tryParse(vagasRaw.toString()) ?? 0;
    }

    final user = FirebaseAuth.instance.currentUser;
    final String organizadorUid = widget.eventData['organizadorUid'] ?? "";

    // Se o UID do evento for igual ao UID do usuário logado, ele é o dono
    if (user != null && organizadorUid == user.uid) {
      setState(() {
        _isCriador = true;
      });
    }
  }


  void _irParaInscricao() async {
    if (_vagasAtuais <= 0) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionScreen(
          eventTitle: widget.eventData['titulo'] ?? "Evento",
          eventId: widget.eventData['id'],
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _vagasAtuais--;
        _isInscrito = true;
        widget.eventData['vagas'] = _vagasAtuais;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inscrição confirmada!"), backgroundColor: Colors.green),
        );
      }
    }
  }


  // --- EDIÇÃO ---
  void _editarEvento() async {

    final atualizou = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (ctx) => EditEventScreen(eventData: widget.eventData)
        )
    );

    if (atualizou == true) {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _showFullDescription(BuildContext context, String description) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
              child: ListView(
                controller: controller,
                children: [
                  Center(child: Container(width: 40, height: 4, color: Colors.grey[300])),
                  const SizedBox(height: 20),
                  const Text('Sobre o evento', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Text(description, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Fechar"),
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
    String imageUrl = widget.eventData['imageUrl'] ?? "";
    ImageProvider imagemBg;
    if (imageUrl.startsWith('http')) {
      imagemBg = NetworkImage(imageUrl);
    } else if (imageUrl.isNotEmpty) {
      imagemBg = FileImage(File(imageUrl));
    } else {
      imagemBg = const AssetImage('assets/images/event_placeholder.jpg');
    }

    String descricao = widget.eventData['descricao'] ?? "Sem descrição.";
    String palestrantePrincipal = widget.eventData['palestrantePrincipal'] ?? "Organizador";
    List<String> convidados = List<String>.from(widget.eventData['palestrantesConvidados'] ?? []);
    String todosPalestrantes = [palestrantePrincipal, ...convidados].join(", ");

    return Scaffold(
      body: Stack(
        children: [
          // 1. IMAGEM
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Container(
              decoration: BoxDecoration(image: DecorationImage(image: imagemBg, fit: BoxFit.cover)),
            ),
          ),

          // 2. HEADER
          Positioned(
            top: 50, left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleBtn(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                const Text("Detalhes", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                _circleBtn(Icons.bookmark_border, () {}),
              ],
            ),
          ),

          // 3. CONTEÚDO
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.42,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40, height: 4, color: Colors.grey[300])),
                    const SizedBox(height: 25),

                    // TÍTULO E AVATAR
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.eventData['titulo'] ?? "Sem título", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.1)),
                              const SizedBox(height: 5),
                              Text(todosPalestrantes, style: TextStyle(color: Colors.grey[500], fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                          alignment: Alignment.center,
                          child: Text(palestrantePrincipal.isNotEmpty ? palestrantePrincipal[0].toUpperCase() : "U", style: TextStyle(color: primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),

                    const SizedBox(height: 25),

                    // INFO
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                        const SizedBox(width: 5),
                        Expanded(child: Text(widget.eventData['isOnline'] == true ? "Online" : (widget.eventData['local'] ?? "Local"), style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 10),
                        Text("$_vagasAtuais", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text(" vagas", style: TextStyle(color: Colors.grey)),
                        const SizedBox(width: 15),
                        Text("Grátis", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // DESCRIÇÃO
                    const Text("Sobre", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.6),
                        children: [
                          TextSpan(text: descricao.length > 120 ? "${descricao.substring(0, 120)}... " : descricao),
                          if (descricao.length > 120)
                            TextSpan(
                              text: " Leia mais",
                              style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()..onTap = () => _showFullDescription(context, descricao),
                            ),
                        ],
                      ),
                    ),

                    // LINK (Se online)
                    if (widget.eventData['isOnline'] == true && widget.eventData['link'] != null && widget.eventData['link'].toString().isNotEmpty) ...[
                      const SizedBox(height: 20),
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
                            Expanded(child: Text(widget.eventData['link'], style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),

                    // BOTÃO DE AÇÃO
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(

                        onPressed: _isCriador
                            ? _editarEvento
                            : (_isInscrito || _vagasAtuais <= 0) ? null : _irParaInscricao,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isCriador ? Color(0xFFA93244) : primaryColor,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isCriador ? Icons.edit : (_isInscrito ? Icons.check : Icons.person_add), color: Colors.white),
                            const SizedBox(width: 10),
                            Text(
                              _isCriador
                                  ? "Editar Evento"
                                  : (_isInscrito ? "Inscrito " : (_vagasAtuais <= 0 ? "Lotado" : "Inscrever-se")),
                              style: TextStyle(color: _isInscrito ? Colors.grey[600] : Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
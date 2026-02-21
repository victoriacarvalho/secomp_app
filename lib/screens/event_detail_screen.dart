import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../servicos/autenticacao_servico.dart';
import 'subscription_screen.dart';
import 'edit_event_screen.dart';
import 'home_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const EventDetailScreen({super.key, required this.eventData});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final AutenticacaoServico _authService = AutenticacaoServico();
  final Color primaryColor = const Color(0xFFA93244);
  bool _isLoading = false;

  late int _vagasAtuais;
  bool _isInscrito = false;
  bool _isCriador = false;
  bool _isSalvo = false;

  @override
  void initState() {
    super.initState();
    _inicializarDados();
    _verificarSeEstaSalvo();
  }

  void _inicializarDados() {
    var vagasRaw = widget.eventData['vagas'];
    _vagasAtuais = (vagasRaw is int) ? vagasRaw : (int.tryParse(vagasRaw.toString()) ?? 0);

    final user = FirebaseAuth.instance.currentUser;
    final String organizadorUid = widget.eventData['organizadorUid'] ?? "";

    if (user != null && organizadorUid == user.uid) {
      setState(() => _isCriador = true);
    }
  }

  void _verificarSeEstaSalvo() async {
    bool salvo = await _authService.isEventoSalvo(widget.eventData['id']);
    if (mounted) setState(() => _isSalvo = salvo);
  }

  void _toggleSalvar() async {
    try {
      bool novoStatus = await _authService.alternarSalvarEvento(widget.eventData['id']);
      if (mounted) {
        setState(() => _isSalvo = novoStatus);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(novoStatus ? "Evento salvo!" : "Removido dos salvos."),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.black87,
          ),
        );
      }
    } catch (e) {
      if (mounted) _showError("Erro ao salvar evento.");
    }
  }

  Future<void> _abrirLink(String? url) async {
    if (url == null || url.isEmpty) return;
    String urlFinal = url.startsWith('http') ? url : 'https://$url';
    final Uri uri = Uri.parse(urlFinal);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) _showError("Não foi possível abrir o link.");
    }
  }

  // Função para inscrição
  void _irParaInscricao() async {
    if (_vagasAtuais <= 0) return;

    setState(() => _isLoading = true);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionScreen(
          eventTitle: widget.eventData['titulo'] ?? "Evento",
          eventId: widget.eventData['id'],
        ),
      ),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result == true) {
        setState(() {
          _vagasAtuais--;
          _isInscrito = true;
          widget.eventData['vagas'] = _vagasAtuais;
        });
      }
    }
  }

  // Função para edição
  void _editarEvento() async {
    final atualizou = await Navigator.push(
        context,
        MaterialPageRoute(builder: (ctx) => EditEventScreen(eventData: widget.eventData))
    );
    if (atualizou == true && mounted) {
      // Se editou, podemos fechar ou recarregar
      Navigator.pop(context, true);
    }
  }

  void _showFullDescription(BuildContext context, String description) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.9,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
          child: ListView(
            controller: controller,
            children: [
              Center(child: Container(width: 40, height: 4, color: Colors.grey[300])),
              const SizedBox(height: 20),
              const Text('Sobre o evento', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Text(description, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF9A202F),
                    side: const BorderSide(color: Color(0xFF9A202F), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("FECHAR", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.eventData['imageUrl'] ?? "";
    String descricao = widget.eventData['descricao'] ?? "Sem descrição.";
    String palestrantePrincipal = widget.eventData['palestrantePrincipal'] ?? "Organizador";
    List<String> convidados = List<String>.from(widget.eventData['palestrantesConvidados'] ?? []);
    String todosPalestrantes = [palestrantePrincipal, ...convidados].join(", ");

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: EventImage(imageUrl: imageUrl, fit: BoxFit.cover),
          ),
          Positioned(
            top: 50, left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleBtn(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                const Text("Detalhes", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                _circleBtn(_isSalvo ? Icons.bookmark : Icons.bookmark_border, _toggleSalvar, isActive: _isSalvo),
              ],
            ),
          ),
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.42,
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40, height: 4, color: Colors.grey[300])),
                    const SizedBox(height: 25),
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
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                        const SizedBox(width: 5),
                        Expanded(child: Text(widget.eventData['isOnline'] == true ? "Online" : (widget.eventData['local'] ?? "Local"), style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 10),
                        Text("$_vagasAtuais vagas", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 15),
                        Text("Grátis", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 30),
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
                    if (widget.eventData['isOnline'] == true && widget.eventData['link']?.toString().isNotEmpty == true) ...[
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => _abrirLink(widget.eventData['link']),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue[200]!)),
                          child: Row(
                            children: [
                              const Icon(Icons.link, color: Colors.blue),
                              const SizedBox(width: 10),
                              Expanded(child: Text(widget.eventData['link'], style: const TextStyle(color: Colors.blue), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),

                    // LÓGICA CORRIGIDA DO BOTÃO ABAIXO:
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : (_isCriador
                            ? _editarEvento
                            : (_vagasAtuais <= 0 || _isInscrito ? null : _irParaInscricao)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isCriador ? Colors.blue : (_isInscrito ? Colors.green : (_vagasAtuais <= 0 ? Colors.grey : primaryColor)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isCriador ? Icons.edit : (_isInscrito ? Icons.check : Icons.person_add), color: Colors.white),
                            const SizedBox(width: 10),
                            Text(
                                _isCriador ? "EDITAR EVENTO" : (_isInscrito ? "INSCRITO" : (_vagasAtuais <= 0 ? "LOTADO" : "INSCREVER-SE")),
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
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

  Widget _circleBtn(IconData icon, VoidCallback onTap, {bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          // Substituído .withOpacity(0.3) por .withValues(alpha: 0.3)
          color: isActive ? primaryColor : Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
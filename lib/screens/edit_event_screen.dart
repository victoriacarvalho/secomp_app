import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../servicos/autenticacao_servico.dart';
import 'home_screen.dart'; 

class EditEventScreen extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const EditEventScreen({super.key, required this.eventData});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tituloController;
  late TextEditingController _localController;
  late TextEditingController _dataController;
  late TextEditingController _horaController;
  late TextEditingController _descricaoController;
  late TextEditingController _vagasController;
  late TextEditingController _linkController;
  late TextEditingController _palestranteController;

  File? _imageFile;
  String _imageUrlAtual = "";
  DateTime? _dataSelecionada;
  TimeOfDay? _horarioSelecionado;

  final List<TextEditingController> _convidadosControllers = [];
  bool _carregando = false;
  bool _isOnline = false;

  final Color primaryRed = const Color(0xFF9A202F);

  @override
  void initState() {
    super.initState();
    _inicializarDados();
  }

  // Preenche os campos com os dados existentes do evento
  void _inicializarDados() {
    var e = widget.eventData;

    _tituloController = TextEditingController(text: e['titulo']);
    _localController = TextEditingController(text: e['local']);
    _descricaoController = TextEditingController(text: e['descricao']);
    _vagasController = TextEditingController(text: e['vagas'].toString());
    _linkController = TextEditingController(text: e['link'] ?? "");
    _palestranteController = TextEditingController(text: e['palestrantePrincipal'] ?? ""); 
    
    _imageUrlAtual = e['imageUrl'] ?? "";
    _isOnline = e['isOnline'] ?? false;

    if (e['data'] != null) {
      DateTime dt = e['data'] is DateTime ? e['data'] : (e['data'] as dynamic).toDate();
      _dataSelecionada = dt;
      _horarioSelecionado = TimeOfDay.fromDateTime(dt);

      _dataController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(dt));
      _horaController = TextEditingController(text: DateFormat('HH:mm').format(dt));
    } else {
      _dataController = TextEditingController();
      _horaController = TextEditingController();
    }

    if (e['palestrantesConvidados'] != null) {
      List<String> convidados = List<String>.from(e['palestrantesConvidados']);
      for (String convidado in convidados) {
        _convidadosControllers.add(TextEditingController(text: convidado));
      }
    }
  }

  // Diálogo de confirmação para exclusão
  void _confirmarExclusao() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white, 
        surfaceTintColor: Colors.white,
        title: const Text("Excluir evento"),
        content: const Text("Tem certeza que deseja excluir este evento permanentemente? Esta ação não pode ser desfeita."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _deletarDeVerdade();
            },
            child: const Text("EXCLUIR", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Deleta o evento do Firestore
  Future<void> _deletarDeVerdade() async {
    setState(() => _carregando = true);
    final authService = AutenticacaoServico();
    String? erro = await authService.excluirEvento(widget.eventData['id']);

    if (erro == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Evento excluído.")));
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
      }
    } else {
      if (mounted) {
        setState(() => _carregando = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
  }

  // Seletor de Data traduzido
  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context, 
      initialDate: _dataSelecionada ?? DateTime.now(), 
      firstDate: DateTime.now(), 
      lastDate: DateTime(2030),
      cancelText: 'Cancelar', confirmText: 'OK',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: primaryRed, onPrimary: Colors.white, onSurface: Colors.black, surface: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() { _dataSelecionada = picked; _dataController.text = DateFormat('dd/MM/yyyy').format(picked); });
    }
  }

  // Seletor de Horário 24h
  Future<void> _selecionarHorario(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context, 
      initialTime: _horarioSelecionado ?? TimeOfDay.now(),
      cancelText: 'Cancelar', confirmText: 'OK',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryRed, surface: Colors.white, onSurface: Colors.black),
          ),
          child: child!,
        ),
      ),
    );
    if (picked != null) {
      setState(() { _horarioSelecionado = picked; _horaController.text = MaterialLocalizations.of(context).formatTimeOfDay(picked, alwaysUse24HourFormat: true); });
    }
  }

  // Atualiza os dados no banco
  void _atualizarEvento() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    try {
      final authService = AutenticacaoServico();
      String urlFinal = _imageUrlAtual;

      if (_imageFile != null) {
        urlFinal = await authService.uploadImagemImgBB(_imageFile!);
      } else if (urlFinal.contains("icea.jpg")) {
        urlFinal = "assets/images/icea.png";
      }

      final DateTime dataFinal = DateTime(
        _dataSelecionada!.year, _dataSelecionada!.month, _dataSelecionada!.day,
        _horarioSelecionado!.hour, _horarioSelecionado!.minute,
      );

      List<String> convidados = _convidadosControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

      String? erro = await authService.atualizarEvento(
        docId: widget.eventData['id'],
        titulo: _tituloController.text.trim(),
        local: _localController.text.trim(),
        data: dataFinal,
        descricao: _descricaoController.text.trim(),
        vagas: int.tryParse(_vagasController.text) ?? 0,
        palestrantesConvidados: convidados,
        isOnline: _isOnline,
        link: _isOnline ? _linkController.text.trim() : null,
        imageUrl: urlFinal,
      );

      setState(() => _carregando = false);
      if (erro == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Evento atualizado!"), backgroundColor: Colors.green));
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
      }
    } catch (e) {
      setState(() => _carregando = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;
    if (_imageFile != null) {
      imageProvider = FileImage(_imageFile!);
    } else if (_imageUrlAtual.startsWith('http')) {
      imageProvider = NetworkImage(_imageUrlAtual);
    } else {
      String path = (_imageUrlAtual.isEmpty || _imageUrlAtual.contains("icea.jpg")) ? "assets/images/icea.png" : _imageUrlAtual;
      imageProvider = AssetImage(path);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text("Editar Evento", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontFamily: 'Times New Roman')),
        actions: [
          IconButton(icon: Icon(Icons.delete_outline, color: primaryRed), onPressed: _carregando ? null : _confirmarExclusao),
          const SizedBox(width: 10),
        ],
      ),
      // --- CORREÇÃO: ScrollConfiguration para evitar esticamento visual ---
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Foto de Capa"),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180, width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Container(
                      alignment: Alignment.bottomRight, padding: const EdgeInsets.all(10),
                      child: CircleAvatar(backgroundColor: Colors.white, radius: 20, child: Icon(Icons.edit, color: primaryRed)),
                    ),
                  ),
                ),
                _buildLabel("Título do Evento"),
                _buildTextField(_tituloController, "Título"),
                _buildLabel("Palestrante Principal"),
                _buildTextField(_palestranteController, "Nome do Palestrante", icon: Icons.person_outline),
                _buildLabel("Local / Plataforma"),
                _buildTextField(_localController, "Local"),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(15)),
                  child: SwitchListTile(
                    title: const Text("Este evento será On-line?", style: TextStyle(fontWeight: FontWeight.w600)),
                    value: _isOnline, activeColor: primaryRed,
                    onChanged: (bool value) => setState(() { _isOnline = value; }),
                  ),
                ),
                if (_isOnline) ...[
                  _buildLabel("Link da Reunião"),
                  _buildTextField(_linkController, "Link da reunião", icon: Icons.link),
                ],
                Row(
                  children: [
                    Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _buildLabel("Data"),
                      GestureDetector(onTap: () => _selecionarData(context), child: AbsorbPointer(child: _buildTextField(_dataController, "dd/mm/aaaa", icon: Icons.calendar_today))),
                    ])),
                    const SizedBox(width: 15),
                    Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _buildLabel("Horário"),
                      GestureDetector(onTap: () => _selecionarHorario(context), child: AbsorbPointer(child: _buildTextField(_horaController, "00:00", icon: Icons.access_time))),
                    ])),
                  ],
                ),
                _buildLabel("Quantidade de Vagas"),
                _buildTextField(_vagasController, "Ex: 50", isNumeric: true, icon: Icons.people_outline),
                _buildLabel("Descrição"),
                _buildTextField(_descricaoController, "Detalhes...", maxLines: 3),
                const SizedBox(height: 25),
                _buildPalestrantesHeader(),
                ..._convidadosControllers.map((c) => Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _buildTextField(c, "Nome do convidado", isConvidado: true, onDelete: () => setState(() => _convidadosControllers.remove(c))),
                )),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _atualizarEvento,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    child: _carregando ? const CircularProgressIndicator(color: Colors.white) : const Text("SALVAR ALTERAÇÕES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(left: 5, bottom: 8, top: 15), child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)));

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, bool isConvidado = false, bool isNumeric = false, IconData? icon, VoidCallback? onDelete}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        controller: controller, maxLines: maxLines, keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint, prefixIcon: icon != null ? Icon(icon, color: Colors.grey, size: 20) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), border: InputBorder.none,
          suffixIcon: isConvidado ? IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: onDelete) : null,
        ),
        validator: (v) => v!.isEmpty ? "Obrigatório" : null,
      ),
    );
  }

  Widget _buildPalestrantesHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text("Palestrantes Extras", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      if (_convidadosControllers.length < 5)
        TextButton.icon(onPressed: () => setState(() => _convidadosControllers.add(TextEditingController())), icon: Icon(Icons.add, color: primaryRed), label: Text("Adicionar", style: TextStyle(color: primaryRed))),
    ]);
  }
}
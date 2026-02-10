import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../servicos/autenticacao_servico.dart';
import 'home_screen.dart'; // Importante para voltar para a Home

class EditEventScreen extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const EditEventScreen({super.key, required this.eventData});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _tituloController;
  late TextEditingController _localController;
  late TextEditingController _dataController;
  late TextEditingController _horaController;
  late TextEditingController _descricaoController;
  late TextEditingController _vagasController;
  late TextEditingController _linkController;

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

  void _inicializarDados() {
    var e = widget.eventData;

    _tituloController = TextEditingController(text: e['titulo']);
    _localController = TextEditingController(text: e['local']);
    _descricaoController = TextEditingController(text: e['descricao']);
    _vagasController = TextEditingController(text: e['vagas'].toString());
    _linkController = TextEditingController(text: e['link'] ?? "");
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

  // --- LÓGICA DE EXCLUSÃO (NOVO) ---
  void _confirmarExclusao() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Evento"),
        content: const Text("Tem certeza que deseja excluir este evento permanentemente? Esta ação não pode ser desfeita."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Fecha o popup
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Fecha o popup
              await _deletarDeVerdade(); // Chama a função real
            },
            child: const Text("EXCLUIR", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletarDeVerdade() async {
    setState(() => _carregando = true);

    final authService = AutenticacaoServico();
    String? erro = await authService.excluirEvento(widget.eventData['id']);

    if (erro == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Evento excluído com sucesso.")));
        // Volta direto para a Home (remove todas as telas anteriores da pilha)
        // Isso evita que o usuário volte para a tela de detalhes de um evento que não existe mais
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false
        );
      }
    } else {
      if (mounted) {
        setState(() => _carregando = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
      }
    }
  }

  // ... (As funções _pickImage, _selecionarData, _selecionarHorario continuam iguais)
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _dataSelecionada ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
    if (picked != null) {
      setState(() { _dataSelecionada = picked; _dataController.text = DateFormat('dd/MM/yyyy').format(picked); });
    }
  }

  Future<void> _selecionarHorario(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _horarioSelecionado ?? TimeOfDay.now());
    if (picked != null) {
      setState(() { _horarioSelecionado = picked; _horaController.text = MaterialLocalizations.of(context).formatTimeOfDay(picked, alwaysUse24HourFormat: true); });
    }
  }
  // ...

  void _atualizarEvento() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    try {
      final authService = AutenticacaoServico();
      String urlFinal = _imageUrlAtual;

      if (_imageFile != null) {
        urlFinal = await authService.uploadImagemImgBB(_imageFile!);
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (_imageFile != null) {
      imageProvider = FileImage(_imageFile!);
    } else if (_imageUrlAtual.isNotEmpty) {
      if (_imageUrlAtual.startsWith('http')) {
        imageProvider = NetworkImage(_imageUrlAtual);
      } else {
        imageProvider = FileImage(File(_imageUrlAtual));
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Editar Evento", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        // --- ÍCONE DE LIXEIRA ---
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: primaryRed),
            onPressed: _carregando ? null : _confirmarExclusao,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
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
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(15),
                    image: imageProvider != null ? DecorationImage(image: imageProvider, fit: BoxFit.cover) : null,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: imageProvider == null
                      ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 40),
                      SizedBox(height: 10),
                      Text("Alterar imagem", style: TextStyle(color: Colors.grey)),
                    ],
                  )
                      : Container(
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.all(10),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                      child: Icon(Icons.edit, color: primaryRed),
                    ),
                  ),
                ),
              ),

              _buildLabel("Título do Evento"),
              _buildTextField(_tituloController, "Título"),

              _buildLabel("Local / Plataforma"),
              _buildTextField(_localController, "Local"),

              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SwitchListTile(
                  title: const Text("Este evento será Online?", style: TextStyle(fontWeight: FontWeight.w600)),
                  value: _isOnline,
                  activeColor: primaryRed,
                  onChanged: (bool value) {
                    setState(() { _isOnline = value; });
                  },
                ),
              ),

              if (_isOnline) ...[
                _buildLabel("Link da Reunião"),
                _buildTextField(_linkController, "Cole o link aqui", icon: Icons.link),
              ],

              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Data"),
                        GestureDetector(
                          onTap: () => _selecionarData(context),
                          child: AbsorbPointer(child: _buildTextField(_dataController, "dd/mm/aaaa", icon: Icons.calendar_today)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Horário"),
                        GestureDetector(
                          onTap: () => _selecionarHorario(context),
                          child: AbsorbPointer(child: _buildTextField(_horaController, "00:00", icon: Icons.access_time)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              _buildLabel("Quantidade de Vagas"),
              _buildTextField(_vagasController, "0", isNumeric: true, icon: Icons.people_outline),

              _buildLabel("Descrição"),
              _buildTextField(_descricaoController, "Descrição...", maxLines: 3),

              const SizedBox(height: 25),

              _buildPalestrantesHeader(),
              ..._convidadosControllers.map((controller) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _buildTextField(
                  controller,
                  "Nome do convidado",
                  isConvidado: true,
                  onDelete: () => setState(() => _convidadosControllers.remove(controller)),
                ),
              )),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _atualizarEvento,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _carregando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("SALVAR ALTERAÇÕES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 8, top: 15),
      child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {
    int maxLines = 1, bool isConvidado = false, bool isNumeric = false, IconData? icon, VoidCallback? onDelete
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey, size: 20) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
          suffixIcon: isConvidado
              ? IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: onDelete)
              : null,
        ),
        validator: (v) => v!.isEmpty ? "Obrigatório" : null,
      ),
    );
  }

  Widget _buildPalestrantesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Palestrantes Extras", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        if (_convidadosControllers.length < 5)
          TextButton.icon(
            onPressed: () => setState(() => _convidadosControllers.add(TextEditingController())),
            icon: Icon(Icons.add, color: primaryRed),
            label: Text("Adicionar", style: TextStyle(color: primaryRed)),
          ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../servicos/autenticacao_servico.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _tituloController = TextEditingController();
  final _palestranteController = TextEditingController(); 
  final _localController = TextEditingController();
  final _dataController = TextEditingController();
  final _horaController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _vagasController = TextEditingController();
  final _linkController = TextEditingController();

  File? _imageFile;
  DateTime? _dataSelecionada;
  TimeOfDay? _horarioSelecionado;

  final List<TextEditingController> _convidadosControllers = [];

  bool _carregando = false;
  bool _isOnline = false;

  final Color primaryRed = const Color(0xFF9A202F);

  @override
  void dispose() {
    _tituloController.dispose();
    _palestranteController.dispose();
    _localController.dispose();
    _dataController.dispose();
    _horaController.dispose();
    _descricaoController.dispose();
    _vagasController.dispose();
    _linkController.dispose();
    for (var c in _convidadosControllers) { c.dispose(); }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Selecionar Data (Traduzido e Estilizado)
  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      cancelText: 'Cancelar',
      confirmText: 'OK',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryRed, 
              onPrimary: Colors.white, 
              onSurface: Colors.black, 
              surface: Colors.white, 
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryRed), 
            ),
            dialogBackgroundColor: Colors.white,
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: primaryRed,
              headerForegroundColor: Colors.white,
              todayBorder: BorderSide(color: primaryRed, width: 2.0),
              todayForegroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white;
                }
                return primaryRed;
              }),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dataSelecionada = picked;
        _dataController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // Selecionar Horário (Traduzido e Estilizado)
  Future<void> _selecionarHorario(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      cancelText: 'Cancelar',
      confirmText: 'OK',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryRed, 
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryRed),
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              dialHandColor: primaryRed,
              dialBackgroundColor: Colors.grey[200],
            )
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _horarioSelecionado = picked;
        final localizations = MaterialLocalizations.of(context);
        _horaController.text = localizations.formatTimeOfDay(picked, alwaysUse24HourFormat: true);
      });
    }
  }

  void _salvarEvento() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dataSelecionada == null || _horarioSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, selecione a Data e o Horário.")),
      );
      return;
    }

    if (_isOnline && _linkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Para eventos online, o link é obrigatório.")),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      final authService = AutenticacaoServico();
      String caminhoImagemFinal = "";

      if (_imageFile != null) {
        caminhoImagemFinal = await authService.uploadImagemImgBB(_imageFile!);
      }

      final DateTime dataFinal = DateTime(
        _dataSelecionada!.year,
        _dataSelecionada!.month,
        _dataSelecionada!.day,
        _horarioSelecionado!.hour,
        _horarioSelecionado!.minute,
      );

      List<String> convidados = _convidadosControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      String? erro = await authService.criarEvento(
        titulo: _tituloController.text.trim(),
        nomePalestrante: _palestranteController.text.trim(), 
        local: _localController.text.trim(),
        data: dataFinal,
        descricao: _descricaoController.text.trim(),
        vagas: int.tryParse(_vagasController.text) ?? 0,
        palestrantesConvidados: convidados,
        isOnline: _isOnline,
        link: _isOnline ? _linkController.text.trim() : null,
        imageUrl: caminhoImagemFinal,
      );

      setState(() => _carregando = false);

      if (erro == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Evento criado com sucesso!")));
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
        }
      }
    } catch (e) {
      setState(() => _carregando = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro interno: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Novo Evento", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      
      // Remove efeito de esticamento ---
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
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(15),
                      image: _imageFile != null
                          ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                          : null,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: _imageFile == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 40),
                              SizedBox(height: 10),
                              Text("Selecionar imagem", style: TextStyle(color: Colors.grey)),
                            ],
                          )
                        : null,
                  ),
                ),

                _buildLabel("Título do Evento"),
                _buildTextField(_tituloController, "Ex: Palestra sobre IA"),

                _buildLabel("Palestrante Principal"),
                _buildTextField(_palestranteController, "Nome do Palestrante", icon: Icons.person_outline),

                _buildLabel("Local / Plataforma"),
                _buildTextField(_localController, "Ex: Auditório Central ou Google Meet"),

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
                      setState(() {
                        _isOnline = value;
                      });
                    },
                  ),
                ),

                if (_isOnline) ...[
                  _buildLabel("Link da Reunião"),
                  _buildTextField(
                      _linkController,
                      "Cole aqui o link (Zoom, Meet...)",
                      icon: Icons.link
                  ),
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
                            child: AbsorbPointer(
                              child: _buildTextField(_dataController, "dd/mm/aaaa", icon: Icons.calendar_today),
                            ),
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
                            child: AbsorbPointer(
                              child: _buildTextField(_horaController, "00:00", icon: Icons.access_time),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                _buildLabel("Quantidade de Vagas"),
                _buildTextField(_vagasController, "Ex: 50", isNumeric: true, icon: Icons.people_outline),

                _buildLabel("Descrição"),
                _buildTextField(_descricaoController, "Detalhes sobre o evento...", maxLines: 3),

                const SizedBox(height: 25),

                // Seção Palestrantes Extras
                Row(
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
                ),

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

                // Botão Salvar
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _salvarEvento,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _carregando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("SALVAR EVENTO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 8, top: 15),
      child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {
    int maxLines = 1,
    bool isConvidado = false,
    bool isNumeric = false,
    IconData? icon,
    VoidCallback? onDelete
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
        validator: (v) {
          if (v!.isEmpty) return "Obrigatório";
          return null;
        },
      ),
    );
  }
}
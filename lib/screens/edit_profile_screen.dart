import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../servicos/autenticacao_servico.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> dadosAtuais;

  const EditProfileScreen({super.key, required this.dadosAtuais});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AutenticacaoServico _authService = AutenticacaoServico();

  late TextEditingController _nomeController;
  String? _cursoSelecionado;
  late List<String> _listaCursos;

  File? _imageFile; // Arquivo local (nova foto)
  String? _fotoUrlAtual; // URL antiga (foto atual)

  bool _isLoading = false;
  final Color primaryColor = const Color(0xFFA93244);

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.dadosAtuais['nome']);
    _cursoSelecionado = widget.dadosAtuais['curso'];
    _fotoUrlAtual = widget.dadosAtuais['fotoUrl'];

    // Carrega cursos
    _listaCursos = _authService.getListaCursos();

    // Validação do curso atual na lista
    if (_cursoSelecionado != null && !_listaCursos.contains(_cursoSelecionado)) {
      if (_cursoSelecionado != "Não informado" && _cursoSelecionado!.isNotEmpty) {
        _listaCursos.add(_cursoSelecionado!);
      } else {
        _cursoSelecionado = null;
      }
    }
  }

  // Selecionar imagem da galeria
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // --- FUNÇÃO SALVAR ATUALIZADA ---
  void _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? urlFinalParaSalvar = _fotoUrlAtual; // Começa com a url antiga

    try {
      // 1. SE O USUÁRIO SELECIONOU UMA NOVA FOTO, FAZ UPLOAD
      if (_imageFile != null) {
        // Envia para o ImgBB e espera o link
        String urlNova = await _authService.uploadImagemImgBB(_imageFile!);

        if (urlNova.isNotEmpty) {
          urlFinalParaSalvar = urlNova; // Atualiza para o novo link
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao subir imagem. Tente novamente.")));
          setState(() => _isLoading = false);
          return;
        }
      }

      // 2. ATUALIZA OS DADOS NO FIRESTORE COM O LINK DA FOTO
      String? erro = await _authService.atualizarPerfilUsuario(
        nome: _nomeController.text.trim(),
        curso: _cursoSelecionado ?? "Não informado",
        fotoUrl: urlFinalParaSalvar, // Salva o link no banco
      );

      setState(() => _isLoading = false);

      if (erro == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perfil atualizado com sucesso!")));
          Navigator.pop(context, true); // Volta para o Perfil e avisa que mudou
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lógica de visualização da imagem (Preview)
    ImageProvider? imageProvider;

    if (_imageFile != null) {
      // Prioridade 1: Imagem nova selecionada no celular
      imageProvider = FileImage(_imageFile!);
    } else if (_fotoUrlAtual != null && _fotoUrlAtual!.isNotEmpty) {
      // Prioridade 2: Imagem salva no banco (URL)
      imageProvider = NetworkImage(_fotoUrlAtual!);
    }
    // Prioridade 3: Se for null, exibe ícone padrão no child do CircleAvatar

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Editar Perfil", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // FOTO
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // CAMPO NOME
              _buildTextField(_nomeController, "Nome Completo", Icons.person),
              const SizedBox(height: 20),

              // DROPDOWN CURSO
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    value: _cursoSelecionado,
                    hint: const Text("Selecione seu Curso", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    decoration: const InputDecoration(border: InputBorder.none),
                    items: _listaCursos.map((String curso) {
                      return DropdownMenuItem<String>(
                        value: curso,
                        child: Text(curso, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (newValue) => setState(() => _cursoSelecionado = newValue),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // BOTÃO SALVAR
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("SALVAR ALTERAÇÕES", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        validator: (value) => value == null || value.isEmpty ? "Campo obrigatório" : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}
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
  late TextEditingController _emailController;
  late TextEditingController _matriculaController;
  
  String? _cursoSelecionado;
  late List<String> _listaCursos;

  File? _imageFile;
  String? _fotoUrlAtual;

  bool _isLoading = false;
  bool _isOrganizador = false;

  final Color primaryColor = const Color(0xFFA93244);

  @override
  void initState() {
    super.initState();
    // Inicialização dos controllers com dados existentes
    _nomeController = TextEditingController(text: widget.dadosAtuais['nome']);
    _emailController = TextEditingController(text: widget.dadosAtuais['email'] ?? '');
    _matriculaController = TextEditingController(text: widget.dadosAtuais['matricula'] ?? '');
    
    _cursoSelecionado = widget.dadosAtuais['curso'];
    _fotoUrlAtual = widget.dadosAtuais['fotoUrl'];

    // Lógica para definir papel do usuário
    String email = widget.dadosAtuais['email'] ?? "";
    String role = widget.dadosAtuais['role'] ?? "";
    
    if (role == 'admin' || email.endsWith('@ufop.edu.br')) {
      _isOrganizador = true;
    }

    _listaCursos = [
      'Sistemas de Informação',
      'Engenharia de Computação',
      'Engenharia Elétrica',
      'Engenharia de Produção',
      'Administração',
      'Outro'
    ];

    // Adiciona curso atual à lista se for externo à lista padrão
    if (!_isOrganizador) {
      if (_cursoSelecionado != null && !_listaCursos.contains(_cursoSelecionado)) {
        if (_cursoSelecionado != "Não informado" && _cursoSelecionado!.isNotEmpty) {
          _listaCursos.add(_cursoSelecionado!);
        } else {
          _cursoSelecionado = null;
        }
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _matriculaController.dispose();
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

  void _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    String? urlFinalParaSalvar = _fotoUrlAtual;

    try {
      // Upload de nova imagem se houver alteração
      if (_imageFile != null) {
        String urlNova = await _authService.uploadImagemImgBB(_imageFile!);
        if (urlNova.isNotEmpty) {
          urlFinalParaSalvar = urlNova;
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao subir imagem.")));
          setState(() => _isLoading = false);
          return;
        }
      }

      String? cursoParaEnviar;
      if (!_isOrganizador) {
        cursoParaEnviar = _cursoSelecionado ?? "Não informado";
      }

      // Atualiza apenas campos permitidos (nome, curso, foto)
      String? erro = await _authService.atualizarPerfilUsuario(
        nome: _nomeController.text.trim(),
        curso: cursoParaEnviar, 
        fotoUrl: urlFinalParaSalvar,
      );

      setState(() => _isLoading = false);

      if (erro == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perfil atualizado!"), backgroundColor: Colors.green));
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (_imageFile != null) {
      imageProvider = FileImage(_imageFile!);
    } else if (_fotoUrlAtual != null && _fotoUrlAtual!.isNotEmpty) {
      imageProvider = NetworkImage(_fotoUrlAtual!);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Editar Perfil", style: TextStyle(fontFamily: 'Times New Roman', color: Colors.black87, fontWeight: FontWeight.w500)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // --- CORREÇÃO: ScrollConfiguration para evitar esticamento visual ---
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Seletor de Foto
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
                        bottom: 0, right: 0,
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

                _buildTextField(
                  controller: _nomeController, 
                  hint: "Nome Completo", 
                  icon: Icons.person,
                  enabled: true
                ),
                const SizedBox(height: 20),

                // E-mail bloqueado para edição
                _buildTextField(
                  controller: _emailController, 
                  hint: "E-mail", 
                  icon: Icons.email_outlined,
                  enabled: false 
                ),
                const SizedBox(height: 20),

                if (!_isOrganizador) ...[
                  // Matrícula bloqueada para edição
                  _buildTextField(
                    controller: _matriculaController, 
                    hint: "Matrícula", 
                    icon: Icons.badge_outlined,
                    enabled: false 
                  ),
                  const SizedBox(height: 20),

                  // Seletor de Curso
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
                        validator: (value) => value == null ? "Selecione um curso" : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ] else ...[
                   const SizedBox(height: 20),
                ],

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
                        : const Text("Salvar alterações", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, 
    required String hint, 
    required IconData icon, 
    bool enabled = true
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFFF8F9FA) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        readOnly: !enabled,
        validator: (value) => value == null || value.isEmpty ? "Campo obrigatório" : null,
        style: TextStyle(color: enabled ? Colors.black : Colors.grey[600]),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: enabled ? Colors.grey : Colors.grey[400], size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final Color primaryRed = const Color(0xFFA93244);

  // Controladores vazios para novo evento
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isOnline = false;
  bool _isPublished = false; // Começa como rascunho por padrão

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Novo Evento",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Validação simples
              if (_titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Por favor, dê um nome ao evento.")),
                );
                return;
              }

              // Lógica de Criar no Backend
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Evento criado com sucesso!")),
              );
              Navigator.pop(context);
            },
            child: Text("Criar", style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. CAPA (Placeholder para upload) ---
            Center(
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selecionar imagem da galeria")));
                },
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey[400]),
                      const SizedBox(height: 10),
                      Text("Adicionar capa", style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // --- 2. INFORMAÇÕES BÁSICAS ---
            _buildSectionTitle("Informações Básicas"),
            _buildTextField(label: "Nome do evento", controller: _titleController, hint: "Ex: Workshop de Flutter"),
            const SizedBox(height: 15),
            _buildTextField(label: "Descrição", controller: _descController, maxLines: 4, hint: "Sobre o que é o evento?"),

            const SizedBox(height: 25),

            // --- 3. DATA E HORA ---
            _buildSectionTitle("Quando?"),
            Row(
              children: [
                Expanded(child: _buildTextField(label: "Data", controller: _dateController, icon: Icons.calendar_today, hint: "DD/MM/AAAA")),
                const SizedBox(width: 15),
                Expanded(child: _buildTextField(label: "Horário", controller: _timeController, icon: Icons.access_time, hint: "00:00")),
              ],
            ),

            const SizedBox(height: 25),

            // --- 4. LOCALIZAÇÃO ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle("Onde?"),
                Row(
                  children: [
                    Text("Evento Online", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Switch(
                        activeColor: primaryRed,
                        value: _isOnline,
                        onChanged: (val) => setState(() => _isOnline = val)
                    ),
                  ],
                )
              ],
            ),
            if (!_isOnline)
              _buildTextField(label: "Local / Endereço", controller: _locationController, icon: Icons.location_on_outlined, hint: "Ex: Auditório Principal")
            else
              _buildTextField(label: "Link da transmissão", controller: _locationController, icon: Icons.link, hint: "https://..."),

            const SizedBox(height: 25),

            // --- 5. INGRESSOS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle("Ingressos"),
                TextButton.icon(
                    onPressed: (){
                      // Adicionar lógica de novo lote
                    },
                    icon: Icon(Icons.add, size: 16, color: primaryRed),
                    label: Text("Adicionar Lote", style: TextStyle(color: primaryRed))
                )
              ],
            ),
            // Mensagem de vazio inicial
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[200]!)
              ),
              child: const Text("Nenhum ingresso criado ainda.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ),

            const SizedBox(height: 25),

            // --- 6. VISIBILIDADE ---
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[200]!)
              ),
              child: Row(
                children: [
                  Icon(_isPublished ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_isPublished ? "Publicar Evento" : "Salvar como Rascunho", style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          _isPublished ? "O evento ficará visível imediatamente" : "Você poderá publicar depois",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                      activeColor: Colors.green,
                      value: _isPublished,
                      onChanged: (val) => setState(() => _isPublished = val)
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Botão Principal de Ação (redundante com o do topo, mas bom para UX)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Mesma lógica de salvar
                  if (_titleController.text.isEmpty) return;
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0
                ),
                child: const Text("Criar Evento", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    IconData? icon,
    String? hint
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey, size: 20) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFA93244)),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }
}
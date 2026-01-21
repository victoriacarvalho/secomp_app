import 'package:flutter/material.dart';

class ManageEventDetailScreen extends StatefulWidget {
  // Num app real, você passaria o ID ou objeto do evento aqui para carregar os dados
  const ManageEventDetailScreen({super.key});

  @override
  State<ManageEventDetailScreen> createState() => _ManageEventDetailScreenState();
}

class _ManageEventDetailScreenState extends State<ManageEventDetailScreen> {
  final Color primaryRed = const Color(0xFFA93244);

  // Controladores para os campos de texto
  final _titleController = TextEditingController(text: "Mineração de dados");
  final _descController = TextEditingController(text: "Aprenda tudo sobre Data Mining neste workshop prático...");
  final _dateController = TextEditingController(text: "26/01/2026");
  final _timeController = TextEditingController(text: "14:00");
  final _locationController = TextEditingController(text: "Sala C203, Bloco C");

  bool _isOnline = false;
  bool _isPublished = true;

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
          "Editar Evento",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Lógica de Salvar no Backend
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Alterações salvas com sucesso!")),
              );
              Navigator.pop(context);
            },
            child: Text("Salvar", style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. CAPA DO EVENTO ---
            Center(
              child: Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                      image: const DecorationImage(
                        image: NetworkImage('https://picsum.photos/500/300'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.camera_alt, size: 16),
                          SizedBox(width: 5),
                          Text("Alterar capa", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- 2. INFORMAÇÕES BÁSICAS ---
            _buildSectionTitle("Informações Básicas"),
            _buildTextField(label: "Nome do evento", controller: _titleController),
            const SizedBox(height: 15),
            _buildTextField(label: "Descrição", controller: _descController, maxLines: 4),

            const SizedBox(height: 25),

            // --- 3. DATA E HORA ---
            _buildSectionTitle("Quando?"),
            Row(
              children: [
                Expanded(child: _buildTextField(label: "Data Início", controller: _dateController, icon: Icons.calendar_today)),
                const SizedBox(width: 15),
                Expanded(child: _buildTextField(label: "Horário", controller: _timeController, icon: Icons.access_time)),
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
              _buildTextField(label: "Local / Endereço", controller: _locationController, icon: Icons.location_on_outlined)
            else
              _buildTextField(label: "Link da transmissão", controller: TextEditingController(text: "https://zoom.us/j/123..."), icon: Icons.link),

            const SizedBox(height: 25),

            // --- 5. INGRESSOS (Estilo Sympla) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle("Ingressos"),
                TextButton.icon(
                    onPressed: (){},
                    icon: Icon(Icons.add, size: 16, color: primaryRed),
                    label: Text("Criar ingresso", style: TextStyle(color: primaryRed))
                )
              ],
            ),

            // Lista de Ingressos Criados
            _buildTicketCard("Entrada Gratuita", "Gratuito", "50/100"),
            _buildTicketCard("Lote 1 - Estudante", "R\$ 15,00", "10/50"),

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
                        Text(_isPublished ? "Evento Publicado" : "Rascunho", style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          _isPublished ? "Visível para todos no app" : "Invisível para o público",
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

            // Botão Excluir Evento
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                child: const Text("Cancelar Evento", style: TextStyle(color: Colors.red)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES PARA FORMULÁRIO ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, int maxLines = 1, IconData? icon}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
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

  Widget _buildTicketCard(String name, String price, String availability) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("$price • $availability vendidos", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: (){})
        ],
      ),
    );
  }
}
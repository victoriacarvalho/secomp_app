import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class EventDetailScreen extends StatelessWidget {
  final String title;
  final String location;
  final String points;
  final String imagePath;

  EventDetailScreen({
    super.key,
    required this.title,
    required this.location,
    required this.points,
    required this.imagePath,
  });

  // Cores do projeto
  final Color primaryRed = const Color(0xFF9A202F);

  // --- 1. TEXTO COMPLETO DA DESCRIÇÃO ---
  final String fullDescription = """
Descubra estratégias essenciais para planejar seu crescimento profissional e se destacar no mercado atual. Aprenda a identificar oportunidades, desenvolver competências chave e construir uma rede de contatos sólida.

Nesta palestra, abordaremos:
• Análise de tendências de mercado.
• Desenvolvimento de soft skills e hard skills.
• Como criar um plano de carreira executável.
• A importância do networking estratégico.

Prepare-se para dar o próximo passo na sua jornada profissional com dicas práticas e insights valiosos de especialistas da área.
""";

  // --- 2. FUNÇÃO PARA MOSTRAR O POP-UP (BottomSheet) ---
  void _showFullDescription(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sobre a palestra',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Text(
                        fullDescription,
                        style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                          backgroundColor: primaryRed,
                          side: BorderSide(color: primaryRed),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                      ),
                      child: const Text("Fechar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
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
    final double imageHeight = MediaQuery.of(context).size.height * 0.45;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. CAMADA DE FUNDO (Imagem)
          Container(
            height: imageHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                // OBS: Usei AssetImage pois foi o que você mandou na tela anterior.
                // Se der erro, troque por NetworkImage se for URL externa.
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. CAMADA DE CONTEÚDO (Scroll)
          SingleChildScrollView(
            child: Column(
              children: [
                // Espaço transparente para mostrar a imagem
                SizedBox(height: imageHeight - 40),

                // O cartão branco arredondado
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5)),
                    ],
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Título e Palestrante
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                                const Text('José da Silva', style: TextStyle(color: Colors.grey, fontSize: 16)),
                              ],
                            ),
                          ),
                          const CircleAvatar(radius: 30, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11')),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Ícones de Informação
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
                          const SizedBox(width: 4),
                          Text(location, style: const TextStyle(color: Colors.grey)),
                          const SizedBox(width: 15),
                          const Icon(Icons.people_outline, color: Colors.grey, size: 20),
                          const SizedBox(width: 4),
                          Text('$points(35)', style: const TextStyle(color: Colors.grey)),
                          const Spacer(),
                          Text('R\$0', style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold, fontSize: 18)),
                          const Text('/pessoa', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Miniaturas
                      Row(children: List.generate(5, (index) => _buildThumbnail())),
                      const SizedBox(height: 30),

                      // Descrição
                      const Text('Sobre a palestra', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),

                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.6),
                          children: [
                            const TextSpan(text: 'Descubra estratégias essenciais para planejar seu crescimento profissional e se destacar no mercado atual. Aprenda a identificar oportunidades... '),
                            TextSpan(
                              text: 'Leia mais',
                              style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _showFullDescription(context);
                                },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Botão Inscrever
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryRed,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            // Feedback visual
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Inscrição realizada com sucesso!")),
                            );
                          },
                          child: const Text('Inscrever', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. CAMADA DE BOTÕES (MOVIDA PARA O FINAL PARA FICAR NO TOPO)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // AQUI ESTÁ A LÓGICA DE VOLTAR
                  _buildCircleButton(
                      Icons.arrow_back_ios_new,
                          () {
                        // Verifica se pode voltar antes de tentar
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      }
                  ),
                  _buildCircleButton(Icons.bookmark_border, () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 50, height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(image: NetworkImage('https://picsum.photos/200'), fit: BoxFit.cover),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class EventImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;

  const EventImage({
    super.key, 
    required this.imageUrl, 
    this.fit = BoxFit.cover, 
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _placeholder();
    }

    // LÓGICA DE DETECÇÃO: Verifica se é um asset local ou um link da web
    if (imageUrl!.startsWith('assets/')) {
      return Image.asset(
        imageUrl!,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }

    // Se não for asset, tenta carregar como imagem da rede (internet)
    return Image.network(
      imageUrl!,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint("Erro ao carregar imagem da rede: $error");
        return _placeholder();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const Icon(Icons.image, color: Colors.grey, size: 40),
    );
  }
}
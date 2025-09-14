import 'dart:typed_data';

import 'package:app_gcm_sa/utils/estilos.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class AssinaturaView extends StatefulWidget {
  const AssinaturaView({super.key});

  @override
  State<AssinaturaView> createState() => _AssinaturaViewState();
}

class _AssinaturaViewState extends State<AssinaturaView> {
  // Controller para a área de assinatura
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 2.5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Confirma e retorna a imagem da assinatura para a tela anterior
  Future<void> _confirmarAssinatura() async {
    if (_controller.isNotEmpty) {
      // Converte a assinatura para uma imagem em formato PNG (bytes)
      final Uint8List? data = await _controller.toPngBytes();
      
      // Retorna os dados da imagem para a tela anterior
      if (mounted) {
        Navigator.of(context).pop(data);
      }
    }
  }

  /// Limpa a área de assinatura
  void _limparAssinatura() {
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registre sua Assinatura'),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(null), // Retorna null se fechar
        ),
        actions: [
          IconButton(
            tooltip: 'Desfazer',
            icon: const Icon(Icons.undo),
            onPressed: () {
              if (_controller.isNotEmpty) _controller.undo();
            },
          ),
          IconButton(
            tooltip: 'Limpar',
            icon: const Icon(Icons.clear),
            onPressed: _limparAssinatura,
          ),
        ],
      ),
      body: Column(
        children: [
          // A área de assinatura (quadro branco)
          Expanded(
            child: Signature(
              controller: _controller,
              backgroundColor: Colors.grey[200]!,
            ),
          ),
          // Barra de botões inferior
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            color: Colors.white,
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _confirmarAssinatura,
                  style: ElevatedButton.styleFrom(backgroundColor: Estilos.preto),
                  child: const Text('Confirmar Assinatura', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


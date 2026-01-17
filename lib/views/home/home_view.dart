import 'dart:async';
import 'package:app_gcm_sa/components/card_nav_drawer_widget.dart';
import 'package:app_gcm_sa/components/snackbar_widget.dart';
import 'package:app_gcm_sa/models/ocorrencia_model.dart';
import 'package:app_gcm_sa/services/ocorrencia_service.dart';
import 'package:app_gcm_sa/services/session_manager.dart';
import 'package:app_gcm_sa/services/signalr_location_service.dart';
import 'package:app_gcm_sa/utils/estilos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Import do Flutter Map
import 'package:latlong2/latlong.dart'; // Import para LatLng

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Controller do Flutter Map
  final MapController _mapController = MapController();
  
  // Lista de marcadores do Flutter Map
  List<Marker> _markers = [];
  
  final OcorrenciaService _apiService = OcorrenciaService();
  final SignalRLocationService _socketService = SignalRLocationService();
  final SessionManager _sessionManager = SessionManager();

  // Centro de Santo André
  final LatLng _posicaoInicialSantoAndre = const LatLng(-23.6593, -46.5332);

  @override
  void initState() {
    super.initState();
    _inicializarMapa();
  }

  @override
  void dispose() {
    _socketService.stopConnection();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _inicializarMapa() async {
    final token = await _sessionManager.getToken();
    if (token == null) return;

    // 1. Carrega ocorrências do dia (histórico recente)
    await _carregarOcorrenciasDoDia(token);

    // 2. Conecta ao Websocket para receber novas em tempo real
    _socketService.onLocationReceived = _onNovaOcorrenciaRecebida;
    await _socketService.startConnection(token);
  }

  Future<void> _carregarOcorrenciasDoDia(String token) async {
    try {
      final response = await _apiService.pesquisarOcorrencias(
        token: token,
        indDtaHoje: 'S', // Filtro para trazer apenas as de hoje
        pageSize: 100,
      );

      // Limpa e reconstrói a lista de marcadores
      final novosMarcadores = response.items.map((oc) => _criarMarcador(oc)).toList();

      setState(() {
        _markers = novosMarcadores;
      });
    } catch (e) {
      print('Erro ao carregar histórico: $e');
    }
  }

  // Chamado quando o SignalR recebe um novo evento
  void _onNovaOcorrenciaRecebida(Ocorrencia novaOcorrencia) {
    if (!mounted) return;

    setState(() {
      // Adiciona o novo marcador à lista
      _markers.add(_criarMarcador(novaOcorrencia));
    });

    // Feedback visual (SnackBar)
    showCustomSnackbar(
      context, 
      message: 'NOVO SOS RECEBIDO!\nVítima: ${novaOcorrencia.vitima}',
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 5),
    );

    // Move a câmera para a nova ocorrência com Zoom
    _mapController.move(
      LatLng(novaOcorrencia.latitude, novaOcorrencia.longitude), 
      17.0 // Zoom level mais alto
    );
    
    // Abre os detalhes automaticamente
    _mostrarDetalhes(novaOcorrencia);
  }

  // Cria um marcador do Flutter Map
  Marker _criarMarcador(Ocorrencia oc) {
    return Marker(
      point: LatLng(oc.latitude, oc.longitude),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => _mostrarDetalhes(oc),
        child: const Icon(
          Icons.location_on, 
          color: Colors.red, 
          size: 40,
          shadows: [
            Shadow(blurRadius: 10, color: Colors.black45, offset: Offset(2, 2))
          ],
        ),
      ),
    );
  }

  // --- FUNÇÃO CORRIGIDA PARA EVITAR ESTOURO DE LAYOUT ---
  void _mostrarDetalhes(Ocorrencia oc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que o modal ocupe mais espaço se necessário
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        // Adiciona padding para evitar sobreposição com barras de sistema
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, 
        ),
        child: SingleChildScrollView( // Permite rolar o conteúdo se for muito grande
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
                    const SizedBox(width: 12),
                    // Flexible evita que o título estoure horizontalmente
                    const Flexible(
                      child: Text(
                        "ALERTA DE PÂNICO", 
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8), // Espaço antes do botão fechar
                    IconButton(
                      icon: const Icon(Icons.close), 
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const Divider(height: 30),
                _infoRow("Vítima:", oc.vitima),
                const SizedBox(height: 8),
                _infoRow("Autor:", oc.autor),
                const SizedBox(height: 8),
                _infoRow("Endereço:", oc.endereco),
                const SizedBox(height: 8),
                _infoRow("Data/Hora:", oc.data),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.map),
                    label: const Text("Abrir no Google Maps (Navegação)", style: TextStyle(fontSize: 16)),
                    onPressed: () {
                      // Aqui entraria a lógica do url_launcher para abrir rotas externas
                      // Exemplo: google.navigation:q=latitude,longitude
                      Navigator.pop(context);
                    },
                  ),
                ),
                // Adiciona um espaço extra no final para garantir que nada fique colado na borda
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Estilos.appbar(context, 'Monitoramento SOS'),
      drawer: const NavigationDrawerWidget(),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _posicaoInicialSantoAndre,
          initialZoom: 13.0,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.gcm.app',
          ),
          
          MarkerLayer(
            markers: _markers,
          ),

          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                child: const Icon(Icons.my_location, color: Colors.black87),
                onPressed: () {
                  _mapController.move(_posicaoInicialSantoAndre, 13.0);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

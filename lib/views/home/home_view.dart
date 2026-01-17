import 'dart:async';
import 'package:app_gcm_sa/components/card_nav_drawer_widget.dart';
import 'package:app_gcm_sa/components/snackbar_widget.dart';
import 'package:app_gcm_sa/models/ocorrencia_model.dart';
import 'package:app_gcm_sa/services/ocorrencia_service.dart';
import 'package:app_gcm_sa/services/session_manager.dart';
import 'package:app_gcm_sa/services/signalr_location_service.dart';
import 'package:app_gcm_sa/utils/estilos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];

  final OcorrenciaService _apiService = OcorrenciaService();
  final SignalRLocationService _socketService = SignalRLocationService();
  final SessionManager _sessionManager = SessionManager();

  final LatLng _posicaoInicialSantoAndre = const LatLng(-23.6593, -46.5332);
  String? _userToken;

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
    _userToken = await _sessionManager.getToken();
    if (_userToken == null) return;

    await _carregarOcorrenciasDoDia(_userToken!);

    _socketService.onLocationReceived = _onNovaOcorrenciaRecebida;
    await _socketService.startConnection(_userToken!);
  }

  Future<void> _carregarOcorrenciasDoDia(String token) async {
    try {
      final response = await _apiService.pesquisarOcorrencias(
        token: token,
        indDtaHoje: 'S',
        pageSize: 100,
      );

      final novosMarcadores =
          response.items.map((oc) => _criarMarcador(oc)).toList();

      setState(() {
        _markers = novosMarcadores;
      });
    } catch (e) {
      print('Erro ao carregar histórico: $e');
    }
  }

  void _onNovaOcorrenciaRecebida(Ocorrencia novaOcorrencia) {
    if (!mounted) return;

    setState(() {
      _markers.add(_criarMarcador(novaOcorrencia));
    });

    showCustomSnackbar(
      context,
      message: 'NOVO SOS RECEBIDO!\nVítima: ${novaOcorrencia.vitima}',
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 5),
    );

    _mapController.move(
      LatLng(novaOcorrencia.latitude, novaOcorrencia.longitude),
      17.0,
    );

    _mostrarDetalhes(novaOcorrencia);
  }

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
            Shadow(blurRadius: 10, color: Colors.black45, offset: Offset(2, 2)),
          ],
        ),
      ),
    );
  }

  // --- FUNÇÃO DO MODAL DE DETALHES COMPLETOS ---
  void _mostrarDetalhes(Ocorrencia ocParcial) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors
              .transparent, // Fundo transparente para ver os cantos arredondados
      builder:
          (context) => Container(
            height:
                MediaQuery.of(context).size.height * 0.85, // Ocupa 85% da tela
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: FutureBuilder<Ocorrencia>(
              // Busca os detalhes completos usando o UUID
              future: _apiService.getDetalhesOcorrencia(
                ocParcial.uuidOcorrencia ?? ocParcial.codigo,
                _userToken!,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Estilos.azulClaro),
                  );
                }

                // Se falhar ou se não tiver UUID, usa os dados parciais que já temos
                final oc = snapshot.data ?? ocParcial;

                return Column(
                  children: [
                    // Barra de Título e Fechar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Detalhes da Ocorrência",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Conteúdo Rolável
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status e Badges
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        oc.atendido == 'S'
                                            ? Colors.green
                                            : Colors.red,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        oc.atendido == 'S'
                                            ? Icons.check_circle
                                            : Icons.warning,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        oc.atendido == 'S'
                                            ? "ATENDIDO"
                                            : "PENDENTE",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (oc.indArmaFogo == 'S')
                                  _buildRiskBadge(
                                    "Arma de Fogo",
                                    Colors.red.shade900,
                                  ),
                                if (oc.indPassagemCriminal == 'S')
                                  _buildRiskBadge(
                                    "Passagem Criminal",
                                    Colors.orange.shade800,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Endereço
                            _buildSectionHeader(Icons.map, "Localização"),
                            Text(
                              oc.endereco,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Data: ${DateFormat('dd/MM/yyyy', 'pt_BR').format(DateTime.parse(oc.data).toLocal())}",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Veículo (Se houver)
                            if (oc.veiculoModelo != null ||
                                oc.veiculoPlaca != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.orange.shade200,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "VEÍCULO DO AUTOR",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildVeiculoInfo(
                                          "Modelo",
                                          oc.veiculoModelo ?? '-',
                                        ),
                                        _buildVeiculoInfo(
                                          "Placa",
                                          oc.veiculoPlaca ?? '-',
                                        ),
                                        _buildVeiculoInfo(
                                          "Cor",
                                          oc.veiculoCor ?? '-',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Cards de Vítima e Autor (Lado a Lado)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Vítima
                                Expanded(
                                  child: _buildProfileCard(
                                    "VÍTIMA",
                                    oc.vitima,
                                    oc.codigoVitima.toString(),
                                    Colors.pink.shade100,
                                    Colors.pink.shade700,
                                    _apiService.getFotoUrl(
                                      'vitima',
                                      oc.codigoVitima,
                                    ),
                                    _userToken!,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Autor
                                Expanded(
                                  child: _buildProfileCard(
                                    "AUTOR",
                                    oc.autor,
                                    oc.codigoAutor.toString(),
                                    Colors.grey.shade300,
                                    Colors.black87,
                                    _apiService.getFotoUrl(
                                      'autor',
                                      oc.codigoAutor,
                                    ),
                                    _userToken!,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),

                    // Botões de Ação Fixos no Rodapé
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.directions),
                              label: const Text("Traçar Rota (Google Maps)"),
                              onPressed: () {
                                _abrirGoogleMaps(oc.latitude, oc.longitude);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
    );
  }

  Widget _buildRiskBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildVeiculoInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProfileCard(
    String type,
    String name,
    String id,
    Color bgColor,
    Color textColor,
    String imageUrl,
    String token,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Text(
              type,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage(
              imageUrl,
              headers: {'Authorization': 'Bearer $token'},
            ),
            backgroundColor: Colors.grey.shade200,
            onBackgroundImageError: (_, __) => const Icon(Icons.person),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "ID: $id",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirGoogleMaps(double lat, double lng) async {
    final url = Uri.parse("google.navigation:q=$lat,$lng");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Fallback para navegador web se o app não estiver instalado
      final webUrl = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng",
      );
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl);
      }
    }
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
          MarkerLayer(markers: _markers),
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

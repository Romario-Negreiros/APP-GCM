import 'package:app_gcm_sa/components/card_nav_drawer_widget.dart';
import 'package:app_gcm_sa/services/eventos_service.dart';
import 'package:app_gcm_sa/services/session_manager.dart';
import 'package:app_gcm_sa/utils/estilos.dart';
import 'package:flutter/material.dart';

class Event {
  final int idEventovoluntario;
  final int idEvento;
  final String data;
  final String titulo;
  String leuNotificacaoEvento;
  final String funcaoVoluntario;

  final String ordemDeServico;
  final String rua;
  final String numero;
  final String bairro;
  final String cidade;
  final String horaInicio;
  final String horaFinal;
  final String inspetoria;

  Event({
    required this.idEventovoluntario,
    required this.idEvento,
    required this.data,
    required this.titulo,
    required this.leuNotificacaoEvento,
    required this.funcaoVoluntario,
    required this.ordemDeServico,
    required this.rua,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.horaInicio,
    required this.horaFinal,
    required this.inspetoria,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      idEventovoluntario: json['id_eventovoluntario'] ?? 0,
      idEvento: json['id_evento'] ?? 0,
      data: json['data'] ?? '',
      titulo: json['dsc_titulo'] ?? 'Evento sem título',
      leuNotificacaoEvento: json['ind_leu_notificacao'] ?? 'N',
      funcaoVoluntario: json['funcao_voluntario'] ?? 'Não atribuída',

      ordemDeServico: json['dsc_ordem_servico'] ?? 'Não informada',
      rua: json['dsc_rua'] ?? 'Não informada',
      numero: json['dsc_numero'] ?? 'S/N',
      bairro: json['dsc_bairro'] ?? 'Não informado',
      cidade: json['dsc_cidade'] ?? 'Não informada',
      horaInicio: json['hor_inicio'] ?? '--:--',
      horaFinal: json['hor_final'] ?? '--:--',
      inspetoria: json['dsc_inspetoria'] ?? 'Não informada',
    );
  }
}

class EventosView extends StatefulWidget {
  const EventosView({super.key});

  @override
  State<EventosView> createState() => _EventosViewState();
}

class _EventosViewState extends State<EventosView> {
  List<Event> events = [];
  bool _isLoading = true;

  final EventosService _eventosService = EventosService();
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    _fetchEventos();
  }

  Future<void> _sincronizarNotificacaoLida(Event evento) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _sessionManager.getToken();
      if (token == null) return; // Não pode sincronizar sem token

      await _eventosService.marcarNotificacoesComoLidas([evento], token);
    } catch (e) {
      debugPrint('Erro ao sincronizar notificações lidas: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchEventos() async {
    try {
      final codFuncionario = await _sessionManager.getCodFuncionario();
      final token = await _sessionManager.getToken();

      if (codFuncionario == null || token == null) {
        throw Exception("Sessão inválida. Faça o login novamente.");
      }

      final List<dynamic> apiData = await _eventosService.getEventos(
        codFuncionario,
        token,
      );

      setState(() {
        events = apiData.map((json) => Event.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar os eventos: ${e.toString()}'),
          ),
        );
      }
    }
  }

  void _exibirDetalhesDoEvento(Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            event.titulo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildDetailRow(
                  Icons.article_outlined,
                  'Ordem de Serviço',
                  event.ordemDeServico,
                ),
                _buildDetailRow(Icons.calendar_today, 'Data', event.data),
                _buildDetailRow(
                  Icons.schedule,
                  'Horário',
                  '${event.horaInicio} às ${event.horaFinal}',
                ),
                _buildDetailRow(
                  Icons.location_on,
                  'Endereço',
                  '${event.rua}, ${event.numero} - ${event.bairro}, ${event.cidade}',
                ),
                _buildDetailRow(
                  Icons.corporate_fare,
                  'Inspetoria',
                  event.inspetoria,
                ),
                _buildDetailRow(
                  Icons.person,
                  'Função',
                  event.funcaoVoluntario,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Fechar',
                style: TextStyle(
                  color: Estilos.azulClaro,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Estilos.azulClaro, size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: Estilos.appbar(context, 'Eventos'),
          drawer: const NavigationDrawerWidget(),
          backgroundColor: Estilos.branco,
          body: Container(
            color: Estilos.azulGradient4,
            child: Container(
              height: double.infinity,
              decoration: const BoxDecoration(
                color: Estilos.branco,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Estilos.azulClaro,
                        ),
                      )
                      : events.isNotEmpty
                      ? ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return Card(
                            color:
                                event.leuNotificacaoEvento == 'S' &&
                                        event.idEvento > 0
                                    ? Colors.white
                                    : Colors.red.shade100,
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              title: Text(
                                event.titulo,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(event.data),
                              onTap: () async {
                                // Marca o evento como lido e exibe o modal
                                if (event.leuNotificacaoEvento == 'N' &&
                                    event.idEvento > 0) {
                                  setState(() {
                                    event.leuNotificacaoEvento = 'S';
                                  });
                                  await _sincronizarNotificacaoLida(event);
                                }
                                if (event.idEvento > 0) {
                                  _exibirDetalhesDoEvento(event);
                                }
                              },
                            ),
                          );
                        },
                      )
                      : const Center(child: Text('Nenhum evento encontrado')),
            ),
          ),
        ),
      ],
    );
  }
}

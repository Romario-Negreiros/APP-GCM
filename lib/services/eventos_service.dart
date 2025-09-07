import 'dart:convert';
import 'package:app_gcm_sa/utils/configuracoes.dart';
import 'package:app_gcm_sa/views/hora_extra/eventos/eventos_view.dart';
import 'package:http/http.dart' as http;

class EventosService {
  final String _baseUrl = Configuracoes.apiUrl;

  Future<void> marcarNotificacoesComoLidas(List<Event> eventos, String token) async {
    final url = Uri.parse('$_baseUrl/eventos-voluntario/notificacao');

    // Mapeia a lista de eventos para o formato que a API espera
    final List<Map<String, dynamic>> payload = eventos.map((evento) => {
      "id_eventovoluntario": evento.idEventovoluntario,
      "ind_leu_notificacao": evento.leuNotificacaoEvento
    }).toList();

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    // O status 204 (No Content) também indica sucesso
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao sincronizar as notificações.');
    }
  }

  Future<List<dynamic>> getEventos(String codFuncionario, String token) async {
    final url = Uri.parse('$_baseUrl/eventos-voluntario/$codFuncionario');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception(
        'Falha ao carregar os eventos. Status: ${response.statusCode}',
      );
    }
  }
}

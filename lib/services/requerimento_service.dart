import 'dart:convert';
import 'package:app_gcm_sa/models/requerimento_model.dart'; // Importa o novo modelo
import 'package:http/http.dart' as http;

class RequerimentoService {
  final String _baseUrl =
      'https://apihomologacao.santoandre.sp.gov.br/bdgm/api/v1';

  /// Insere um novo requerimento no sistema.
  Future<void> inserirRequerimento(
    Map<String, dynamic> payload,
    String token,
  ) async {
    final url = Uri.parse('$_baseUrl/requerimento');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    // O status 204 (No Content) indica sucesso para esta requisição.
    if (response.statusCode != 204) {
      try {
        final responseBody = jsonDecode(response.body);
        throw Exception(
          responseBody['message'] ?? 'Falha ao inserir o requerimento.',
        );
      } catch (_) {
        throw Exception(
          'Falha ao inserir o requerimento. Status: ${response.statusCode}',
        );
      }
    }
  }

  /// Retorna a lista de requerimentos de um funcionário específico.
  Future<List<Requerimento>> listarRequerimentos(
    String codFuncionario,
    String token,
  ) async {
    final url = Uri.parse('$_baseUrl/requerimento/listar/$codFuncionario');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // A API retorna uma lista de objetos JSON.
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      // Mapeia cada objeto JSON para um objeto do modelo Requerimento.
      return data.map((json) => Requerimento.fromJson(json)).toList();
    } else {
      throw Exception(
        'Falha ao listar os requerimentos. Status: ${response.statusCode}',
      );
    }
  }

  /// Retorna os dados de um requerimento específico pelo seu ID.
  Future<Requerimento> getRequerimento(
    int seqRequerimento,
    String token,
  ) async {
    final url = Uri.parse('$_baseUrl/requerimento/$seqRequerimento');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // A API retorna um único objeto JSON.
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      // Cria um objeto do modelo Requerimento a partir do JSON.
      return Requerimento.fromJson(data);
    } else {
      throw Exception(
        'Falha ao obter o requerimento. Status: ${response.statusCode}',
      );
    }
  }
}

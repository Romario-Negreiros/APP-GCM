import 'dart:convert';
import 'dart:typed_data';
import 'package:app_gcm_sa/models/requerimento_model.dart'; // Importa o novo modelo
import 'package:app_gcm_sa/utils/configuracoes.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class RequerimentoService {
  final String _baseUrl = Configuracoes.apiUrl;

  /// Insere um novo requerimento no sistema.
  Future<void> inserirRequerimento({
    required Map<String, String> fields,
    required Uint8List assinaturaBytes,
    required String token,
  }) async {
    final url = Uri.parse('$_baseUrl/requerimento');
    var request = http.MultipartRequest('POST', url);

    // Adiciona os headers de autorização
    request.headers['Authorization'] = 'Bearer $token';

    // Adiciona os campos de texto do formulário
    request.fields.addAll(fields);

    // Adiciona o arquivo da assinatura
    request.files.add(
      http.MultipartFile.fromBytes(
        'arq_assinatura',
        assinaturaBytes,
        filename: 'assinatura.png',
        contentType: MediaType('image', 'png'),
      ),
    );

    // Envia a requisição e aguarda a resposta
    var streamedResponse = await request.send();

    // Verifica o status da resposta
    if (streamedResponse.statusCode != 204) {
      final response = await http.Response.fromStream(streamedResponse);
      try {
        final responseBody = jsonDecode(response.body);
        throw Exception(
          responseBody['message'] ?? 'Falha ao inserir o requerimento.',
        );
      } catch (_) {
        throw Exception(
          'Falha ao inserir o requerimento. Status: ${streamedResponse.statusCode}',
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

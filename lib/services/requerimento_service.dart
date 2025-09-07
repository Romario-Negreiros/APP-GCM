import 'dart.convert';
import 'package.http/http.dart' as http;

class RequerimentoService {
  final String _baseUrl = 'https://apihomologacao.santoandre.sp.gov.br/bdgm/api/v1';

  /// Envia um novo requerimento para a API.
  Future<void> enviarRequerimento(Map<String, dynamic> payload, String token) async {
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
      // Tenta decodificar uma mensagem de erro do corpo da resposta, se houver.
      try {
        final responseBody = jsonDecode(response.body);
        throw Exception(responseBody['message'] ?? 'Falha ao enviar o requerimento.');
      } catch (_) {
        throw Exception('Falha ao enviar o requerimento. Status: ${response.statusCode}');
      }
    }
  }
}

import 'dart:convert';
import 'package:app_gcm_sa/models/ocorrencia_model.dart';
import 'package:http/http.dart' as http;

class OcorrenciaService {
  final String _baseUrl = 'https://apihomologacao.santoandre.sp.gov.br/alertamulher/api/v1/ocorrencia';

  Future<OcorrenciaResponse> pesquisarOcorrencias({
    required String token,
    int currentPage = 1,
    int pageSize = 10,
    String? orderBy,
    bool orderByDesc = false,
    String? dscBusca,
    String? indDtaHoje,
  }) async {
    final queryParams = <String, String>{
      'currentPage': currentPage.toString(),
      'pageSize': pageSize.toString(),
      'orderByDesc': orderByDesc.toString(),
    };

    if (orderBy != null) queryParams['orderBy'] = orderBy;
    if (dscBusca != null && dscBusca.isNotEmpty) queryParams['dsc_busca'] = dscBusca;
    if (indDtaHoje != null) queryParams['ind_dta_hoje'] = indDtaHoje;

    final uri = Uri.parse('$_baseUrl/pesquisar').replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return OcorrenciaResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Falha ao carregar ocorrências. Status: ${response.statusCode}');
    }
  }

  // --- NOVO MÉTODO: Obter Detalhes Completos ---
  Future<Ocorrencia> getDetalhesOcorrencia(String uuid, String token) async {
    final url = Uri.parse('$_baseUrl/$uuid');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return Ocorrencia.fromJson(json);
    } else {
      throw Exception('Falha ao carregar detalhes da ocorrência. Status: ${response.statusCode}');
    }
  }
  
  // URL para obter a imagem (não requer chamada, apenas formatação da URL)
  String getFotoUrl(String tipo, int id) {
    // Tipo: 'vitima' ou 'autor'
    return 'https://apihomologacao.santoandre.sp.gov.br/alertamulher/api/v1/$tipo/arquivo/$id/foto_$tipo.jpg';
  }
}
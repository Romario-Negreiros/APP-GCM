class Ocorrencia {
  final String codigo;
  final String data;
  final String vitima;
  final int codigoVitima;
  final String autor;
  final int codigoAutor;
  final double latitude;
  final double longitude;
  final String endereco;
  final String atendido;
  final String? dataAtendimento;
  final String? uuidOcorrencia;
  
  // Detalhes adicionais
  final String? descricao;
  final String? indArmaFogo; // 'S' ou 'N'
  final String? indPassagemCriminal; // 'S' ou 'N'
  final String? indDependenteQuimico; // 'S' ou 'N'
  
  // Veículo
  final String? veiculoModelo;
  final String? veiculoPlaca;
  final String? veiculoCor;

  Ocorrencia({
    required this.codigo,
    required this.data,
    required this.vitima,
    required this.codigoVitima,
    required this.autor,
    required this.codigoAutor,
    required this.latitude,
    required this.longitude,
    required this.endereco,
    required this.atendido,
    this.dataAtendimento,
    this.uuidOcorrencia,
    this.descricao,
    this.indArmaFogo,
    this.indPassagemCriminal,
    this.indDependenteQuimico,
    this.veiculoModelo,
    this.veiculoPlaca,
    this.veiculoCor,
  });

  factory Ocorrencia.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Ocorrencia(
      codigo: json['codigo']?.toString() ?? '',
      data: json['data'] ?? json['dta_ocorrencia'] ?? '', // Suporta ambos os formatos
      vitima: json['vitima'] ?? json['dsc_nome_vitima'] ?? 'Não informado',
      codigoVitima: json['codigoVitima'] ?? json['seq_vitima'] ?? 0,
      autor: json['autor'] ?? json['dsc_nome_autor'] ?? 'Não informado',
      codigoAutor: json['codigoAutor'] ?? json['seq_autor'] ?? 0,
      latitude: parseDouble(json['latitude'] ?? json['num_latitude']),
      longitude: parseDouble(json['longitude'] ?? json['num_longitude']),
      endereco: json['endereco'] ?? json['dsc_endereco'] ?? '',
      atendido: json['atendido'] ?? json['ind_atendido'] ?? 'N',
      dataAtendimento: json['dta_atendimento'],
      uuidOcorrencia: json['uuid_ocorrencia'],
      
      // Mapeamento dos detalhes
      descricao: json['dsc_ocorrencia'],
      indArmaFogo: json['ind_arma_fogo'],
      indPassagemCriminal: json['ind_passagem_criminal'],
      indDependenteQuimico: json['ind_dependente_quimico'],
      veiculoModelo: json['dsc_veiculo_modelo'],
      veiculoPlaca: json['dsc_veiculo_placa'],
      veiculoCor: json['dsc_veiculo_cor'],
    );
  }
}

class OcorrenciaResponse {
  final List<Ocorrencia> items;
  final int totalPages;
  final int totalItems;

  OcorrenciaResponse({
    required this.items,
    required this.totalPages,
    required this.totalItems,
  });

  factory OcorrenciaResponse.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List? ?? [];
    List<Ocorrencia> itemsList = list.map((i) => Ocorrencia.fromJson(i)).toList();

    return OcorrenciaResponse(
      items: itemsList,
      totalPages: json['totalPages'] ?? 0,
      totalItems: json['totalItems'] ?? 0,
    );
  }
}
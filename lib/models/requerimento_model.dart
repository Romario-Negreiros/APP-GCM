class Requerimento {
  final int seqRequerimento;
  final int codFuncionario;
  final String? dscNome;
  final String? dscGraduacao;
  final int numIf;
  final int codTurno;
  final String? dscTurno;
  final String? dscInspetoria;
  final String? dscPostoServico;
  final String? dscDestinatario;
  final String? dscAssunto;
  final String? dscRelatorio;
  final String? dtaSolicitacao;

  Requerimento({
    required this.seqRequerimento,
    required this.codFuncionario,
    this.dscNome,
    this.dscGraduacao,
    required this.numIf,
    required this.codTurno,
    this.dscTurno,
    this.dscInspetoria,
    this.dscPostoServico,
    this.dscDestinatario,
    this.dscAssunto,
    this.dscRelatorio,
    this.dtaSolicitacao,
  });

  factory Requerimento.fromJson(Map<String, dynamic> json) {
    return Requerimento(
      seqRequerimento: json['seq_requerimento'] ?? 0,
      codFuncionario: json['cod_funcionario'] ?? 0,
      dscNome: json['dsc_nome'],
      dscGraduacao: json['dsc_graduacao'],
      numIf: json['num_if'] ?? 0,
      codTurno: json['cod_turno'] ?? 0,
      dscTurno: json['dsc_turno'],
      dscInspetoria: json['dsc_inspetoria'],
      dscPostoServico: json['dsc_posto_servico'],
      dscDestinatario: json['dsc_destinatario'],
      dscAssunto: json['dsc_assunto'],
      dscRelatorio: json['dsc_relatorio'],
      dtaSolicitacao: json['dta_solicitacao'],
    );
  }
}

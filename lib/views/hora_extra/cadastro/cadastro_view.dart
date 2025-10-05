import 'package:app_gcm_sa/components/snackbar_widget.dart';
import 'package:app_gcm_sa/services/cadastro_service.dart';
import 'package:app_gcm_sa/services/session_manager.dart';
import 'package:app_gcm_sa/utils/estilos.dart';
import 'package:app_gcm_sa/utils/string_para_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:app_gcm_sa/components/card_nav_drawer_widget.dart';
import 'package:app_gcm_sa/utils/utils.dart';
import 'package:intl/intl.dart';

class Classe {
  final int codClasse;
  final String dscClasse;

  Classe({required this.codClasse, required this.dscClasse});

  factory Classe.fromApi(Map<String, dynamic> json) {
    return Classe(
      codClasse: json['cod_classe'] ?? 0,
      dscClasse: json['dsc_classe'] ?? 'N/A',
    );
  }
}

class Turno {
  final int codTurno;
  final String dscTurno;

  Turno({required this.codTurno, required this.dscTurno});

  factory Turno.fromApi(Map<String, dynamic> json) {
    return Turno(
      codTurno: json['cod_turno'] ?? 0,
      dscTurno: json['dsc_turno'] ?? 'N/A',
    );
  }
}

class Disponibilidade {
  final int? idEventovoluntario;
  final int? idEvento;
  final String data;
  final String? evento;
  final String? leuNotificacaoEvento;

  Disponibilidade({
    required this.data,
    this.idEventovoluntario,
    this.idEvento,
    this.evento,
    this.leuNotificacaoEvento,
  });

  factory Disponibilidade.fromApi(Map<String, dynamic> json) {
    return Disponibilidade(
      data: json['data'] ?? '',
      idEvento: json['id_evento'],
      idEventovoluntario: json['id_eventovoluntario'],
      evento: json['evento'],
      leuNotificacaoEvento: json['ind_leu_notificacao'],
    );
  }
}

class CadastroData {
  String identificacaoFuncional;
  String nomeCompleto;
  String nomeGuerra;
  int? codClasse;
  String? graduacao;
  String categoriaCnh;
  String email;
  int? codTurno;
  String? turnoTrabalho;
  String? dataAfastamento;
  String? dataVencimentoCNH;
  String telefoneCelular;
  List<Disponibilidade> disponibilidades;

  CadastroData({
    required this.identificacaoFuncional,
    required this.nomeCompleto,
    required this.nomeGuerra,
    this.codClasse,
    this.graduacao,
    required this.categoriaCnh,
    required this.email,
    this.codTurno,
    this.turnoTrabalho,
    this.dataAfastamento,
    this.dataVencimentoCNH,
    required this.telefoneCelular,
    required this.disponibilidades,
  });

  factory CadastroData.fromApi(Map<String, dynamic> json) {
    final String telefone =
        '(${json['ddd_telefone_celular'] ?? ''}) ${json['num_telefone_celular'] ?? ''}';

    var eventosApi = json['eventosVoluntario'] as List? ?? [];
    List<Disponibilidade> disponibilidadeList =
        eventosApi.map((i) => Disponibilidade.fromApi(i)).toList();

    return CadastroData(
      identificacaoFuncional: json['identificacao_funcional'] ?? '',
      nomeCompleto: json['nome_completo'] ?? '',
      nomeGuerra: json['nome_guerra'] ?? '',
      codClasse: json['cod_classe'],
      graduacao: json['graduacao'],
      categoriaCnh: json['categoria_cnh'] ?? '',
      email: json['email'] ?? '',
      codTurno: json['cod_turno'],
      turnoTrabalho: json["turno_trabalho"],
      dataAfastamento: json["dta_afastamento"],
      dataVencimentoCNH: json["dta_vencimento_cnh"],
      telefoneCelular: telefone,
      disponibilidades: disponibilidadeList,
    );
  }
}

class CadastroView extends StatefulWidget {
  const CadastroView({super.key});

  @override
  State<CadastroView> createState() => _CadastroViewState();
}

class _CadastroViewState extends State<CadastroView> {
  final _formKey = GlobalKey<FormState>();

  CadastroData? _cadastroData;
  List<Classe> _opcoesClasses = [];
  List<Turno> _opcoesTurnos = [];
  Classe? _classeSelecionada;
  Turno? _turnoSelecionado;
  final Set<String> _categoriasCnhSelecionadas = <String>{};
  static const categoriasValidas = {'A', 'B', 'C', 'D', 'E'};
  bool _isLoading = true;
  bool _isSaving = false; // Loading exclusivo do botão Salvar

  final SessionManager _sessionManager = SessionManager();
  final CadastroService _cadastroService = CadastroService();

  final _identificacaoFuncionalController = TextEditingController();
  final _nomeCompletoController = TextEditingController();
  final _nomeGuerraController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneCelularController = TextEditingController();
  final _disponibilidadeController = TextEditingController();
  final _dataAfastamentoController = TextEditingController();
  final _dataVencimentoCnhController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAndFillCadastroData();
  }

  Future<void> _fetchAndFillCadastroData() async {
    try {
      final codFuncionario = await _sessionManager.getCodFuncionario();
      final token = await _sessionManager.getToken();

      if (codFuncionario == null || token == null) {
        throw Exception("Sessão inválida. Faça o login novamente.");
      }

      final apiData = await _cadastroService.getCadastro(codFuncionario, token);
      final data = CadastroData.fromApi(apiData);

      final classes = await _cadastroService.getClasses(token);
      _opcoesClasses =
          classes.map<Classe>((c) {
            Classe classe = Classe.fromApi(c);

            if (c['cod_classe'] == data.codClasse) {
              _classeSelecionada = classe;
            }

            return classe;
          }).toList();

      final turnos = await _cadastroService.getTurnos(token);
      _opcoesTurnos =
          turnos.map<Turno>((c) {
            Turno turno = Turno.fromApi(c);

            if (c['cod_turno'] == data.codTurno) {
              _turnoSelecionado = turno;
            }

            return turno;
          }).toList();

      setState(() {
        _cadastroData = data;

        _identificacaoFuncionalController.text = data.identificacaoFuncional;
        _nomeCompletoController.text = data.nomeCompleto;
        _nomeGuerraController.text = data.nomeGuerra;
        _emailController.text = data.email;
        _telefoneCelularController.text = data.telefoneCelular;
        _dataAfastamentoController.text = data.dataAfastamento ?? "Em atividade";
        _dataVencimentoCnhController.text = data.dataVencimentoCNH ?? "Não informado";

        _categoriasCnhSelecionadas.clear();
        if (data.categoriaCnh.isNotEmpty) {
          _categoriasCnhSelecionadas.addAll(
            data.categoriaCnh
                .split('')
                .where((cat) => categoriasValidas.contains(cat)),
          );
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        showCustomSnackbar(
          context,
          message: 'Erro ao carregar dados: ${e.toString()}',
          backgroundColor: Estilos.danger,
        );
      }
    }
  }

  Future<void> _performSave() async {
    setState(() => _isSaving = true);

    try {
      // 1. Obter dados da sessão
      final codFuncionario = await _sessionManager.getCodFuncionario();
      final token = await _sessionManager.getToken();
      if (codFuncionario == null || token == null) {
        throw Exception("Sessão inválida.");
      }

      // 2. Montar o payload (corpo da requisição) com os dados da tela

      // Helper para extrair DDD e número do telefone formatado
      String ddd = '';
      String numero = '';
      final telefoneCompleto = _telefoneCelularController.text.replaceAll(
        RegExp(r'\D'),
        '',
      );
      if (telefoneCompleto.length == 11) {
        ddd = telefoneCompleto.substring(0, 2);
        numero = telefoneCompleto.substring(2);
      }

      // Helper para converter data de DD/MM/YYYY para formato ISO 8601
      String formatToIso(String ddMMyyyy) {
        final parts = ddMMyyyy.split('/');
        // Formato YYYY-MM-DDTHH:mm:ss.sssZ
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        ).toIso8601String();
      }

      // Criando o mapa do payload
      final Map<String, dynamic> payload = {
        "cod_funcionario": int.tryParse(codFuncionario) ?? 0,
        "nome_completo": _nomeCompletoController.text,
        "nome_guerra": _nomeGuerraController.text,
        "cod_classe": _classeSelecionada?.codClasse,
        "email": _emailController.text,
        "ddd_telefone_celular": ddd,
        "num_telefone_celular": numero,
        "cod_turno": _turnoSelecionado?.codTurno,
        "disponibilidades":
            _cadastroData?.disponibilidades
                .map(
                  (d) => {
                    "cod_funcionario": int.tryParse(codFuncionario) ?? 0,
                    "data": formatToIso(d.data),
                    "id_evento": d.idEvento ?? 0,
                    "ind_leu_notificacao": d.leuNotificacaoEvento ?? 'N',
                  },
                )
                .toList() ??
            [],
      };

      // 3. Chamar o serviço para enviar os dados
      await _cadastroService.salvarCadastro(payload, token);

      // 4. Mostrar snackbar de sucesso
      if (mounted) {
        showCustomSnackbar(context, message: 'Dados salvos com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(
          context,
          message: 'Erro ao salvar: ${e.toString()}',
          backgroundColor: Estilos.danger,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // Widget _buildCnhCheckbox(String categoria) {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       Text(categoria),
  //       Checkbox(
  //         value: _categoriasCnhSelecionadas.contains(categoria),
  //         onChanged: (bool? isChecked) {
  //           final novoSet = Set<String>.from(_categoriasCnhSelecionadas);
  //           if (isChecked == true) {
  //             novoSet.add(categoria);
  //           } else {
  //             novoSet.remove(categoria);
  //           }

  //           // APLICA A REGRA DE VALIDAÇÃO
  //           // 1. Não pode ter mais de 2 categorias
  //           // 2. Se tiver 2, uma delas OBRIGATORIAMENTE tem que ser a 'A'
  //           if (novoSet.length > 2 ||
  //               (novoSet.length == 2 && !novoSet.contains('A'))) {
  //             // Se a regra for violada, mostra um erro e não atualiza o estado
  //             showCustomSnackbar(
  //               context,
  //               message: 'Apenas "A" pode ser combinada com outra categoria.',
  //               backgroundColor: Estilos.danger,
  //             );
  //             return; // Impede a atualização do estado
  //           }

  //           // Se a validação passar, atualiza o estado
  //           setState(() {
  //             _categoriasCnhSelecionadas.clear();
  //             _categoriasCnhSelecionadas.addAll(novoSet);
  //           });
  //         },
  //       ),
  //     ],
  //   );
  // }

  @override
  void dispose() {
    _identificacaoFuncionalController.dispose();
    _nomeCompletoController.dispose();
    _nomeGuerraController.dispose();
    _emailController.dispose();
    _telefoneCelularController.dispose();
    _disponibilidadeController.dispose();
    super.dispose();
  }

  Future<void> _selecionarDataDisponibilidade() async {
    // Esconde o teclado caso esteja aberto
    FocusScope.of(context).requestFocus(FocusNode());

    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Impede a seleção de datas passadas
      lastDate: DateTime(
        DateTime.now().year + 2,
      ), // Permite selecionar até 2 anos no futuro
      locale: const Locale(
        'pt',
        'BR',
      ), // Garante que o calendário esteja em português
    );

    if (dataSelecionada != null) {
      // Formata a data para o padrão DD/MM/AAAA e atualiza o controller
      final String dataFormatada = DateFormat(
        'dd/MM/yyyy',
      ).format(dataSelecionada);
      _disponibilidadeController.text = dataFormatada;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Estilos.appbar(context, 'Cadastro'),
      drawer: const NavigationDrawerWidget(),
      backgroundColor: Estilos.branco,
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Estilos.azulClaro),
              )
              : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Estilos.branco,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dados Operacionais',
                              style: Utils.safeGoogleFont(
                                'Roboto',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Estilos.preto,
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _identificacaoFuncionalController,
                              keyboardType: TextInputType.number,
                              readOnly: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Color(0xFFf0f0f0), // Cor de fundo para indicar desabilitado
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Estilos.cinzaClaro,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                labelText: 'Identificação Funcional',
                              ),
                              style: Utils.safeGoogleFont(
                                'Roboto',
                                fontWeight: FontWeight.w400,
                                color: Estilos.preto,
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _nomeCompletoController,
                              decoration: const InputDecoration(
                                labelText: 'Nome Completo',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Estilos.cinzaClaro,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                              ),
                              style: Utils.safeGoogleFont(
                                'Roboto',
                                fontWeight: FontWeight.w400,
                                color: Estilos.preto,
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _nomeGuerraController,
                              decoration: const InputDecoration(
                                labelText: 'Nome de Guerra',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Estilos.cinzaClaro,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                              ),
                              style: Utils.safeGoogleFont(
                                'Roboto',
                                fontWeight: FontWeight.w400,
                                color: Estilos.preto,
                              ),
                            ),
                            const SizedBox(height: 16),

                            DropdownButtonFormField<Classe>(
                              value: _classeSelecionada,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Graduação',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                              ),
                              items:
                                  _opcoesClasses.map((Classe classe) {
                                    return DropdownMenuItem<Classe>(
                                      value: classe,
                                      child: Text(classe.dscClasse),
                                    );
                                  }).toList(),
                              onChanged: (Classe? newValue) {
                                setState(() {
                                  _classeSelecionada = newValue;
                                });
                              },
                              validator:
                                  (value) =>
                                      value == null
                                          ? 'Selecione a graduação'
                                          : null,
                            ),

                            const SizedBox(height: 16),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Categoria CNH:',
                                  style: Utils.safeGoogleFont('Roboto', color: Colors.black54),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200], // Fundo para indicar que é desabilitado
                                    border: Border.all(color: Estilos.cinzaClaro),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: categoriasValidas.map((categoria) {
                                      final bool isSelected = _categoriasCnhSelecionadas.contains(categoria);
                                      return Chip(
                                        label: Text(
                                          categoria,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? Colors.white : Colors.grey[600],
                                          ),
                                        ),
                                        backgroundColor: isSelected ? Estilos.azulClaro : Colors.grey[300],
                                        side: BorderSide.none,
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            
                            // --- NOVO CAMPO: VENCIMENTO DA CNH ---
                            TextFormField(
                              controller: _dataVencimentoCnhController,
                              readOnly: true, // Apenas leitura
                              decoration: const InputDecoration(
                                labelText: 'Vencimento da CNH',
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                filled: true,
                                fillColor: Color(0xFFf0f0f0), // Cor de fundo para indicar desabilitado
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // --- NOVO CAMPO: DATA DE AFASTAMENTO ---
                            TextFormField(
                              controller: _dataAfastamentoController,
                              readOnly: true, // Apenas leitura
                              decoration: const InputDecoration(
                                labelText: 'Data de Afastamento',
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                filled: true,
                                fillColor: Color(0xFFf0f0f0), // Cor de fundo para indicar desabilitado
                              ),
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'E-mail',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Estilos.cinzaClaro,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                              ),
                              style: Utils.safeGoogleFont(
                                'Roboto',
                                fontWeight: FontWeight.w400,
                                color: Estilos.preto,
                              ),
                            ),
                            const SizedBox(height: 16),

                            DropdownButtonFormField<Turno>(
                              value: _turnoSelecionado,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Turno atual de trabalho',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                              ),
                              items:
                                  _opcoesTurnos.map((Turno turno) {
                                    return DropdownMenuItem<Turno>(
                                      value: turno,
                                      child: Text(turno.dscTurno),
                                    );
                                  }).toList(),
                              onChanged: (Turno? newValue) {
                                setState(() {
                                  _turnoSelecionado = newValue;
                                });
                              },
                              validator:
                                  (value) =>
                                      value == null
                                          ? 'Selecione um turno'
                                          : null,
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _telefoneCelularController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                TelefoneInputFormatter(),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Telefone Celular',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Estilos.cinzaClaro,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                              ),
                              style: Utils.safeGoogleFont(
                                'Roboto',
                                fontWeight: FontWeight.w400,
                                color: Estilos.preto,
                              ),
                            ),

                            const Divider(height: 40, thickness: 1),

                            Text(
                              'Disponibilidade',
                              style: Utils.safeGoogleFont(
                                'Roboto',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Estilos.preto,
                              ),
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _disponibilidadeController,
                                    readOnly: true, // Impede o teclado de abrir
                                    onTap:
                                        _selecionarDataDisponibilidade, // Chama o calendário ao tocar
                                    decoration: const InputDecoration(
                                      labelText: 'Data de disponibilidade',
                                      hintText: 'Selecione uma data',
                                      suffixIcon: Icon(
                                        Icons.calendar_today,
                                      ), // Ícone para indicar ação
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Estilos.cinzaClaro,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                    ),
                                    style: Utils.safeGoogleFont(
                                      'Roboto',
                                      fontWeight: FontWeight.w400,
                                      color: Estilos.preto,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    final novaData =
                                        _disponibilidadeController.text.trim();

                                    // 1. Basic format and length validation
                                    if (novaData.isEmpty ||
                                        novaData.length != 10) {
                                      showCustomSnackbar(
                                        context,
                                        message:
                                            'Formato de data inválido. Use DD/MM/AAAA.',
                                        backgroundColor: Estilos.danger,
                                        textColor: Estilos.textDanger,
                                      );
                                      return;
                                    }

                                    DateTime parsedDate;
                                    try {
                                      // 2. Validate if the date is real (e.g., not 99/99/9999 or 30/02/2025)
                                      final parts = novaData.split(
                                        '/',
                                      ); // [dd, MM, yyyy]
                                      if (parts.length != 3) {
                                        throw const FormatException(
                                          'Invalid format',
                                        );
                                      }

                                      final day = int.parse(parts[0]);
                                      final month = int.parse(parts[1]);
                                      final year = int.parse(parts[2]);

                                      parsedDate = DateTime(year, month, day);

                                      // DateTime can be lenient (e.g., 30/02 becomes 02/03). This check ensures it's exact.
                                      if (parsedDate.day != day ||
                                          parsedDate.month != month ||
                                          parsedDate.year != year) {
                                        throw const FormatException(
                                          'Date does not exist.',
                                        );
                                      }
                                    } catch (e) {
                                      showCustomSnackbar(
                                        context,
                                        message:
                                            'Data inválida. Verifique o dia, mês e ano.',
                                        backgroundColor: Estilos.danger,
                                        textColor: Estilos.textDanger,
                                      );
                                      return;
                                    }

                                    final now = DateTime.now();
                                    final today = DateTime(
                                      now.year,
                                      now.month,
                                      now.day,
                                    );

                                    if (parsedDate.isBefore(today)) {
                                      showCustomSnackbar(
                                        context,
                                        message:
                                            'Não é possível inserir uma data anterior a hoje.',
                                        backgroundColor: Estilos.danger,
                                        textColor: Estilos.textDanger,
                                      );
                                      return;
                                    }

                                    final existe = _cadastroData!
                                        .disponibilidades
                                        .any((d) => d.data == novaData);

                                    if (existe) {
                                      showCustomSnackbar(
                                        context,
                                        message: 'Data já inserida.',
                                        backgroundColor: Estilos.danger,
                                        textColor: Estilos.textDanger,
                                      );
                                      return;
                                    }

                                    setState(() {
                                      _cadastroData!.disponibilidades.add(
                                        Disponibilidade(data: novaData),
                                      );
                                      _cadastroData!.disponibilidades.sort((
                                        a,
                                        b,
                                      ) {
                                        final DateTime dataA = stringParaData(
                                          a.data,
                                        );
                                        final DateTime dataB = stringParaData(
                                          b.data,
                                        );
                                        return dataA.compareTo(dataB);
                                      });
                                      _disponibilidadeController.clear();
                                    });
                                  },
                                  child: const Icon(Icons.add),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: 24,
                                  horizontalMargin: 16,
                                  columns: const [
                                    DataColumn(
                                      label: SizedBox(
                                        width: 60,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Ações',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 150,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Data Disponibilidade',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: SizedBox(
                                        width: 120,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Evento',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows:
                                      _cadastroData!.disponibilidades.map((
                                        dispo,
                                      ) {
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Align(
                                                alignment: Alignment.center,
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Estilos.vermelho,
                                                  ),
                                                  onPressed: () {
                                                    if (dispo.evento != null &&
                                                        dispo
                                                            .evento!
                                                            .isNotEmpty) {
                                                      showCustomSnackbar(
                                                        context,
                                                        message:
                                                            'Não é possível remover data com evento associado.',
                                                        backgroundColor:
                                                            Estilos.warning,
                                                        textColor:
                                                            Estilos.textWarning,
                                                      );
                                                    } else {
                                                      setState(() {
                                                        _cadastroData!
                                                            .disponibilidades
                                                            .remove(dispo);
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(dispo.data),
                                              ),
                                            ),
                                            DataCell(
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(dispo.evento ?? ''),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            Center(
                              child: Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Estilos.cinzaClaro),

                                  color:
                                      _isSaving
                                          ? Colors.grey[600]
                                          : Estilos.preto,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Estilos.preto,
                                  ),
                                  onPressed: _isSaving ? null : _performSave,
                                  child:
                                      _isSaving
                                          ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                          : const Text(
                                            'Salvar',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

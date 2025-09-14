import 'dart:typed_data';

import 'package:app_gcm_sa/components/card_nav_drawer_widget.dart';
import 'package:app_gcm_sa/components/snackbar_widget.dart';
import 'package:app_gcm_sa/services/cadastro_service.dart';
import 'package:app_gcm_sa/services/requerimento_service.dart';
import 'package:app_gcm_sa/services/session_manager.dart';
import 'package:app_gcm_sa/utils/estilos.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CadastroRequerimentoView extends StatefulWidget {
  const CadastroRequerimentoView({super.key});

  @override
  State<CadastroRequerimentoView> createState() =>
      _CadastroRequerimentoViewState();
}

class _CadastroRequerimentoViewState extends State<CadastroRequerimentoView> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoadingPage = true;
  bool _isSending = false;

  // Armazena os bytes da imagem da assinatura
  Uint8List? _assinaturaBytes;
  bool get _assinaturaRealizada => _assinaturaBytes != null;

  // Serviços
  final SessionManager _sessionManager = SessionManager();
  final CadastroService _cadastroService = CadastroService();
  final RequerimentoService _requerimentoService = RequerimentoService();

  // Dados do funcionário que não aparecem no formulário
  Map<String, dynamic> _dadosFuncionario = {};

  // Controllers para os campos de texto
  final _postoDeServicoController = TextEditingController();
  final _inspetoriaController = TextEditingController();
  final _destinatarioController = TextEditingController();
  final _relatorioController = TextEditingController();

  // Opções e valor selecionado para o dropdown de Assunto
  final List<String> _opcoesAssunto = [
    'Férias',
    'Licença',
    'Abono',
    'Mudança de escala',
    'Outro',
  ];
  String? _assuntoSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  @override
  void dispose() {
    _postoDeServicoController.dispose();
    _inspetoriaController.dispose();
    _destinatarioController.dispose();
    _relatorioController.dispose();
    super.dispose();
  }

  /// Busca os dados do funcionário necessários para montar o payload do requerimento.
  Future<void> _carregarDadosIniciais() async {
    try {
      final token = await _sessionManager.getToken();
      final codFuncionario = await _sessionManager.getCodFuncionario();

      if (token == null || codFuncionario == null) {
        throw Exception("Sessão inválida. Faça o login novamente.");
      }

      final apiData = await _cadastroService.getCadastro(codFuncionario, token);

      _dadosFuncionario = {
        "cod_funcionario": int.tryParse(codFuncionario) ?? 0,
        "dsc_nome": apiData['nome_completo'],
        "dsc_graduacao": apiData['graduacao'],
        "num_if": int.tryParse(apiData['identificacao_funcional']) ?? 0,
        "cod_turno": apiData['cod_turno'] ?? 0,
      };
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(
          context,
          message: 'Erro ao carregar dados: ${e.toString()}',
          backgroundColor: Estilos.danger,
        );
        context.pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingPage = false);
      }
    }
  }

  Future<void> _enviarRequerimento() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_assinaturaRealizada) {
      showCustomSnackbar(
        context,
        message: 'É necessário registrar a assinatura para enviar.',
        backgroundColor: Estilos.danger,
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final token = await _sessionManager.getToken();
      if (token == null) throw Exception("Sessão expirada.");

      final Map<String, String> fields = {
        "cod_funcionario": _dadosFuncionario['cod_funcionario'].toString(),
        "dsc_nome": _dadosFuncionario['dsc_nome'] ?? '',
        "dsc_graduacao": _dadosFuncionario['dsc_graduacao'] ?? '',
        "num_if": _dadosFuncionario['num_if'].toString(),
        "cod_turno": _dadosFuncionario['cod_turno'].toString(),
        "dsc_posto_servico": _postoDeServicoController.text,
        "dsc_inspetoria": _inspetoriaController.text,
        "dsc_destinatario": _destinatarioController.text,
        "dsc_assunto": _assuntoSelecionado!,
        "dsc_relatorio": _relatorioController.text,
      };

      await _requerimentoService.inserirRequerimento(
        fields: fields,
        assinaturaBytes: _assinaturaBytes!,
        token: token,
      );

      if (mounted) {
        showCustomSnackbar(
          context,
          message: 'Requerimento enviado com sucesso!',
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(
          context,
          message: 'Erro ao enviar: ${e.toString()}',
          backgroundColor: Estilos.danger,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Estilos.appbar(context, 'Inserir Requerimento'),
      drawer: const NavigationDrawerWidget(),
      backgroundColor: Estilos.branco,
      body:
          _isLoadingPage
              ? const Center(
                child: CircularProgressIndicator(color: Estilos.azulClaro),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- FORMULÁRIO ATUALIZADO ---
                      TextFormField(
                        controller: _postoDeServicoController,
                        decoration: const InputDecoration(
                          labelText: 'Posto de Serviço',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        validator:
                            (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Digite o posto de serviço'
                                    : null,
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _inspetoriaController,
                        decoration: const InputDecoration(
                          labelText: 'Inspetoria',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        validator:
                            (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Digite a inspetoria'
                                    : null,
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _destinatarioController,
                        decoration: const InputDecoration(
                          labelText: 'Destinatário',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        validator:
                            (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Digite o destinatário'
                                    : null,
                      ),
                      const SizedBox(height: 24),

                      DropdownButtonFormField<String>(
                        value: _assuntoSelecionado,
                        decoration: const InputDecoration(
                          labelText: 'Assunto',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        items:
                            _opcoesAssunto
                                .map(
                                  (String assunto) => DropdownMenuItem<String>(
                                    value: assunto,
                                    child: Text(assunto),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (String? newValue) =>
                                setState(() => _assuntoSelecionado = newValue),
                        validator:
                            (value) =>
                                value == null ? 'Selecione o assunto' : null,
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _relatorioController,
                        decoration: const InputDecoration(
                          labelText: 'Relatório/Descrição',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        maxLines: 8,
                        validator:
                            (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Digite o conteúdo do relatório'
                                    : null,
                      ),
                      const SizedBox(height: 32),

                      OutlinedButton.icon(
                        icon: Icon(
                          _assinaturaRealizada
                              ? Icons.check_circle
                              : Icons.edit,
                          color:
                              _assinaturaRealizada
                                  ? Colors.green
                                  : Estilos.azulClaro,
                        ),
                        label: Text(
                          _assinaturaRealizada
                              ? 'Assinatura Registrada'
                              : 'Assinar Documento',
                          style: TextStyle(
                            color:
                                _assinaturaRealizada
                                    ? Colors.green
                                    : Estilos.azulClaro,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color:
                                _assinaturaRealizada
                                    ? Colors.green
                                    : Estilos.azulClaro,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          final resultado = await context.push<Uint8List>(
                            '/requerimentos/assinatura',
                          );
                          if (resultado != null) {
                            setState(() {
                              _assinaturaBytes = resultado;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isSending ? Colors.grey[600] : Estilos.preto,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          onPressed: _isSending ? null : _enviarRequerimento,
                          child:
                              _isSending
                                  ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                  : const Text(
                                    'Enviar Requerimento',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

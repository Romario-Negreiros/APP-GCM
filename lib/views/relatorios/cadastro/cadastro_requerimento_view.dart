import 'package:app_gcm_sa/components/card_nav_drawer_widget.dart';
import 'package:app_gcm_sa/components/snackbar_widget.dart';
import 'package:app_gcm_sa/services/cadastro_service.dart';
import 'package:app_gcm_sa/services/requerimento_service.dart';
import 'package:app_gcm_sa/services/session_manager.dart';
import 'package:app_gcm_sa/utils/estilos.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InserirRequerimentoView extends StatefulWidget {
  const InserirRequerimentoView({super.key});

  @override
  State<InserirRequerimentoView> createState() => _InserirRequerimentoViewState();
}

class _InserirRequerimentoViewState extends State<InserirRequerimentoView> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoadingPage = true; // Controla o loading inicial da página
  bool _isSending = false;
  bool _assinaturaRealizada = false;

  // Serviços
  final SessionManager _sessionManager = SessionManager();
  final CadastroService _cadastroService = CadastroService();
  final RequerimentoService _requerimentoService = RequerimentoService();

  // Dados do funcionário que não aparecem no formulário mas são necessários para o envio
  Map<String, dynamic> _dadosFuncionario = {};

  // Mock de dados para os dropdowns (pode ser substituído por uma chamada de API no futuro)
  final List<String> _postosDeServico = ['Paço Municipal', 'UPAs', 'Parques', 'Bases Comunitárias'];
  String? _postoSelecionado;

  // Controllers do formulário
  final _destinatarioController = TextEditingController();
  final _assuntoController = TextEditingController();
  final _relatorioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  @override
  void dispose() {
    _destinatarioController.dispose();
    _assuntoController.dispose();
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
      
      // Armazena os dados relevantes para o payload
      _dadosFuncionario = {
        "cod_funcionario": int.tryParse(codFuncionario) ?? 0,
        "dsc_nome": apiData['nome_completo'],
        "dsc_graduacao": apiData['graduacao'],
        "num_if": int.tryParse(apiData['identificacao_funcional']) ?? 0,
        "cod_turno": apiData['cod_turno'] ?? 0,
        "dsc_inspetoria": "Não informado", // Este campo não vem da API de cadastro
      };

    } catch (e) {
      if (mounted) {
        showCustomSnackbar(context, message: 'Erro ao carregar dados: ${e.toString()}', backgroundColor: Estilos.danger);
        context.pop();
      }
    } finally {
      if(mounted) {
        setState(() => _isLoadingPage = false);
      }
    }
  }

  Future<void> _enviarRequerimento() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_assinaturaRealizada) {
      showCustomSnackbar(context, message: 'É necessário registrar a assinatura para enviar.', backgroundColor: Estilos.danger);
      return;
    }

    setState(() => _isSending = true);
    
    try {
      final token = await _sessionManager.getToken();
      if(token == null) throw Exception("Sessão expirada.");

      // Monta o payload final combinando os dados pré-carregados com os do formulário
      final Map<String, dynamic> payload = {
        ..._dadosFuncionario,
        "dsc_posto_servico": _postoSelecionado!,
        "dsc_destinatario": _destinatarioController.text,
        "dsc_assunto": _assuntoController.text,
        "dsc_relatorio": _relatorioController.text,
      };

      await _requerimentoService.enviarRequerimento(payload, token);
      
      if (mounted) {
        showCustomSnackbar(context, message: 'Requerimento enviado com sucesso!');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(context, message: 'Erro ao enviar: ${e.toString()}', backgroundColor: Estilos.danger);
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
      body: _isLoadingPage
          ? const Center(child: CircularProgressIndicator(color: Estilos.azulClaro))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dropdown para Posto de Serviço
                    DropdownButtonFormField<String>(
                      value: _postoSelecionado,
                      decoration: const InputDecoration(labelText: 'Posto de Serviço', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                      items: _postosDeServico.map((String posto) => DropdownMenuItem<String>(value: posto, child: Text(posto))).toList(),
                      onChanged: (String? newValue) => setState(() => _postoSelecionado = newValue),
                      validator: (value) => value == null ? 'Selecione o posto de serviço' : null,
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _destinatarioController,
                      decoration: const InputDecoration(labelText: 'Destinatário', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                      validator: (value) => (value == null || value.isEmpty) ? 'Digite o destinatário' : null,
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _assuntoController,
                      decoration: const InputDecoration(labelText: 'Assunto', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                      validator: (value) => (value == null || value.isEmpty) ? 'Digite o assunto' : null,
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _relatorioController,
                      decoration: const InputDecoration(labelText: 'Relatório/Descrição', alignLabelWithHint: true, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                      maxLines: 8,
                      validator: (value) => (value == null || value.isEmpty) ? 'Digite o conteúdo do relatório' : null,
                    ),
                    const SizedBox(height: 32),

                    // Botão de Assinatura
                    OutlinedButton.icon(
                      icon: Icon(
                        _assinaturaRealizada ? Icons.check_circle : Icons.edit,
                        color: _assinaturaRealizada ? Colors.green : Estilos.azulClaro,
                      ),
                      label: Text(
                        _assinaturaRealizada ? 'Assinatura Registrada' : 'Assinar Documento',
                        style: TextStyle(color: _assinaturaRealizada ? Colors.green : Estilos.azulClaro, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _assinaturaRealizada ? Colors.green : Estilos.azulClaro, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        final resultado = await context.push<bool>('/requerimento/assinatura');
                        if (resultado == true) {
                          setState(() {
                            _assinaturaRealizada = true;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Botão Enviar
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSending ? Colors.grey[600] : Estilos.preto,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                        ),
                        onPressed: _isSending ? null : _enviarRequerimento,
                        child: _isSending
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Text('Enviar Requerimento', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}


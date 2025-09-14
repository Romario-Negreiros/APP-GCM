import 'package:app_gcm_sa/components/card_nav_drawer_widget.dart';
import 'package:app_gcm_sa/components/snackbar_widget.dart';
import 'package:app_gcm_sa/models/requerimento_model.dart';
import 'package:app_gcm_sa/services/requerimento_service.dart';
import 'package:app_gcm_sa/services/session_manager.dart';
import 'package:app_gcm_sa/utils/estilos.dart';
import 'package:flutter/material.dart';

class ListarRequerimentosView extends StatefulWidget {
  const ListarRequerimentosView({super.key});

  @override
  State<ListarRequerimentosView> createState() =>
      _ListarRequerimentosViewState();
}

class _ListarRequerimentosViewState extends State<ListarRequerimentosView> {
  bool _isLoading = true;
  List<Requerimento> _requerimentos = [];

  final RequerimentoService _requerimentoService = RequerimentoService();
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    _carregarRequerimentos();
  }

  /// Busca os requerimentos do funcionário logado na API.
  Future<void> _carregarRequerimentos() async {
    try {
      final token = await _sessionManager.getToken();
      final codFuncionario = await _sessionManager.getCodFuncionario();

      if (token == null || codFuncionario == null) {
        throw Exception("Sessão inválida. Faça o login novamente.");
      }

      final requerimentosDaApi = await _requerimentoService.listarRequerimentos(
        codFuncionario,
        token,
      );

      if (mounted) {
        setState(() {
          _requerimentos = requerimentosDaApi;
        });
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(
          context,
          message: 'Erro ao carregar requerimentos: ${e.toString()}',
          backgroundColor: Estilos.danger,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- NOVA FUNÇÃO PARA EXIBIR O MODAL DE DETALHES ---
  void _exibirDetalhesRequerimento(Requerimento req) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            req.dscAssunto ?? 'Detalhes do Requerimento',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildDetailRow(
                  Icons.calendar_today,
                  'Data de Envio',
                  req.dtaSolicitacao ?? 'N/A',
                ),
                _buildDetailRow(
                  Icons.person_pin_outlined,
                  'Destinatário',
                  req.dscDestinatario ?? 'N/A',
                ),
                _buildDetailRow(
                  Icons.business,
                  'Inspetoria',
                  req.dscInspetoria ?? 'N/A',
                ),
                _buildDetailRow(
                  Icons.location_on_outlined,
                  'Posto de Serviço',
                  req.dscPostoServico ?? 'N/A',
                ),
                const Divider(height: 24),
                Text(
                  req.dscRelatorio ?? 'Sem descrição.',
                  textAlign: TextAlign.justify,
                  style: const TextStyle(height: 1.5),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Fechar',
                style: TextStyle(
                  color: Estilos.azulClaro,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  /// Widget auxiliar para criar as linhas de detalhe do modal.
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Estilos.azulClaro, size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Estilos.appbar(context, 'Meus Requerimentos'),
      drawer: const NavigationDrawerWidget(),
      backgroundColor: Estilos.branco,
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Estilos.azulClaro),
              )
              : _requerimentos.isEmpty
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Nenhum requerimento encontrado.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _requerimentos.length,
                itemBuilder: (context, index) {
                  final requerimento = _requerimentos[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 8,
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.file_copy_outlined,
                        color: Estilos.azulClaro,
                      ),
                      title: Text(
                        requerimento.dscAssunto ?? 'Assunto não informado',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Para: ${requerimento.dscDestinatario ?? 'N/A'}\nData: ${requerimento.dtaSolicitacao}',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      // --- ONTAP ADICIONADO AQUI ---
                      onTap: () => _exibirDetalhesRequerimento(requerimento),
                    ),
                  );
                },
              ),
    );
  }
}

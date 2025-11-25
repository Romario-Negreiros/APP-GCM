import 'package:app_gcm_sa/components/card_nav_drawer_widget.dart';
import 'package:app_gcm_sa/utils/estilos.dart';
import 'package:app_gcm_sa/utils/utils.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- MODELO DE DADOS PARA A PARTE ENVOLVIDA ---
class ParteEnvolvida {
  // Tipos de envolvimento (Checkboxes na imagem)
  bool isAutor = false;
  bool isCondutor = false;
  bool isSolicitante = false;
  bool isTestemunha = false;
  bool isVitima = false;
  bool isRepresentante = false;
  bool isParteNaoDefinida = false;

  // Dados Pessoais
  final nomeController = TextEditingController();
  final sexoController = TextEditingController();
  final documentoTipoController = TextEditingController();
  final documentoNumeroController = TextEditingController();
  final ufDocumentoController = TextEditingController();
  final dataNascimentoController = TextEditingController();
  final escolaridadeController = TextEditingController();
  final estadoCivilController = TextEditingController();
  final naturalidadeController = TextEditingController();
  final ufNaturalidadeController = TextEditingController();
  final nacionalidadeController = TextEditingController();
  final profissaoController = TextEditingController();
  final nomePaiController = TextEditingController();
  final nomeMaeController = TextEditingController();

  // Endereço e Contato
  final enderecoController = TextEditingController();
  final numeroController = TextEditingController();
  final complementoController = TextEditingController();
  final telefoneController = TextEditingController();
  final bairroController = TextEditingController();
  final referenciaController = TextEditingController();
  final cidadeController = TextEditingController();
  final ufEnderecoController = TextEditingController();

  // Veículo
  final marcaController = TextEditingController();
  final modeloController = TextEditingController();
  final corController = TextEditingController();
  final anoFabricacaoController = TextEditingController();
  final placaController = TextEditingController();
  final municipioVeiculoController = TextEditingController();
  final ufVeiculoController = TextEditingController();
  final chassiController = TextEditingController();

  // Versão e Assinatura
  final versaoParteController = TextEditingController();
  // Assinatura seria um campo especial (imagem/bytes), por enquanto deixamos placeholder

  void dispose() {
    nomeController.dispose();
    sexoController.dispose();
    documentoTipoController.dispose();
    documentoNumeroController.dispose();
    ufDocumentoController.dispose();
    dataNascimentoController.dispose();
    escolaridadeController.dispose();
    estadoCivilController.dispose();
    naturalidadeController.dispose();
    ufNaturalidadeController.dispose();
    nacionalidadeController.dispose();
    profissaoController.dispose();
    nomePaiController.dispose();
    nomeMaeController.dispose();
    enderecoController.dispose();
    numeroController.dispose();
    complementoController.dispose();
    telefoneController.dispose();
    bairroController.dispose();
    referenciaController.dispose();
    cidadeController.dispose();
    ufEnderecoController.dispose();
    marcaController.dispose();
    modeloController.dispose();
    corController.dispose();
    anoFabricacaoController.dispose();
    placaController.dispose();
    municipioVeiculoController.dispose();
    ufVeiculoController.dispose();
    chassiController.dispose();
    versaoParteController.dispose();
  }
}

class BoGcmEView extends StatefulWidget {
  const BoGcmEView({super.key});

  @override
  State<BoGcmEView> createState() => _BoGcmEViewState();
}

class _BoGcmEViewState extends State<BoGcmEView> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para os dados da ocorrência (Seção 1)
  final _dataFatoController = TextEditingController();
  final _horaFatoController = TextEditingController();
  final _horaInicioController = TextEditingController();
  final _horaTerminoController = TextEditingController();
  final _numBopcController = TextEditingController();
  final _numBopmController = TextEditingController();
  final _codigoOcorrenciaController = TextEditingController();
  final _naturezaOcorrenciaController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _referenciaController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();
  final _nomeProprioPublicoController = TextEditingController();

  String? _proprioMunicipal = 'Nao';

  // --- LISTA DE PARTES ENVOLVIDAS ---
  final List<ParteEnvolvida> _partesEnvolvidas = [];

  @override
  void initState() {
    super.initState();
    // Adiciona uma parte inicial vazia para começar
    _adicionarParte();
  }

  void _adicionarParte() {
    if (_partesEnvolvidas.length < 10) {
      setState(() {
        _partesEnvolvidas.add(ParteEnvolvida());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Limite máximo de 10 partes atingido.')),
      );
    }
  }

  void _removerParte(int index) {
    setState(() {
      _partesEnvolvidas[index].dispose(); // Libera os controllers
      _partesEnvolvidas.removeAt(index);
    });
  }

  @override
  void dispose() {
    // Dispose dos controllers da ocorrência
    _dataFatoController.dispose();
    _horaFatoController.dispose();
    _horaInicioController.dispose();
    _horaTerminoController.dispose();
    _numBopcController.dispose();
    _numBopmController.dispose();
    _codigoOcorrenciaController.dispose();
    _naturezaOcorrenciaController.dispose();
    _enderecoController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _complementoController.dispose();
    _referenciaController.dispose();
    _cidadeController.dispose();
    _ufController.dispose();
    _nomeProprioPublicoController.dispose();

    // Dispose de cada parte envolvida
    for (var parte in _partesEnvolvidas) {
      parte.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Estilos.appbar(context, 'BoGcm-E'),
      drawer: const NavigationDrawerWidget(),
      backgroundColor: Estilos.branco,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título da Seção (baseado na imagem)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.grey[200],
                child: Center(
                  child: Text(
                    'DADOS DA OCORRÊNCIA',
                    style: Utils.safeGoogleFont(
                      'Roboto',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Estilos.preto,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Linha 1: Data e Hora do Fato
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dataFatoController,
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        DataInputFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Data do Fato',
                        hintText: 'dd/mm/aaaa',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _horaFatoController,
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        HoraInputFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Hora do Fato',
                        hintText: 'hh:mm',
                        border: OutlineInputBorder(),
                         contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Linha 2: Hora Início e Término
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _horaInicioController,
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        HoraInputFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Hora Início',
                         border: OutlineInputBorder(),
                         contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _horaTerminoController,
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        HoraInputFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Hora Término',
                         border: OutlineInputBorder(),
                         contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Linha 3: Próprio Municipal (Radio Buttons para fidelidade visual)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Próprio Municipal?',
                    style: Utils.safeGoogleFont('Roboto', fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Sim'),
                          value: 'Sim',
                          groupValue: _proprioMunicipal,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (value) => setState(() => _proprioMunicipal = value),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Não'),
                          value: 'Nao',
                          groupValue: _proprioMunicipal,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (value) => setState(() => _proprioMunicipal = value),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Linha 4: Nº BOPC e Nº BOPM
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _numBopcController,
                      decoration: const InputDecoration(
                        labelText: 'Nº BOPC',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _numBopmController,
                      decoration: const InputDecoration(
                        labelText: 'Nº BOPM',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Linha 5: Código e Natureza
              Row(
                children: [
                  SizedBox(
                    width: 100, // Código geralmente é curto
                    child: TextFormField(
                      controller: _codigoOcorrenciaController,
                      decoration: const InputDecoration(
                        labelText: 'Cód. Ocorr.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _naturezaOcorrenciaController,
                      decoration: const InputDecoration(
                        labelText: 'Natureza da Ocorrência',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Linha 6: Endereço, Número e Bairro
              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      controller: _numeroController,
                      decoration: const InputDecoration(
                        labelText: 'Número',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _bairroController,
                      decoration: const InputDecoration(
                        labelText: 'Bairro',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Linha 7: Complemento e Referência
              TextFormField(
                controller: _complementoController,
                decoration: const InputDecoration(
                  labelText: 'Complemento',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _referenciaController,
                decoration: const InputDecoration(
                  labelText: 'Referência',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Linha 8: Cidade, UF e Nome do Próprio
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _cidadeController,
                      decoration: const InputDecoration(
                        labelText: 'Cidade',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 70,
                    child: TextFormField(
                      controller: _ufController,
                      maxLength: 2,
                      decoration: const InputDecoration(
                        labelText: 'UF',
                        border: OutlineInputBorder(),
                        counterText: "", // Esconde o contador 0/2
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Nome do Próprio Público (Habilitar apenas se "Sim" for selecionado seria uma boa lógica futura)
              TextFormField(
                controller: _nomeProprioPublicoController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Próprio Público',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 32),
              
              // --- SEÇÃO 2: QUALIFICAÇÃO DA PARTE (MÚLTIPLA) ---
              _buildSectionTitle('QUALIFICAÇÃO DA PARTE'),
              const SizedBox(height: 16),
              
              // Lista de partes envolvidas (Expansível)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Rola com o SingleChildScrollView pai
                itemCount: _partesEnvolvidas.length,
                itemBuilder: (context, index) {
                  return _buildParteForm(_partesEnvolvidas[index], index);
                },
              ),

              const SizedBox(height: 16),
              
              // Botão para Adicionar Nova Parte
              OutlinedButton.icon(
                onPressed: _adicionarParte,
                icon: const Icon(Icons.person_add),
                label: const Text('Adicionar Envolvido'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Estilos.preto),
                ),
              ),

              const SizedBox(height: 32),

              // Botão Salvar/Próximo
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Estilos.preto,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                  ),
                  onPressed: () {
                    // Lógica para salvar
                    if (_formKey.currentState!.validate()) {
                      // Coletar dados...
                    }
                  },
                  child: const Text('Salvar BO', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para títulos de seção
  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey[300],
      child: Center(
        child: Text(
          title,
          style: Utils.safeGoogleFont('Roboto', fontSize: 18, fontWeight: FontWeight.bold, color: Estilos.preto),
        ),
      ),
    );
  }

  // --- FORMULÁRIO DE UMA ÚNICA PARTE ENVOLVIDA ---
  Widget _buildParteForm(ParteEnvolvida parte, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          tooltip: 'Remover Parte',
          onPressed: () => _removerParte(index),
        ),
        title: AnimatedBuilder(
          animation: parte.nomeController,
          builder: (context, _) {
            final nome = parte.nomeController.text;
            return Text(
              'Envolvido #${index + 1} ${nome.isNotEmpty ? "- $nome" : ""}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            );
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Checkboxes de Tipo de Envolvimento
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    _buildCheckbox('Autor', parte.isAutor, (v) => setState(() => parte.isAutor = v!)),
                    _buildCheckbox('Condutor', parte.isCondutor, (v) => setState(() => parte.isCondutor = v!)),
                    _buildCheckbox('Solicitante', parte.isSolicitante, (v) => setState(() => parte.isSolicitante = v!)),
                    _buildCheckbox('Testemunha', parte.isTestemunha, (v) => setState(() => parte.isTestemunha = v!)),
                    _buildCheckbox('Vítima', parte.isVitima, (v) => setState(() => parte.isVitima = v!)),
                    _buildCheckbox('Representante', parte.isRepresentante, (v) => setState(() => parte.isRepresentante = v!)),
                    _buildCheckbox('Parte Não Definida', parte.isParteNaoDefinida, (v) => setState(() => parte.isParteNaoDefinida = v!)),
                  ],
                ),
                const Divider(),
                
                // Dados Pessoais
                TextFormField(controller: parte.nomeController, decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: parte.sexoController, decoration: const InputDecoration(labelText: 'Sexo', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: parte.dataNascimentoController, decoration: const InputDecoration(labelText: 'Data Nasc.', hintText: 'dd/mm/aaaa', border: OutlineInputBorder()), keyboardType: TextInputType.datetime, inputFormatters: [FilteringTextInputFormatter.digitsOnly, DataInputFormatter()])),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: parte.documentoTipoController, decoration: const InputDecoration(labelText: 'Documento', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: TextFormField(controller: parte.documentoNumeroController, decoration: const InputDecoration(labelText: 'Nº Documento', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    SizedBox(width: 60, child: TextFormField(controller: parte.ufDocumentoController, maxLength: 2, decoration: const InputDecoration(labelText: 'UF', border: OutlineInputBorder(), counterText: ""))),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(controller: parte.escolaridadeController, decoration: const InputDecoration(labelText: 'Escolaridade', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: parte.estadoCivilController, decoration: const InputDecoration(labelText: 'Estado Civil', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: parte.profissaoController, decoration: const InputDecoration(labelText: 'Profissão', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: parte.naturalidadeController, decoration: const InputDecoration(labelText: 'Naturalidade', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    SizedBox(width: 60, child: TextFormField(controller: parte.ufNaturalidadeController, maxLength: 2, decoration: const InputDecoration(labelText: 'UF', border: OutlineInputBorder(), counterText: ""))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: parte.nacionalidadeController, decoration: const InputDecoration(labelText: 'Nacionalidade', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(controller: parte.nomePaiController, decoration: const InputDecoration(labelText: 'Nome do Pai', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextFormField(controller: parte.nomeMaeController, decoration: const InputDecoration(labelText: 'Nome da Mãe', border: OutlineInputBorder())),
                
                const SizedBox(height: 24),
                const Text('ENDEREÇO / CONTATO', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                
                TextFormField(controller: parte.enderecoController, decoration: const InputDecoration(labelText: 'Endereço', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(width: 100, child: TextFormField(controller: parte.numeroController, decoration: const InputDecoration(labelText: 'Nº', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: parte.complementoController, decoration: const InputDecoration(labelText: 'Complemento', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(controller: parte.bairroController, decoration: const InputDecoration(labelText: 'Bairro', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextFormField(controller: parte.referenciaController, decoration: const InputDecoration(labelText: 'Referência', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: parte.cidadeController, decoration: const InputDecoration(labelText: 'Cidade', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    SizedBox(width: 60, child: TextFormField(controller: parte.ufEnderecoController, maxLength: 2, decoration: const InputDecoration(labelText: 'UF', border: OutlineInputBorder(), counterText: ""))),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(controller: parte.telefoneController, keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly, TelefoneInputFormatter()], decoration: const InputDecoration(labelText: 'DDD / Telefone', border: OutlineInputBorder())),

                const SizedBox(height: 24),
                _buildSectionTitle('VEÍCULO'), // Subseção Veículo dentro da Parte
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: parte.marcaController, decoration: const InputDecoration(labelText: 'Marca', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: parte.modeloController, decoration: const InputDecoration(labelText: 'Modelo', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: parte.corController, decoration: const InputDecoration(labelText: 'Cor', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: parte.anoFabricacaoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Ano Fab.', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: parte.placaController, decoration: const InputDecoration(labelText: 'Placa', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: parte.chassiController, decoration: const InputDecoration(labelText: 'Chassi', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: parte.municipioVeiculoController, decoration: const InputDecoration(labelText: 'Município Veículo', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    SizedBox(width: 60, child: TextFormField(controller: parte.ufVeiculoController, maxLength: 2, decoration: const InputDecoration(labelText: 'UF', border: OutlineInputBorder(), counterText: ""))),
                  ],
                ),

                const SizedBox(height: 24),
                const Text('VERSÃO DA PARTE', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: parte.versaoParteController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Versão da Parte',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                
                const SizedBox(height: 24),
                // Placeholder para assinatura
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Text('Campo de Assinatura (Toque para assinar)', style: TextStyle(color: Colors.grey))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
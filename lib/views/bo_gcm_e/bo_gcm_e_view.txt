import 'package:app_gcm_sa/components/card_nav_drawer_widget.dart';
import 'package:app_gcm_sa/utils/estilos.dart';
import 'package:app_gcm_sa/utils/utils.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart'; // Import necessário para navegação
import 'package:image_picker/image_picker.dart'; // Adicionado para fotos

// --- MODELO DE DADOS PARA OBJETO APREENDIDO ---
class ObjetoApreendido {
  final descricaoController = TextEditingController();
  final marcaController = TextEditingController();
  final modeloController = TextEditingController();
  final numeracaoController = TextEditingController();
  final qtdController = TextEditingController();
  final destinoController = TextEditingController();
  final recebedorController = TextEditingController();

  void dispose() {
    descricaoController.dispose();
    marcaController.dispose();
    modeloController.dispose();
    numeracaoController.dispose();
    qtdController.dispose();
    destinoController.dispose();
    recebedorController.dispose();
  }
}

// --- MODELO DE DADOS PARA A PARTE ENVOLVIDA ---
class ParteEnvolvida {
  // Tipos de envolvimento
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

  // --- NOVO CAMPO PARA A ASSINATURA ---
  Uint8List? assinaturaBytes;

  // --- NOVO CAMPO PARA FOTOS DO CROQUI (4 FOTOS) ---
  // Inicializa com 4 posições nulas
  List<Uint8List?> fotosCroqui = [null, null, null, null];

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

  final _relatorioOcorrenciaController = TextEditingController();
  final _informacoesComplementaresController = TextEditingController();

  String? _proprioMunicipal = 'Nao';

  // --- LISTA DE PARTES ENVOLVIDAS ---
  final List<ParteEnvolvida> _partesEnvolvidas = [];

  // --- LISTA DE OBJETOS APREENDIDOS ---
  final List<ObjetoApreendido> _objetosApreendidos = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
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
      _partesEnvolvidas[index].dispose();
      _partesEnvolvidas.removeAt(index);
    });
  }

  void _adicionarObjeto() {
    setState(() {
      _objetosApreendidos.add(ObjetoApreendido());
    });
  }

  void _removerObjeto(int index) {
    setState(() {
      _objetosApreendidos[index].dispose();
      _objetosApreendidos.removeAt(index);
    });
  }


  @override
  void dispose() {
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
    _relatorioOcorrenciaController.dispose();
    _informacoesComplementaresController.dispose();

    for (var parte in _partesEnvolvidas) {
      parte.dispose();
    }
    for (var objeto in _objetosApreendidos) {
      objeto.dispose();
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
              // --- SEÇÃO 1: DADOS DA OCORRÊNCIA ---
              _buildSectionTitle('DADOS DA OCORRÊNCIA'),
              const SizedBox(height: 16),
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
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Próprio Municipal?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Sim'),
                      value: 'Sim',
                      groupValue: _proprioMunicipal,
                      contentPadding: EdgeInsets.zero,
                      onChanged:
                          (value) => setState(() => _proprioMunicipal = value),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Não'),
                      value: 'Nao',
                      groupValue: _proprioMunicipal,
                      contentPadding: EdgeInsets.zero,
                      onChanged:
                          (value) => setState(() => _proprioMunicipal = value),
                    ),
                  ),
                ],
              ),
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
              Row(
                children: [
                  SizedBox(
                    width: 100,
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
                        counterText: "",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _partesEnvolvidas.length,
                itemBuilder: (context, index) {
                  final parte = _partesEnvolvidas[index];
                  return _buildParteForm(parte, index, key: ObjectKey(parte));
                },
              ),

              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: _adicionarParte,
                icon: const Icon(Icons.person_add),
                label: const Text('Adicionar Envolvido'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Estilos.preto),
                ),
              ),

              // --- SEÇÃO 3: OBJETOS APREENDIDOS E INF. COMPLEMENTARES ---
              _buildSectionTitle('OBJETOS APREENDIDOS'),
              const SizedBox(height: 16),

              if (_objetosApreendidos.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Nenhum objeto apreendido adicionado."),
                  ),
                ),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _objetosApreendidos.length,
                itemBuilder: (context, index) {
                  final objeto = _objetosApreendidos[index];
                  return _buildObjetoForm(objeto, index, key: ObjectKey(objeto));
                },
              ),

              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: _adicionarObjeto,
                icon: const Icon(Icons.add_box),
                label: const Text('Adicionar Objeto Apreendido'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Estilos.preto),
                ),
              ),

              const SizedBox(height: 24),
              
              const Text('INFORMAÇÕES COMPLEMENTARES', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _informacoesComplementaresController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Informações adicionais...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 32),

              // --- SEÇÃO 4: RELATÓRIO DA OCORRÊNCIA ---
              _buildSectionTitle('RELATÓRIO DA OCORRÊNCIA'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _relatorioOcorrenciaController,
                maxLines: 15, // Espaço grande para o texto
                decoration: const InputDecoration(
                  hintText: 'Descreva detalhadamente a ocorrência...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true, // Alinha o label no topo
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Estilos.preto,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Lógica para salvar
                    }
                  },
                  child: const Text(
                    'Salvar BO',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey[300],
      child: Center(
        child: Text(
          title,
          style: Utils.safeGoogleFont(
            'Roboto',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Estilos.preto,
          ),
        ),
      ),
    );
  }
  // --- FORMULÁRIO DE OBJETO APREENDIDO ---
  Widget _buildObjetoForm(ObjetoApreendido objeto, int index, {Key? key}) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          tooltip: 'Remover Objeto',
          onPressed: () => _removerObjeto(index),
        ),
        title: AnimatedBuilder(
          animation: objeto.descricaoController,
          builder: (context, _) {
            final desc = objeto.descricaoController.text;
            return Text(
              'Objeto #${index + 1} ${desc.isNotEmpty ? "- $desc" : ""}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            );
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(controller: objeto.descricaoController, decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: objeto.marcaController, decoration: const InputDecoration(labelText: 'Marca', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: objeto.modeloController, decoration: const InputDecoration(labelText: 'Modelo', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(flex: 2, child: TextFormField(controller: objeto.numeracaoController, decoration: const InputDecoration(labelText: 'Numeração', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: objeto.qtdController, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'Qtd.', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(controller: objeto.destinoController, decoration: const InputDecoration(labelText: 'Destino', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextFormField(controller: objeto.recebedorController, decoration: const InputDecoration(labelText: 'Recebedor', border: OutlineInputBorder())),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- FORMULÁRIO DE UMA ÚNICA PARTE ENVOLVIDA ---
  Widget _buildParteForm(ParteEnvolvida parte, int index, {Key? key}) {
    return Card(
      key: key,
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
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    _buildCheckbox(
                      'Autor',
                      parte.isAutor,
                      (v) => setState(() => parte.isAutor = v!),
                    ),
                    _buildCheckbox(
                      'Condutor',
                      parte.isCondutor,
                      (v) => setState(() => parte.isCondutor = v!),
                    ),
                    _buildCheckbox(
                      'Solicitante',
                      parte.isSolicitante,
                      (v) => setState(() => parte.isSolicitante = v!),
                    ),
                    _buildCheckbox(
                      'Testemunha',
                      parte.isTestemunha,
                      (v) => setState(() => parte.isTestemunha = v!),
                    ),
                    _buildCheckbox(
                      'Vítima',
                      parte.isVitima,
                      (v) => setState(() => parte.isVitima = v!),
                    ),
                    _buildCheckbox(
                      'Representante',
                      parte.isRepresentante,
                      (v) => setState(() => parte.isRepresentante = v!),
                    ),
                    _buildCheckbox(
                      'Parte Não Definida',
                      parte.isParteNaoDefinida,
                      (v) => setState(() => parte.isParteNaoDefinida = v!),
                    ),
                  ],
                ),
                const Divider(),

                TextFormField(
                  controller: parte.nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: parte.sexoController,
                        decoration: const InputDecoration(
                          labelText: 'Sexo',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: parte.dataNascimentoController,
                        decoration: const InputDecoration(
                          labelText: 'Data Nasc.',
                          hintText: 'dd/mm/aaaa',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.datetime,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          DataInputFormatter(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: parte.documentoTipoController,
                        decoration: const InputDecoration(
                          labelText: 'Documento',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: parte.documentoNumeroController,
                        decoration: const InputDecoration(
                          labelText: 'Nº Documento',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 60,
                      child: TextFormField(
                        controller: parte.ufDocumentoController,
                        maxLength: 2,
                        decoration: const InputDecoration(
                          labelText: 'UF',
                          border: OutlineInputBorder(),
                          counterText: "",
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: parte.escolaridadeController,
                  decoration: const InputDecoration(
                    labelText: 'Escolaridade',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: parte.estadoCivilController,
                        decoration: const InputDecoration(
                          labelText: 'Estado Civil',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: parte.profissaoController,
                        decoration: const InputDecoration(
                          labelText: 'Profissão',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: parte.naturalidadeController,
                        decoration: const InputDecoration(
                          labelText: 'Naturalidade',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 60,
                      child: TextFormField(
                        controller: parte.ufNaturalidadeController,
                        maxLength: 2,
                        decoration: const InputDecoration(
                          labelText: 'UF',
                          border: OutlineInputBorder(),
                          counterText: "",
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: parte.nacionalidadeController,
                        decoration: const InputDecoration(
                          labelText: 'Nacionalidade',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: parte.nomePaiController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Pai',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: parte.nomeMaeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Mãe',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  'ENDEREÇO / CONTATO',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: parte.enderecoController,
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
                        controller: parte.numeroController,
                        decoration: const InputDecoration(
                          labelText: 'Nº',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: parte.complementoController,
                        decoration: const InputDecoration(
                          labelText: 'Complemento',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: parte.bairroController,
                  decoration: const InputDecoration(
                    labelText: 'Bairro',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: parte.referenciaController,
                  decoration: const InputDecoration(
                    labelText: 'Referência',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: parte.cidadeController,
                        decoration: const InputDecoration(
                          labelText: 'Cidade',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 60,
                      child: TextFormField(
                        controller: parte.ufEnderecoController,
                        maxLength: 2,
                        decoration: const InputDecoration(
                          labelText: 'UF',
                          border: OutlineInputBorder(),
                          counterText: "",
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: parte.telefoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    TelefoneInputFormatter(),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'DDD / Telefone',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('VEÍCULO'),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: parte.marcaController,
                        decoration: const InputDecoration(
                          labelText: 'Marca',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: parte.modeloController,
                        decoration: const InputDecoration(
                          labelText: 'Modelo',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: parte.corController,
                        decoration: const InputDecoration(
                          labelText: 'Cor',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: parte.anoFabricacaoController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Ano Fab.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: parte.placaController,
                        decoration: const InputDecoration(
                          labelText: 'Placa',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: parte.chassiController,
                        decoration: const InputDecoration(
                          labelText: 'Chassi',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: parte.municipioVeiculoController,
                        decoration: const InputDecoration(
                          labelText: 'Município Veículo',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 60,
                      child: TextFormField(
                        controller: parte.ufVeiculoController,
                        maxLength: 2,
                        decoration: const InputDecoration(
                          labelText: 'UF',
                          border: OutlineInputBorder(),
                          counterText: "",
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Text(
                  'VERSÃO DA PARTE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
                GestureDetector(
                  onTap: () async {
                    final resultado = await context.push<Uint8List>(
                      '/requerimentos/assinatura',
                    );
                    if (resultado != null) {
                      setState(() {
                        parte.assinaturaBytes = resultado;
                      });
                    }
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child:
                        parte.assinaturaBytes != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                parte.assinaturaBytes!,
                                fit: BoxFit.contain,
                              ),
                            )
                            : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit_square,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Toque aqui para assinar',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 24),
                // --- SEÇÃO DE FOTOS DO CROQUI / AVARIAS (GRID 2x2) ---
                const Text(
                  'CROQUI / AVARIAS',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 colunas
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1, // Quadrado
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return _buildPhotoSlot(parte, index);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET DE SLOT PARA FOTO COM LÓGICA DE SELEÇÃO ---
  Widget _buildPhotoSlot(ParteEnvolvida parte, int photoIndex) {
    final photo = parte.fotosCroqui[photoIndex];

    return GestureDetector(
      onTap: () {
        _selecionarOrigemImagem(parte, photoIndex);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[100],
        ),
        child:
            photo != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(photo, fit: BoxFit.cover),
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt, color: Colors.grey, size: 32),
                    const SizedBox(height: 4),
                    Text(
                      'Foto ${photoIndex + 1}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
      ),
    );
  }

  // --- FUNÇÃO PARA SELECIONAR A ORIGEM DA IMAGEM ---
  void _selecionarOrigemImagem(ParteEnvolvida parte, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar Foto'),
                onTap: () async {
                  Navigator.of(ctx).pop(); // Fecha o menu
                  try {
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 50, // Otimiza o tamanho
                      maxWidth: 1024,
                    );
                    if (image != null) {
                      final bytes = await image.readAsBytes();
                      setState(() {
                        parte.fotosCroqui[index] = bytes;
                      });
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao abrir câmera: $e')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da Galeria'),
                onTap: () async {
                  Navigator.of(ctx).pop(); // Fecha o menu
                  try {
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 50,
                      maxWidth: 1024,
                    );
                    if (image != null) {
                      final bytes = await image.readAsBytes();
                      setState(() {
                        parte.fotosCroqui[index] = bytes;
                      });
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao abrir galeria: $e')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
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

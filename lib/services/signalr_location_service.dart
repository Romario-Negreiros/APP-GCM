import 'package:app_gcm_sa/models/ocorrencia_model.dart';
import 'package:signalr_core/signalr_core.dart';

class SignalRLocationService {
  // ATENÇÃO: Ajuste a URL base para apontar para a raiz onde o /ws/location está hospedado
  // Se a API for a mesma do endpoint HTTP, a base seria algo como:
  final String _hubUrl = 'https://apihomologacao.santoandre.sp.gov.br/alertamulher/ws/location'; 
  
  HubConnection? _hubConnection;
  Function(Ocorrencia)? onLocationReceived;

  bool get isConnected => _hubConnection?.state == HubConnectionState.connected;

  Future<void> startConnection(String token) async {
    if (isConnected) return;

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          '$_hubUrl?type=web', // Conecta como 'web' para RECEBER mensagens
          HttpConnectionOptions(
            accessTokenFactory: () async => token,
          ),
        )
        .withAutomaticReconnect()
        .build();

    _hubConnection?.onclose((error) => print('SignalR (Location): Conexão fechada: $error'));
    _hubConnection?.onreconnecting((error) => print('SignalR (Location): Reconectando...'));
    
    // Registra o listener para o método "ReceiveLocation" que o servidor chama
    _hubConnection?.on('ReceiveLocation', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final data = arguments[0] as Map<String, dynamic>;
          
          // Mapeia o objeto anônimo do C# para o nosso modelo Ocorrencia
          // Note que os nomes das propriedades no C# são minúsculos no JSON (camelCase geralmente)
          // O objeto C# é: { lat, lng, endereco, sentAt, uuid_ocorrencia, seq_vitima, ... }
          
          final novaOcorrencia = Ocorrencia(
            codigo: data['uuid_ocorrencia']?.toString() ?? 'N/A',
            data: data['sentAt']?.toString() ?? DateTime.now().toString(),
            vitima: data['dsc_nome_vitima'] ?? 'Desconhecido',
            codigoVitima: int.tryParse(data['seq_vitima']?.toString() ?? '0') ?? 0,
            autor: data['dsc_nome_autor'] ?? 'Desconhecido',
            codigoAutor: int.tryParse(data['seq_autor']?.toString() ?? '0') ?? 0,
            latitude: (data['lat'] as num).toDouble(),
            longitude: (data['lng'] as num).toDouble(),
            endereco: data['endereco'] ?? '',
            atendido: 'N', // Novo alerta, provavelmente não atendido
            uuidOcorrencia: data['uuid_ocorrencia']?.toString(),
          );

          onLocationReceived?.call(novaOcorrencia);
        } catch (e) {
          print('SignalR: Erro ao processar ReceiveLocation: $e');
        }
      }
    });

    try {
      await _hubConnection?.start();
      print('SignalR (Location): Conectado com sucesso.');
    } catch (e) {
      print('SignalR (Location): Erro ao conectar: $e');
    }
  }

  Future<void> stopConnection() async {
    await _hubConnection?.stop();
  }
}
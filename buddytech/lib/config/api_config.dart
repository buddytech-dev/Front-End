/// Configurações da API BuddyTech
class ApiConfig {
  ApiConfig._();

  /// URL base da API
  /// Altere para o endereço correto do seu ambiente
  ///
  /// Desenvolvimento local Windows: http://localhost:5000/api
  /// Desenvolvimento Web (Chrome): http://localhost:5000/api
  /// Emulador Android: http://10.0.2.2:5000/api
  /// Dispositivo físico Android: http://<IP_DA_MAQUINA>:5000/api
  /// Produção: https://api.buddytech.com/api

  // Para rodar no Chrome/Windows use localhost
  // Para rodar no emulador Android use 10.0.2.2
  // Para rodar em dispositivo físico, use o IP da sua máquina (ex: 192.168.1.100)
  static const String baseUrl = 'http://192.168.1.15:5084/api';

  /// Timeout para requisições (em segundos)
  static const int timeout = 30;

  /// Headers padrão
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}

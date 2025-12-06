import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Configurações da API BuddyTech
class ApiConfig {
  ApiConfig._();

  /// URL base da API, ajustada para diferentes ambientes
  static String get baseUrl {
    if (kIsWeb) {
      // Rodando no navegador (Chrome/Web)
      return 'http://localhost:5084/api';
    } else if (Platform.isAndroid) {
      // Rodando no emulador Android
      return 'http://172.20.10.3:5084/api';
    } else if (Platform.isIOS) {
      // Rodando no emulador ou dispositivo iOS
      return 'http://localhost:5084/api';
    } else {
      // Caso não detectado, usar IP da máquina (dispositivo físico Android)
      return 'http://172.20.10.3:5084/api';
    }
  }

  /// Timeout para requisições (em segundos)
  static const int timeout = 30;

  /// Headers padrão
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}

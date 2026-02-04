import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Configuracoes {
  static recuperarTamanho(context) {
    double baseWidth = 400;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return ffem;
  }

  static String get apiUrl => dotenv.env['API_URL'] ?? '';
  static String get apiAmUrl => dotenv.env['API_AM_URL'] ?? '';
  static String get environment =>
      dotenv.env['ENV'] == 'development' ? "Homologação" : "Produção";
}

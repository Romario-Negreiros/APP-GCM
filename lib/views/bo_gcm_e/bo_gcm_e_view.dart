import 'package:app_gcm_sa/components/card_nav_drawer_widget.dart';
import 'package:app_gcm_sa/utils/estilos.dart';
import 'package:app_gcm_sa/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BoGcmEView extends StatelessWidget {
  const BoGcmEView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Estilos.appbar(context, 'BoGcm-E'),
      drawer: const NavigationDrawerWidget(),
      backgroundColor: Estilos.branco,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Estilos.azulClaro.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  'assets/svgIcons/siren.svg',
                  colorFilter: Estilos.colorFilterIconsInicial,
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'B.O. Eletrônico',
                textAlign: TextAlign.center,
                style: Utils.safeGoogleFont(
                  'Roboto',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Estilos.preto,
                ),
              ),
              const SizedBox(height: 8),

              Chip(
                label: const Text(
                  'Em Desenvolvimento',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Estilos.warning,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              const SizedBox(height: 24),

              Text(
                'Este módulo será voltado para criação de B.Os. eletrônicos.',
                textAlign: TextAlign.center,
                style: Utils.safeGoogleFont(
                  'Roboto',
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              const Divider(),

              const SizedBox(height: 32),

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_top, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    'Funcionalidades disponíveis em breve.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

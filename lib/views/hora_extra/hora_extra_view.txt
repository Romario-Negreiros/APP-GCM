import 'package:app_gcm_sa/components/card_nav_drawer_widget.dart';
import 'package:app_gcm_sa/utils/estilos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class HoraExtraView extends StatelessWidget {
  const HoraExtraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Estilos.appbar(context, 'Hora Extra'),
      drawer: const NavigationDrawerWidget(),
      backgroundColor: Estilos.branco,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2,
            child: ListTile(
              leading: SvgPicture.asset(
                'assets/svgIcons/user-round.svg',
                colorFilter: Estilos.colorFilterIconsInicial,
                width: 25,
                height: 25,
              ),
              title: const Text(
                'Meu Cadastro',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Visualize e altere seus dados cadastrais.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.push('/hora-extra/cadastro');
              },
            ),
          ),
          const SizedBox(height: 16),

          Card(
            elevation: 2,
            child: ListTile(
              leading: SvgPicture.asset(
                'assets/svgIcons/lucide--calendar-days.svg',
                colorFilter: Estilos.colorFilterIconsInicial,
                width: 25,
                height: 25,
              ),
              title: const Text(
                'Eventos e Disponibilidade',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Consulte eventos e gerencie suas datas de voluntariado.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.push('/hora-extra/eventos');
              },
            ),
          ),
        ],
      ),
    );
  }
}

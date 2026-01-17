import 'package:app_gcm_sa/components/card_nav_drawer_widget.dart';
import 'package:app_gcm_sa/utils/estilos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class RequerimentosView extends StatelessWidget {
  const RequerimentosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Estilos.appbar(context, 'Requerimentos'),
      drawer: const NavigationDrawerWidget(),
      backgroundColor: Estilos.branco,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2,
            child: ListTile(
              leading: SvgPicture.asset(
                'assets/svgIcons/plus.svg', // Ícone para "adicionar"
                colorFilter: Estilos.colorFilterIconsInicial,
                width: 25,
                height: 25,
              ),
              title: const Text(
                'Cadastrar Requerimento',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Preencha e envie um novo requerimento interno.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navega para a rota filha de inserção
                context.push('/requerimentos/cadastro');
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: ListTile(
              leading: SvgPicture.asset(
                'assets/svgIcons/list.svg', // Ícone para "listar"
                colorFilter: Estilos.colorFilterIconsInicial,
                width: 25,
                height: 25,
              ),
              title: const Text(
                'Meus Requerimentos Enviados',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Visualize o histórico dos seus requerimentos.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navega para a rota filha de listagem
                context.push('/requerimentos/listar');
              },
            ),
          ),
        ],
      ),
    );
  }
}

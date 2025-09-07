import 'package:app_gcm_sa/components/card_nav_drawer_widget.dart';
import 'package:app_gcm_sa/utils/estilos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class RelatoriosView extends StatelessWidget {
  const RelatoriosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Estilos.appbar(context, 'Relatórios'),
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
                'Inserir Novo Relatório',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Preencha e envie um novo relatório interno.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navega para a rota filha de inserção
                context.push('/relatorios/cadastro');
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
                'Meus Relatórios Enviados',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Visualize o histórico dos seus relatórios.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navega para a rota filha de listagem
                context.push('/relatorios/listar');
              },
            ),
          ),
        ],
      ),
    );
  }
}

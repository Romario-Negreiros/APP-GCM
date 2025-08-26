import 'package:app_gcm_sa/components/btn_padrao_square.dart';
import 'package:app_gcm_sa/components/card_nav_drawer_widget.dart';
import 'package:app_gcm_sa/services/session_manager.dart';
import 'package:app_gcm_sa/utils/configuracoes.dart';
import 'package:app_gcm_sa/utils/estilos.dart';
import 'package:app_gcm_sa/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MenuItem {
  MenuItem({required this.text, required this.link, required this.iconSvg});

  late String text;
  late String link;
  late String iconSvg;
}

List<MenuItem> menus = [
  MenuItem(
    text: "Hora Extra",
    link: "/hora-extra",
    iconSvg: "assets/svgIcons/lucide--calendar-days.svg",
  ),
  MenuItem(text: "CAP", link: "/cap", iconSvg: "assets/svgIcons/award.svg"),
  MenuItem(
    text: "Romaneio",
    link: "/romaneio",
    iconSvg: "assets/svgIcons/shirt.svg",
  ),
  MenuItem(
    text: "Normativa",
    link: "/normativa",
    iconSvg: "assets/svgIcons/gavel.svg",
  ),
  MenuItem(
    text: "Relatórios",
    link: "/relatorios",
    iconSvg: "assets/svgIcons/file-text.svg",
  ),
  MenuItem(
    text: "BoGcm-E",
    link: "/bo-gcm-e",
    iconSvg: "assets/svgIcons/siren.svg",
  ),
  MenuItem(
    text: "Estatística",
    link: "/estatistica",
    iconSvg: "assets/svgIcons/chart-bar.svg",
  ),
];

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final SessionManager _sessionManager = SessionManager();
  String _dscNomeFuncionario = "";

  @override
  void initState() {
    super.initState();
    _fetchDscNomeFuncionario();
  }

  Future<void> _fetchDscNomeFuncionario() async {
    final nome = await _sessionManager.getDscNomeFuncionario();
    setState(() {
      _dscNomeFuncionario = nome?.split(" ")[0] ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    double ffem = Configuracoes.recuperarTamanho(context);

    return Stack(
      children: [
        Scaffold(
          appBar: Estilos.appBarHome(
            context,
            _dscNomeFuncionario,
            scaffoldKey,
            ffem,
            "",
          ),
          key: scaffoldKey,
          drawer: NavigationDrawerWidget(),
          backgroundColor: Estilos.branco,
          body: Container(
            color: Estilos.azulGradient4,
            child: Container(
              decoration: const BoxDecoration(
                color: Estilos.branco,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    color: Colors.transparent,
                    height: 160 * ffem,
                    child: Center(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: menus.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              left:
                                  index == 0
                                      ? 16.0 * ffem
                                      : 0, // Espaçamento à esquerda do primeiro item
                              top: 8.0 * ffem, // Espaçamento superior
                              bottom: 20.0 * ffem, // Espaçamento inferior
                              right:
                                  0.0, // Espaçamento direito entre itens (opcional)
                            ),
                            child: BtnPadraoSquare(
                              onTap: () => context.push(menus[index].link),
                              icon: menus[index].iconSvg,
                              textBtn: menus[index].text,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 145 * ffem,
                        child: Image.asset('assets/imagens/GCM-Logo.png'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            'GCM-SA CONECTA',
                            textAlign: TextAlign.center,
                            style: Utils.safeGoogleFont(
                              'Nunito',
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              height: 0,
                              letterSpacing: 0.88,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

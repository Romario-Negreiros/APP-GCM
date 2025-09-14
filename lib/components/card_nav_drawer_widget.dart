import 'package:app_gcm_sa/services/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/estilos.dart';

class NavigationDrawerWidget extends StatefulWidget {
  const NavigationDrawerWidget({super.key});

  @override
  State<NavigationDrawerWidget> createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  final padding = const EdgeInsets.symmetric(horizontal: 20);
  final SessionManager _sessionManager = SessionManager();

  late List<Map<String, dynamic>> _allMenuItems;

  Widget buildMenuItem({
    required String text,
    IconData? icon,
    String? iconSvg,
    VoidCallback? onClicked,
    int? notificacoes,
    List<Map<String, dynamic>>? children,
    bool isParent = false,
  }) {
    const color = Estilos.cinzaMenu;

    if (children != null) {
      children = children.where((element) => element.isNotEmpty).toList();
    } else {
      children = [];
    }

    return !isParent
        ? GestureDetector(
          onTap: onClicked,
          child: Container(
            margin: const EdgeInsets.only(left: 24, right: 24, bottom: 0),
            padding: const EdgeInsets.only(
              top: 0,
              bottom: 0,
              left: 12,
              right: 20,
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      iconSvg == null
                          ? Icon(icon, color: color, size: 20)
                          : SvgPicture.asset(
                            iconSvg,
                            // ignore: deprecated_member_use
                            color: color,
                            width: 20,
                            height: 20,
                          ),
                      const SizedBox(width: 12),
                      Text(
                        text,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        : Container(
          margin: const EdgeInsets.only(left: 24, right: 24, bottom: 0),
          padding: const EdgeInsets.only(top: 0, bottom: 0, left: 12),
          child: Column(
            children: [
              Theme(
                data: ThemeData(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  childrenPadding: EdgeInsets.zero,
                  tilePadding: EdgeInsets.zero,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            iconSvg!,
                            // ignore: deprecated_member_use
                            color: Estilos.cinzaMenu,
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            text,
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Estilos.cinzaMenu,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
  }

  @override
  void initState() {
    super.initState();

    _allMenuItems = [
      {
        'name': 'Inicio',
        'item': buildMenuItem(
          text: 'Inicio',
          iconSvg: 'assets/svgIcons/home.svg',
          onClicked: () => context.go("/home"),
          isParent: false,
        ),
      },
      {
        'name': 'Hora Extra',
        'item': buildMenuItem(
          text: 'Hora Extra',
          iconSvg: 'assets/svgIcons/lucide--calendar-days.svg',
          onClicked: () {
            Navigator.of(context).pop();
            context.push("/hora-extra");
          },
          isParent: false,
        ),
      },
      {
        'name': 'CAP',
        'item': buildMenuItem(
          text: 'CAP',
          iconSvg: 'assets/svgIcons/award.svg',
          onClicked: () {
            Navigator.of(context).pop();
            context.push("/cap");
          },
          isParent: false,
        ),
      },
      {
        'name': 'Romaneio',
        'item': buildMenuItem(
          text: 'Romaneio',
          iconSvg: 'assets/svgIcons/shirt.svg',
          onClicked: () {
            Navigator.of(context).pop();
            context.push("/romaneio");
          },
          isParent: false,
        ),
      },
      {
        'name': 'Normativa',
        'item': buildMenuItem(
          text: 'Normativa',
          iconSvg: 'assets/svgIcons/gavel.svg',
          onClicked: () {
            Navigator.of(context).pop();
            context.push("/normativa");
          },
          isParent: false,
        ),
      },
      {
        'name': 'Requerimentos',
        'item': buildMenuItem(
          text: 'Requerimentos',
          iconSvg: 'assets/svgIcons/file-text.svg',
          onClicked: () {
            Navigator.of(context).pop();
            context.push("/requerimentos");
          },
          isParent: false,
        ),
      },
      {
        'name': 'BoGcm-E',
        'item': buildMenuItem(
          text: 'BoGcm-E',
          iconSvg: 'assets/svgIcons/siren.svg',
          onClicked: () {
            Navigator.of(context).pop();
            context.push("/bo-gcm-e");
          },
          isParent: false,
        ),
      },
      {
        'name': 'Estatística',
        'item': buildMenuItem(
          text: 'Estatística',
          iconSvg: 'assets/svgIcons/chart-bar.svg',
          onClicked: () {
            Navigator.of(context).pop();
            context.push("/estatistica");
          },
          isParent: false,
        ),
      },

      // Espaço
      {'name': '', 'item': const SizedBox(height: 10)},

      // Divider UX
      {'name': '', 'item': dividerUx()},

      // Sair
      {
        'name': 'name',
        'item': buildMenuItemSair(
          text: 'Sair',
          iconSvg: 'assets/svgIcons/log-out.svg',
          onClicked: () => sairApp(context),
        ),
      },
    ];
  }

  List<Map<String, dynamic>> searchSubMenuItems(String query) {
    List<Map<String, dynamic>> subMenuItems = [];

    for (var item in _allMenuItems) {
      if (item['name'].toLowerCase().contains(query.toLowerCase())) {
        subMenuItems.add(item);
      }

      List<Map<String, dynamic>>? children =
          (item['children'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList();

      if (children != null) {
        for (var child in children) {
          if (child.containsKey('title') &&
              child['title'].toLowerCase().contains(query.toLowerCase())) {
            subMenuItems.add({
              'name': child['title'],
              'item': ListTile(
                title: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        child['icon'],
                        // ignore: deprecated_member_use
                        color: Estilos.cinzaMenu,
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        child['title'],
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Estilos.cinzaMenu,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: child['onClicked'],
              ),
            });
          }
        }
      }
    }

    return subMenuItems;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        return;
      },
      child: SizedBox(
        // Para Funcionar precisa se o container a metade do botão maior do que o Drawer
        // Por Exemplo: Drawer = 270 botão = 30 o container deve ser = 285 ou seja 270 + (30 / 2)
        width: (MediaQuery.of(context).size.width * 0.9) + 15,
        child: Stack(
          children: [
            Drawer(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(
                    15,
                  ), // Borda arredondada no canto superior direito
                  bottomRight: Radius.circular(
                    15,
                  ), // Borda arredondada no canto inferior direito
                ),
              ),
              backgroundColor: Estilos.branco,
              //width: 270,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Container(
                color: Estilos.branco,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _allMenuItems.length,
                        itemBuilder: (context, index) {
                          return _allMenuItems[index]['item'];
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/imagens/marca_psa_horizontal.png',
                      width: 113,
                    ),

                    // Versão do App
                    Container(
                      padding: const EdgeInsets.only(bottom: 24, top: 14),
                      child: Text(
                        'Versão 1.0.0',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Estilos.cinzaClaroAzulado,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Aqui carrega o botão de retornar para funcionar precisa de um container maior que o Drawer
            Positioned(
              top: 60,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Estilos.branco,
                    border: Border.all(
                      color: const Color.fromARGB(255, 246, 246, 246),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: Estilos.azulGradient3,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Menu de opões de Sair
  Widget buildMenuItemSair({
    required String text,
    IconData? icon,
    String? iconSvg,
    VoidCallback? onClicked,
  }) {
    const color = Estilos.vermelhoMenu;

    return GestureDetector(
      onTap: onClicked,
      child: Container(
        color: Estilos.branco,
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 8),
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 30,
          left: 12,
          right: 12,
        ),
        child: Row(
          children: [
            iconSvg == null
                ? Icon(icon, color: color, size: 20)
                : SvgPicture.asset(iconSvg, width: 20, height: 20),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // Divisor UX
  Widget dividerUx() {
    return const Divider(
      color: Estilos.cinzaDivider,
      indent: 24,
      endIndent: 24,
      thickness: 2,
      height: 24,
    );
  }

  // Sair do App
  void sairApp(BuildContext context) async {
    try {
      context.go("/");
      await _sessionManager.logout();
    } catch (e) {
      debugPrint("Erro ao sair do app: $e");
    }
  }
}

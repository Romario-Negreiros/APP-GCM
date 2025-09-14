import 'package:app_gcm_sa/utils/estilos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BtnPadraoSquare extends StatelessWidget {
  final bool visible;
  final Function() onTap;
  final String icon;
  final Color iconColor;
  final ColorFilter iconColorFilter;
  final Color bgIconColor;
  final bool isLoading;
  final String textBtn;
  final String secondTextBtn;

  const BtnPadraoSquare({
    super.key,
    this.visible = true,
    required this.onTap,
    required this.icon,
    this.iconColor = Estilos.colorIconsInicial,
    this.iconColorFilter = Estilos.colorFilterIconsInicial,
    this.bgIconColor = Estilos.colorBGIconsInicial,
    this.isLoading = false,
    required this.textBtn,
    this.secondTextBtn = "",
  });

  @override
  Widget build(BuildContext context) {
    double baseWidth = 400;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Visibility(
      visible: visible,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(right: 15 * ffem),
          width: 102,
          height: 122,
          decoration: const BoxDecoration(
            color: Estilos.branco,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 10,
                offset: Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
            //border: Border.all(color: Estilos.cinzaClaro, width: 0.7 * ffem), // Adiciona a borda preta
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: bgIconColor,
                      borderRadius: BorderRadius.circular(
                        100,
                      ), // Define o raio em pixels
                    ),
                    width: 45,
                    height: 45,
                  ),
                  icon == 'badge_outlined'
                      ? Icon(Icons.badge_outlined, color: iconColor)
                      : SvgPicture.asset(
                        icon,
                        colorFilter: iconColorFilter,
                        width: 23 * ffem,
                        height: 23 * ffem,
                      ),
                ],
              ),
              Container(
                height: 35,
                margin: EdgeInsets.only(top: 5 * ffem),
                padding: EdgeInsets.only(left: 5 * ffem, right: 5 * ffem),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      textBtn,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        overflow: TextOverflow.ellipsis,
                        letterSpacing:
                            0.56, // Use Estilos.preto, se estiver definido em outro lugar.
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

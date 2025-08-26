// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:app_gcm_sa/services/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/estilos.dart';
import '../../../utils/utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  double progress = 0.0;
  late Timer timer;
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  final SessionManager _sessionManager = SessionManager();

  Future<void> _checkSessionAndRedirect() async {
    // Um pequeno delay para a splash screen ser visível, melhorando a UX.
    await Future.delayed(const Duration(seconds: 2));

    final bool isSessionValid = await _sessionManager.isSessionValid();

    // A verificação 'mounted' é uma boa prática para evitar erros se o widget
    // for removido da árvore enquanto a verificação assíncrona acontece.
    if (mounted) {
      if (isSessionValid) {
        // Se a sessão for válida, vai para a home
        context.go('/home');
      } else {
        // Se não, vai para a tela de login
        context.go('/');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkSessionAndRedirect();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.8).animate(_controller);
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.4).animate(_controller);

    timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      setState(() {
        progress += 0.01;
        if (progress >= 1.0) {
          timer.cancel();
          context.go('/', extra: 'fromSplash');
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 400;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Estilos.branco,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.only(bottom: 80, top: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/imagens/marca_psa_horizontal.png',
              width: 150,
              height: 75,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 291 * ffem,
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
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(68, 0, 183, 255),
                      ),
                    ),
                  ),
                ),
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    CircularProgressIndicator(
                      color: Estilos.azulClaro,
                      value: progress >= 0 ? progress : 0,
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                    Center(
                      child: Text(
                        ((progress * 100)).toStringAsFixed(0),
                        textAlign: TextAlign.center,
                        style: Utils.safeGoogleFont(
                          'Roboto',
                          fontSize: 12 * ffem,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.55 * ffem,
                          color: Estilos.azulClaro,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

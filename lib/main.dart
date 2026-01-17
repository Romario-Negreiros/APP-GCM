import 'package:app_gcm_sa/views/requerimento/listar/listar_requerimentos_view.dart';
import 'package:app_gcm_sa/views/splash_screen/splash_screen_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:app_gcm_sa/views/login/login_view.dart';
import 'package:app_gcm_sa/views/home/home_view.dart';
import 'package:app_gcm_sa/views/hora_extra/cadastro/cadastro_view.dart';
import 'package:app_gcm_sa/views/hora_extra/eventos/eventos_view.dart';
import 'package:app_gcm_sa/views/cap/cap_view.dart';
import 'package:app_gcm_sa/views/romaneio/romaneio_view.dart';
import 'package:app_gcm_sa/views/normativa/normativa_view.dart';
import 'package:app_gcm_sa/views/requerimento/requerimentos_view.dart';
import 'package:app_gcm_sa/views/requerimento/cadastro/cadastro_requerimento_view.dart';
import 'package:app_gcm_sa/views/requerimento/cadastro/assinatura_requerimento_view.dart';
import 'package:app_gcm_sa/views/bo_gcm_e/bo_gcm_e_view.dart';
import 'package:app_gcm_sa/views/estatisticas/estatisticas_view.dart';
import 'package:app_gcm_sa/views/hora_extra/hora_extra_view.dart';
// import 'package:app_gcm_sa/views/sos/sos_hub_view.dart';
// import 'package:app_gcm_sa/views/sos/listar_ocorrencias_view.dart';
// import 'package:app_gcm_sa/views/sos/mapa_ocorrencias_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  await dotenv.load(fileName: '.env.$environment');

  runApp(MyApp());
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Define the routes where pressing back should exit the app.
    const rootRoutes = ['/home', '/login'];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        final router = GoRouter.of(context);
        final currentLocation =
            router.routerDelegate.currentConfiguration.uri.toString();

        // If we can pop within the router's stack, do it.
        // This handles navigation between pages like /home -> /eventos -> back to /home.
        if (router.canPop()) {
          router.pop();
        } else if (rootRoutes.contains(currentLocation)) {
          // If we are on a root route and cannot pop, the OS will handle the exit.
          // This part is for added safety, but the logic above usually covers it.
          SystemNavigator.pop();
        } else {
          // If we are not on a root route, navigate back to the home page.
          router.go('/home');
        }
      },
      child: child,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(path: '/', name: 'login', builder: (context, state) => LoginView()),

    ShellRoute(
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => HomeView(),
        ),
        // GoRoute(
        //   path: '/sos',
        //   name: 'sos',
        //   builder: (context, state) => const SosHubView(),
        //   routes: [
        //     GoRoute(
        //       path: 'listar',
        //       name: 'sos-listar',
        //       builder: (context, state) => const ListarOcorrenciasView(),
        //     ),
        //     GoRoute(
        //       path: 'mapa',
        //       name: 'sos-mapa',
        //       builder: (context, state) => const MapaOcorrenciasView(),
        //     ),
        //   ],
        // ),
        GoRoute(
          path: '/hora-extra',
          name: 'hora-extra',
          builder: (context, state) => const HoraExtraView(),
          routes: [
            GoRoute(
              path: 'cadastro',
              name: 'he-cadastro',
              builder: (context, state) => CadastroView(),
            ),
            GoRoute(
              path: 'eventos',
              name: 'he-eventos',
              builder: (context, state) => EventosView(),
            ),
          ],
        ),
        GoRoute(
          path: '/cap',
          name: 'cap',
          builder: (context, state) => const CapView(),
        ),
        GoRoute(
          path: '/romaneio',
          name: 'romaneio',
          builder: (context, state) => const RomaneioView(),
        ),
        GoRoute(
          path: '/normativa',
          name: 'normativa',
          builder: (context, state) => const NormativaView(),
        ),
        GoRoute(
          path: '/requerimentos',
          name: 'requerimentos',
          builder: (context, state) => const RequerimentosView(),
          routes: [
            GoRoute(
              path: 'cadastro',
              name: 'rel-cadastro',
              builder: (context, state) => CadastroRequerimentoView(),
            ),
            GoRoute(
              path: 'listar',
              name: 'rel-listar',
              builder: (context, state) => ListarRequerimentosView(),
            ),
            GoRoute(
              path: 'assinatura',
              name: 'rel-assinatura',
              builder: (context, state) => AssinaturaView(),
            ),
          ],
        ),
        GoRoute(
          path: '/bo-gcm-e',
          name: 'bo-gcm-e',
          builder: (context, state) => const BoGcmEView(),
        ),
        GoRoute(
          path: '/estatistica',
          name: 'estatistica',
          builder: (context, state) => const EstatisticasView(),
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'GCM App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
    );
  }
}

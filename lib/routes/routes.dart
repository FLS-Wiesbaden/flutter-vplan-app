import 'package:auto_route/auto_route.dart';
import 'package:de_fls_wiesbaden_vplan/guards/auth.guards.dart';
import 'package:de_fls_wiesbaden_vplan/guards/firstrun.guards.dart';
import 'package:de_fls_wiesbaden_vplan/routes/routes.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Route')
class AppRouter extends $AppRouter {
  @override
  RouteType get defaultRouteType =>
      const RouteType.material(); //.cupertino, .adaptive ..etc

  @override
  List<AutoRoute> get routes => [
        AutoRoute(
            page: FlsVplanMainUiRoute.page, path: '/', guards: [AuthGuard()]),
        AutoRoute(
            page: WizardRoute.page,
            path: '/wizard',
            guards: [AuthGuard(), FirstRunGuard()]
            //transitionsBuilder: TransitionsBuilders.zoomIn,
            ),
        AutoRoute(page: AboutUiRoute.page, path: '/about'),
        AutoRoute(
          page: AuthUiRoute.page,
          path: '/login',
          //keepHistory: false,
          //transitionsBuilder: TransitionsBuilders.slideLeftWithFade,
        ),
        AutoRoute(
          page: AuthScanUiRoute.page, 
          path: '/login/scan',
          //keepHistory: false
          //transitionsBuilder: TransitionsBuilders.slideLeftWithFade,
        )
      ];
}

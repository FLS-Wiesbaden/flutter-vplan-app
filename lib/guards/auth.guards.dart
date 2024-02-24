import 'package:auto_route/auto_route.dart';
import 'package:de_fls_wiesbaden_vplan/controllers/authcontroller.dart';
import 'package:de_fls_wiesbaden_vplan/routes/routes.gr.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    AuthController authController = AuthController.getInstance();
    if (await authController.isLoggedIn()) {
      resolver.next(true);
    } else {
      router.push(AuthUiRoute());
      /*  onResult: (didLogin) {
          resolver.next(didLogin);
        },
      ));*/
    }
  }
  
}
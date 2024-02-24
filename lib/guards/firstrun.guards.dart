import 'package:auto_route/auto_route.dart';
import 'package:de_fls_wiesbaden_vplan/routes/routes.gr.dart';
import 'package:de_fls_wiesbaden_vplan/storage/config.dart';

class FirstRunGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final Config config = Config.getInstance();
    if (await config.isFirstCall()) {
      resolver.next(true);
    } else {
      router.push(const FlsVplanMainUiRoute());
    }
  }
}
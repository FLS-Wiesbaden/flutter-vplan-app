import 'package:de_fls_wiesbaden_vplan/ui/helper/consts.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:de_fls_wiesbaden_vplan/models/plan.dart';
import 'package:de_fls_wiesbaden_vplan/storage/planstorage.dart';
import 'package:de_fls_wiesbaden_vplan/ui/authui.dart';
import 'package:de_fls_wiesbaden_vplan/ui/helper/exceptions.dart';
import 'package:de_fls_wiesbaden_vplan/ui/helper/physics.dart';
import 'package:de_fls_wiesbaden_vplan/ui/styles/plancolors.dart';
import 'package:de_fls_wiesbaden_vplan/ui/vplan/plandayui.dart';
import 'package:de_fls_wiesbaden_vplan/ui/vplan/planemptyui.dart';
import 'package:de_fls_wiesbaden_vplan/ui/vplan/planerrorui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

/// Widget to show the plan itself in a specific hierarchy:
///   PlanUi
///     PlanDayUi
///       PlanEntryUi
///       PlanEventUi
///       PlanEmptyUi
///     PlanEmptyUi
///     PlanErrorUi
/// If no days are given in any ways, we in a slightly bad situation
/// requiring to show the PlanEmptyUi instead of list of days.
class PlanUi extends StatefulWidget {
  const PlanUi({super.key, required this.personalPlan});

  final bool personalPlan;

  @override
  State<PlanUi> createState() => _PlanUiState();
}

class _PlanUiState extends State<PlanUi> with TickerProviderStateMixin, WidgetsBindingObserver {

  int selectedPage = 0;
  late PlanStorage planStorage;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final log = Logger(vplanLoggerId);
    log.finer("AppLifeCycle status changed: ${state.name}");
    if (state == AppLifecycleState.resumed) {
       setState(() {
        log.finer("AppLifeCycle status changed to resume. So refresh.");
        // refresh
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final log = Logger(vplanLoggerId);
    final ValueNotifier<int> selectedPage = ValueNotifier<int>(0);
    final PageController pageController =
        PageController(viewportFraction: 0.9, initialPage: selectedPage.value);
    planStorage = Provider.of<PlanStorage>(context);
    
    Future<Plan> load({bool refresh = false}) {
      return planStorage.load(refresh: refresh, personalPlan: widget.personalPlan).onError((error, stackTrace) {
          if (error is ApiAuthException) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AuthUi(errorMessage: AppLocalizations.of(context)!.authenticationError)),
            );
          }
          return Future.error(error!, stackTrace);
        });
    }
    Future<void> refresh() {
      return load(refresh: true);
    }

    return Scaffold(
      backgroundColor: PlanColors.AppBackgroundColor,
      body: FutureBuilder<Plan>(
        future: load(),
        builder: (context, AsyncSnapshot<Plan> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.active) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data!.length() > 0 && !snapshot.data!.isEmpty) {
            log.finer("Page is freshly built.");
            return RefreshIndicator(
              onRefresh: refresh,
              notificationPredicate: (ScrollNotification notification) {
                return notification.depth < 2 && notification.depth >= 0;
              },
              child: Stack(fit: StackFit.expand, children: [
              ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                primary: false,
              ),
              PageView.builder(
                physics: const CustomPageViewScrollPhysics(),
                controller: pageController,
                onPageChanged: (int page) {
                  selectedPage.value = page;
                },
                itemCount: snapshot.data?.length(),
                itemBuilder: (context, posIndex) {
                  return Container(
                    margin: const EdgeInsets.only(top: 15.0),
                    child: PlanDayUi(
                      day: snapshot.data!.getDay(posIndex)
                    ));
                }),
              Positioned(
                  left: 0.0,
                  right: 0.0,
                  bottom: 0.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        child: Container(
                          color: Colors.white,
                          child: ValueListenableBuilder<int>(
                            valueListenable: selectedPage,
                            builder: (context, value, _) {
                              return DotsIndicator(
                                dotsCount: snapshot.data!.length(),
                                position: value,
                                decorator: DotsDecorator(
                                  color: PlanColors
                                      .PageIndicatorColor, // Inactive color
                                  activeColor: PlanColors
                                      .PageIndicatorSelectedColor,
                                ),
                              );
                            }
                          )
                        ),
                      )
                    ],
                  )),
            ]));
          } else if (snapshot.hasError) {
            return RefreshIndicator(
              onRefresh: refresh,
              child: Stack(
                children: [
                  PlanErrorUi(errorMessage: snapshot.error!.toString()),
                  ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                  )
                ]
              )
            );
          } else {
            return RefreshIndicator(
              onRefresh: refresh,
              child: Stack(
                children: [
                  const PlanEmptyUi(),
                  ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                  )
                ]
              )
            );
          }
        }
      )
    );
  }
}

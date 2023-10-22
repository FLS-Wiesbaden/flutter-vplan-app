import 'package:de_fls_wiesbaden_vplan/storage/config.dart';
import 'package:de_fls_wiesbaden_vplan/ui/settings/plansettingsui.dart';
import 'package:de_fls_wiesbaden_vplan/ui/styles/plancolors.dart';
import 'package:de_fls_wiesbaden_vplan/ui/vplan/planui.dart';
import 'package:de_fls_wiesbaden_vplan/ui/wizard.dart';
import 'package:de_fls_wiesbaden_vplan/utils/notifications.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class FlsVplanMainUi extends StatefulWidget {
  const FlsVplanMainUi({super.key, required this.title});
  
  final String title;

  @override
  State<FlsVplanMainUi> createState() => _FlsVplanMainUiState();
}

class _FlsVplanMainUiState extends State<FlsVplanMainUi> with TickerProviderStateMixin {
  int selectedPage = 0;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 1, length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final Config config = Config.getInstance();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    return FutureBuilder(
      future: config.isFirstCall().then((value) async {
        if (value) {
          await Navigator.push(context,MaterialPageRoute(builder: (context)=>const Wizard()));
        }
      }), 
      builder: (context, snapshot) {
        BackgroundPush.setupPush();
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return Scaffold(
              backgroundColor: PlanColors.AppBackgroundColor,
              body: SafeArea(
                bottom: false,
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    PlanUi(personalPlan: false),
                    PlanUi(personalPlan: true),
                    PlanSettingsUi()
                  ]
                )
              ),
              bottomNavigationBar: SafeArea(
                top: false,
                left: false,
                right: false,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: PlanColors.TabBorderColor, width: 0.5
                      )
                    )
                  ),
                  child: TabBar(
                    labelColor: PlanColors.SelectedIconColor,
                    unselectedLabelColor: PlanColors.IconColor,
                    indicatorColor: Colors.transparent,
                    indicatorWeight: 0.1,
                    controller: _tabController,
                    isScrollable: false,
                    tabs: <Widget>[
                      Tab(
                        icon: const Icon(Icons.list),
                        text: AppLocalizations.of(context)!.schoolPlan,
                      ),
                      Tab(
                        icon: const Icon(Icons.favorite),
                        text: AppLocalizations.of(context)!.myPlan,
                      ),
                      Tab(
                        icon: const Icon(Icons.settings),
                        text: AppLocalizations.of(context)!.settings,
                      ),
                    ],
                  )
                ),
            )
          );
        }
      }
    );
  }
}
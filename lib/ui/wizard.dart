import 'package:de_fls_wiesbaden_vplan/controllers/authcontroller.dart';
import 'package:de_fls_wiesbaden_vplan/storage/config.dart';
import 'package:de_fls_wiesbaden_vplan/storage/planstorage.dart';
import 'package:de_fls_wiesbaden_vplan/ui/settings/plansettingsui.dart';
import 'package:de_fls_wiesbaden_vplan/ui/styles/plancolors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wizard extends StatefulWidget {
  const Wizard({super.key});
  
  @override
  State<Wizard> createState() => _Wizard();
  
}

class _Wizard extends State<Wizard> {
  @override
  Widget build(BuildContext context) {
    PlanStorage ps = context.select((PlanStorage ps) => ps);
    
    return FutureBuilder(future: ps.load(), builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      } else {
        return Scaffold(
          backgroundColor: PlanColors.AppBackgroundColor,
          body: const SafeArea(
            bottom: false,
            child: PlanSettingsUi(isWizard: true)
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            left: false,
            right: false,
            child: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: const Icon(Icons.cancel_outlined),
                  label: AppLocalizations.of(context)!.cancel,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.navigate_next),
                  label: AppLocalizations.of(context)!.go
                )
              ],
              currentIndex: 1,
              onTap: (value) async {
                if (value == 0) {
                  await AuthController.getInstance().logout();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                } else {
                  await Config.getInstance().setFirstCallDone(true);
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                }
              },
            )
          )
        );
      }
    });
  }

}
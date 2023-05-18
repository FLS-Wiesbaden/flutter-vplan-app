import 'package:de_fls_wiesbaden_vplan/ui/styles/plancolors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

/// If there are no plan entry available (e.g. because there is
/// no regular plan available or uploaded and there are no standins),
/// a screen is shown to indicate: Hey. everything is up-to-date and 
/// there are no published information.
/// If an event is available for the day, the PlanEventUi widget 
/// is shown.
class PlanEmptyUi extends StatelessWidget {
  const PlanEmptyUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/empty-visual.svg',
          ),
          Padding(padding: const EdgeInsets.fromLTRB(0, 15, 0, 0), child: Text(
            AppLocalizations.of(context)!.everythingOnSchedule, 
            style: TextStyle(
              color: PlanColors.PrimaryTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 22
            )
          )),
          Padding(padding: const EdgeInsets.fromLTRB(0, 15, 0, 0), 
            child: Text(AppLocalizations.of(context)!.youGetNotified,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PlanColors.SecondaryTextColor,
                fontWeight: FontWeight.normal
              )
            )
          ),
        ]
    ));
  }
}
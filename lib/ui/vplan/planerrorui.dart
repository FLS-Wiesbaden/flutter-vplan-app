import 'package:de_fls_wiesbaden_vplan/ui/styles/plancolors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

/// Widget to show errors in case of loading
/// a plan.
class PlanErrorUi extends StatelessWidget {
  const PlanErrorUi({super.key, required this.errorMessage});

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/empty-visual.svg',
              //colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(0, 15, 0, 0), child: Text(AppLocalizations.of(context)!.errorOnLoading, style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 22
            ))),
            Padding(padding: const EdgeInsets.fromLTRB(0, 15, 0, 0), 
              child: Text(AppLocalizations.of(context)!.errorMessage(errorMessage), 
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PlanColors.SecondaryTextColor,
                  fontWeight: FontWeight.normal
                )
              )
            ),
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

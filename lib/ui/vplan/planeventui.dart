import 'package:de_fls_wiesbaden_vplan/models/event.dart';
import 'package:de_fls_wiesbaden_vplan/ui/styles/plancolors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// In opposite to the PlanEmptyUi, this 
/// widget shows a beach to relax and to enjoy
/// some holidays.
class PlanEventUi extends StatelessWidget {
  final Event event;
  
  const PlanEventUi({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Center(
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/beach.png'
          ),
          Padding(padding: const EdgeInsets.fromLTRB(0, 15, 0, 0), child: Text(event.caption, style: TextStyle(
            color: PlanColors.PrimaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 22
          ))),
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
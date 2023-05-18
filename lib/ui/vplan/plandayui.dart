import 'package:de_fls_wiesbaden_vplan/models/day.dart';
import 'package:de_fls_wiesbaden_vplan/storage/planstorage.dart';
import 'package:de_fls_wiesbaden_vplan/ui/helper/behaviors.dart';
import 'package:de_fls_wiesbaden_vplan/ui/styles/plancolors.dart';
import 'package:de_fls_wiesbaden_vplan/ui/vplan/planemptyui.dart';
import 'package:de_fls_wiesbaden_vplan/ui/vplan/planentryui.dart';
import 'package:de_fls_wiesbaden_vplan/ui/vplan/planeventui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Reflects a plan day. This widget decides for
/// a day, whether an PlanEventUi must be shown,
/// an PlanEmptyUi must be shown or whether a list of
/// PlanEntryUi must be shown.
class PlanDayUi extends StatelessWidget {
  const PlanDayUi({super.key, required this.day});

  final Day day;

  @override
  Widget build(BuildContext context) {
    final fetchDate = context.select((PlanStorage ps) => ps.getFetchedDate());

    return Column(
      children: [
        Text(day.getWeekdayName(),
            style: TextStyle(
                color: PlanColors.PrimaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        Text(day.getDateString(),
            style: TextStyle(
                color: PlanColors.SecondaryTextColor,
                fontWeight: FontWeight.normal,
                fontSize: 14)),
        Flexible(
          fit: FlexFit.tight,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
            margin: const EdgeInsets.fromLTRB(5, 15, 5, 15),
            decoration: day.isEmpty ? null : BoxDecoration(
                color: PlanColors.PlanDayBackgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                border: Border(
                    bottom: BorderSide(
                        color: PlanColors.TabBorderColor, width: 0.5),
                    left: BorderSide(
                        color: PlanColors.TabBorderColor, width: 0.5),
                    right: BorderSide(
                        color: PlanColors.TabBorderColor, width: 0.5),
                    top: BorderSide(
                        color: PlanColors.TabBorderColor, width: 0.5))),
            child: day.isEmpty || day.isEvent? Stack(
                children: [
                  day.isEvent ? PlanEventUi(event: day.event!) : const PlanEmptyUi(),
                  ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                  )
                ]
              ) : ScrollConfiguration(
              behavior: NoGlowBehavior(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: day.length()+1,
                itemBuilder: (BuildContext chdContext, int index) {
                  if (index == 0) {
                    return Center(
                      child: Text(
                        AppLocalizations.of(context)!.lastUpdate(fetchDate), 
                        style: TextStyle(color: PlanColors.SecondaryTextColor, fontSize: 11),
                      )
                    );
                  } else {
                    return SizedBox(
                      width: 350,
                      child: PlanEntryUi(entry: day.entries[index-1])
                    );
                  }
                }
              )
            )
          )
        ),
      ],
    );
  }
}

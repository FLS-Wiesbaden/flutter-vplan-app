import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:de_fls_wiesbaden_vplan/models/entry.dart';
import 'package:de_fls_wiesbaden_vplan/storage/config.dart';
import 'package:de_fls_wiesbaden_vplan/storage/planstorage.dart';
import 'package:de_fls_wiesbaden_vplan/ui/styles/plancolors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

/// Class to show the entry itself to the user
/// Furthermore providing the sharing functionality.
/// UI is prepared based on the plan mode: Teacher or Pupil.
class PlanEntryUi extends StatefulWidget {
  const PlanEntryUi({super.key, required this.entry});
  final Entry entry;

  @override
  State<PlanEntryUi> createState() => _PlanEntryUi();
}

class _PlanEntryUi extends State<PlanEntryUi> {
  GlobalKey globalKey = GlobalKey();

  void _showShareActions(BuildContext context, String shareText, String eventTitle, Uint8List pngBytes) {
    final box = context.findRenderObject() as RenderBox?;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Share.shareXFiles(
                [XFile.fromData(pngBytes, mimeType: "image/png")], 
                subject: AppLocalizations.of(context)!.standInPlan, 
                text: shareText, 
                sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size
              );
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.shareAsPicture),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Share.share(
                shareText, 
                subject: AppLocalizations.of(context)!.standInPlan, 
                sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size
              );
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.shareAsText),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Event calEvent = Event(
                allDay: false,
                title: eventTitle,
                location: widget.entry.room ?? "",
                startDate: widget.entry.startDateTime,
                endDate: widget.entry.endDateTime,
                description: shareText
              );
              Add2Calendar.addEvent2Cal(calEvent);
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.createCalendarEntry),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final schoolClassStorage = context.select((PlanStorage ps) => ps.schoolClassStorage);
    final mode = context.select((Config ps) => ps.mode);
    final schoolClass = schoolClassStorage.getClass(entry.className);
    final schoolType = schoolClassStorage.getType(schoolClass != null ? schoolClass.schoolType : 0);
    String eventTitle = "";
    String plainText = "";
    List<String> plainTextList = [];

    List<TextSpan> originalElements = [];
    List<Widget> standin = [];
    List<Widget> additions = [];

    TextSpan space = const TextSpan(text: " ");
    TextStyle primTextStyle = TextStyle(
        color: PlanColors.PrimaryTextColor, fontWeight: FontWeight.normal);
    TextStyle scndTextStyle = TextStyle(
        color: PlanColors.SecondaryTextColor, fontWeight: FontWeight.normal);

    Text classElement = Text(entry.className, style: TextStyle(color: PlanColors.PrimaryTextColor, fontWeight: FontWeight.bold));
    plainText = entry.className;
    
    if (mode == PlanType.teacher) {
      if (entry.chgTeacher != null) {
        classElement = Text(entry.chgTeacher!.displayName, style: TextStyle(color: PlanColors.PrimaryTextColor, fontWeight: FontWeight.bold));
        plainText = entry.chgTeacher!.displayName;
      } else if (entry.teacher != null) {
        classElement = Text(entry.teacher!.displayName, style: TextStyle(color: PlanColors.PrimaryTextColor, fontWeight: FontWeight.bold));
        plainText = entry.teacher!.displayName;
      }

      if (entry.isYardDuty()) {
        originalElements.add(TextSpan(text: AppLocalizations.of(context)!.supervision, style: scndTextStyle));
        if (entry.teacher != null) {
          originalElements.add(space);
          originalElements.add(TextSpan(text: AppLocalizations.of(context)!.forSomeone, style: scndTextStyle));
          originalElements.add(space);
          originalElements.add(TextSpan(text: entry.teacher!.displayName, style: primTextStyle));
        }
        originalElements.add(space);
        originalElements.add(TextSpan(text: AppLocalizations.of(context)!.from, style: scndTextStyle));
        originalElements.add(space);
        originalElements.add(TextSpan(text: entry.getStartTime(), style: primTextStyle));
        originalElements.add(space);
        originalElements.add(TextSpan(text: AppLocalizations.of(context)!.hourTo, style: scndTextStyle));
        originalElements.add(space);
        originalElements.add(TextSpan(text: entry.getEndTime(), style: primTextStyle));
        originalElements.add(space);
        originalElements.add(TextSpan(text: AppLocalizations.of(context)!.hour, style: scndTextStyle));
      }
    }

    if (!entry.isYardDuty()) {
      originalElements.add(TextSpan(text: entry.subject.name, style: primTextStyle));
      if (entry.teacher != null) {
        originalElements.add(space);
        originalElements.add(TextSpan(text: AppLocalizations.of(context)!.by, style: scndTextStyle));
        originalElements.add(space);
        originalElements.add(TextSpan(text: entry.teacher!.displayName, style: primTextStyle));
      }
      if (mode == PlanType.teacher) {
        originalElements.add(space);
        originalElements.add(TextSpan(text: AppLocalizations.of(context)!.inClass, style: scndTextStyle));
        originalElements.add(space);
        originalElements.add(TextSpan(text: entry.className, style: primTextStyle));
      }
      if (entry.room != null) {
        originalElements.add(space);
        originalElements.add(TextSpan(text: AppLocalizations.of(context)!.inRoom, style: scndTextStyle));
        originalElements.add(space);
        originalElements.add(TextSpan(text: entry.room, style: primTextStyle));
      }
    }
    RichText original = RichText(text: TextSpan(children: originalElements));
    
    eventTitle = AppLocalizations.of(context)!.changeType(entry.isFree() ? AppLocalizations.of(context)!.cancelled : entry.isRegular() ? AppLocalizations.of(context)!.regular : AppLocalizations.of(context)!.standin);
    plainTextList.add(eventTitle);
    if (!entry.isRegular()) {
      standin.add(Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 5),
        child: Text(entry.isFree() ? AppLocalizations.of(context)!.cancelled : entry.isRegular() ? "" : AppLocalizations.of(context)!.standin,
          style: TextStyle(
              color: PlanColors.PrimaryTextColor,
              fontWeight: FontWeight.bold
          )
        )
      ));
    }

    if (!entry.isFree()) {
      if (entry.chgTeacher != null) {
        plainTextList.add(AppLocalizations.of(context)!.substituteTeacher(entry.chgTeacher!.displayName));
        standin.add(ListTile(
            leading: const Icon(Icons.person),
            title: Wrap(children: [Text(entry.chgTeacher!.displayName, style: TextStyle(color: PlanColors.SecondaryTextColor),)]),
            contentPadding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
            horizontalTitleGap: 5.0,
            minLeadingWidth: 0,
            minVerticalPadding: 0,
            visualDensity: const VisualDensity(vertical: -4),
            dense: true,
            style: ListTileStyle.drawer,
          )
        );
      }
      if (entry.chgRoom != null) {
        plainTextList.add(AppLocalizations.of(context)!.changedRoom(entry.chgRoom!));
        standin.add(ListTile(
            leading: const Icon(Icons.room),
            title: Wrap(children: [Text(entry.chgRoom!, style: TextStyle(color: PlanColors.SecondaryTextColor),)]),
            contentPadding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
            horizontalTitleGap: 5.0,
            minLeadingWidth: 0,
            minVerticalPadding: 0,
            visualDensity: const VisualDensity(vertical: -4),
            dense: true,
            style: ListTileStyle.drawer,
          )
        );
      }
      if (entry.chgSubject != null) {
        plainTextList.add(AppLocalizations.of(context)!.changedSubject(entry.chgSubject!.name));
        standin.add(ListTile(
            leading: const Icon(Icons.book),
            title: Wrap(children: [Text(entry.chgSubject!.name, style: TextStyle(color: PlanColors.SecondaryTextColor),)]),
            contentPadding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
            horizontalTitleGap: 5.0,
            minLeadingWidth: 0,
            minVerticalPadding: 0,
            visualDensity: const VisualDensity(vertical: -4),
            dense: true,
            style: ListTileStyle.drawer,
          )
        );
      }
    }

    if (entry.chgNotes != null) {
      plainTextList.add(AppLocalizations.of(context)!.changeNotice(entry.chgNotes!));
      additions.add(ListTile(
          leading: const Icon(Icons.info_outline),
          title: Wrap(children: [Text(entry.chgNotes!, style: TextStyle(color: PlanColors.SecondaryTextColor),)]),
          contentPadding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
          horizontalTitleGap: 5.0,
          minLeadingWidth: 0,
          minVerticalPadding: 0,
          visualDensity: const VisualDensity(vertical: -4),
          dense: true,
          style: ListTileStyle.drawer,
        )
      );
    }

    // Prepare plain text for sharing!
    eventTitle = AppLocalizations.of(context)!.eventTitle(eventTitle, entry.hourText);
    plainText = "$plainText: ${original.text.toPlainText()}";
    for (var sti in plainTextList) {
      plainText = "$plainText; $sti";

    }

    showShareActions() async {
      RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      // ignore: use_build_context_synchronously
      _showShareActions(context, plainText, eventTitle, pngBytes);
    }

    return GestureDetector(
      onLongPress: showShareActions,
      child: RepaintBoundary(
        key: globalKey,
        child: Card(
          elevation: 1.0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: PlanColors.TabBorderColor,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: Container(
            margin: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Container(width: 20, height: 10, decoration: BoxDecoration(
                              gradient: schoolType.getGradient(),
                          ),)),
                          classElement
                        ],
                      ),
                      Text(entry.getShortDateString(),
                          style: TextStyle(color: PlanColors.PrimaryTextColor))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: original
                ),
                ...standin,
                ...additions
              ]
            ),
          )
        )
      )
    );
  }
}
import 'package:de_fls_wiesbaden_vplan/models/lesson.dart';
import 'package:de_fls_wiesbaden_vplan/models/schoolclass.dart';
import 'package:de_fls_wiesbaden_vplan/models/schooltype.dart';
import 'package:de_fls_wiesbaden_vplan/models/teacher.dart';
import 'package:de_fls_wiesbaden_vplan/storage/config.dart';
import 'package:de_fls_wiesbaden_vplan/storage/planstorage.dart';
import 'package:de_fls_wiesbaden_vplan/storage/schoolclassstorage.dart';
import 'package:de_fls_wiesbaden_vplan/storage/teacherstorage.dart';
import 'package:de_fls_wiesbaden_vplan/ui/aboutui.dart';
import 'package:de_fls_wiesbaden_vplan/ui/settings/mainsettings.dart';
import 'package:de_fls_wiesbaden_vplan/ui/styles/plancolors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Complex plan filter settings. 
/// E.g. Which teachers? which school type? ...
class PlanSettingsUi extends StatefulWidget {
  final bool isWizard;
  const PlanSettingsUi({super.key, this.isWizard = false});

  @override
  State<StatefulWidget> createState() => _PlanSettingsUi();
}

class _PlanSettingsUi extends State<PlanSettingsUi> {

  @override
  Widget build(BuildContext context) {
    SchoolClassStorage schoolClassStorage = context.select((PlanStorage ps) => ps.schoolClassStorage);
    Future<PlanType> planType = context.select((Config cfg) => cfg.getMode());

    List<Widget> nonWizardWidgets = [];
    if (!widget.isWizard) {
      nonWizardWidgets.add(Padding(
        padding: const EdgeInsets.only(top: 15),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutUi()),
            );
          }, 
          child: Text(AppLocalizations.of(context)!.aboutApp)
        )
      ));
    }
    List<Widget> generalWidgets = [
      Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Text(AppLocalizations.of(context)!.general, style: TextStyle(color: PlanColors.PrimaryTextColor, fontWeight: FontWeight.bold, fontSize: 16))
      ),
      Divider(color: PlanColors.BorderColor, height: 5),
      const GeneralSettingsUi()
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15, top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Text(AppLocalizations.of(context)!.title, style: TextStyle(color: PlanColors.PrimaryTextColor, fontWeight: FontWeight.bold, fontSize: 32))
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
            child: Text(
              AppLocalizations.of(context)!.chooseFilter, 
              style: TextStyle(color: PlanColors.SecondaryTextColor)
            )
          ),
          FutureBuilder(future: planType, builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data == PlanType.pupil) {
              return Expanded(child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  ...nonWizardWidgets,
                  ...generalWidgets,
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Text(AppLocalizations.of(context)!.schoolTypes, style: TextStyle(color: PlanColors.PrimaryTextColor, fontWeight: FontWeight.bold, fontSize: 16))
                  ),
                  Divider(color: PlanColors.BorderColor, height: 5),
                  Wrap(
                    spacing: 5,
                    children: List<Widget>.generate(schoolClassStorage.getNumberOfTypes(), (index) => SchoolChipUi(chipElem: schoolClassStorage.getType(index)))
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Text(AppLocalizations.of(context)!.classes, style: TextStyle(color: PlanColors.PrimaryTextColor, fontWeight: FontWeight.bold, fontSize: 16))
                  ),
                  Divider(color: PlanColors.BorderColor, height: 5),
                  const ClassChipCollectionUi(),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Text(AppLocalizations.of(context)!.courses, style: TextStyle(color: PlanColors.PrimaryTextColor, fontWeight: FontWeight.bold, fontSize: 16))
                  ),
                  Divider(color: PlanColors.BorderColor, height: 5),
                  const LessonChipCollectionUi()
                ]
              ));
            } else {
              return Expanded(child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  ...nonWizardWidgets,
                  ...generalWidgets,
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Text(AppLocalizations.of(context)!.teacher, style: TextStyle(color: PlanColors.PrimaryTextColor, fontWeight: FontWeight.bold, fontSize: 16))
                  ),
                  Divider(color: PlanColors.BorderColor, height: 5),
                  const TeacherChipCollectionUi()
                ]
              ));
            }
          }
          ),
        ],
      )
    );
  }
}

class ClassChipCollectionUi extends StatefulWidget {

  const ClassChipCollectionUi({super.key});
  
  @override
  State<StatefulWidget> createState() => _ClassChipCollectionUi();

}

class _ClassChipCollectionUi extends State<ClassChipCollectionUi> {

  bool listenerAdded = false;
  late SchoolClassStorage storage;

  void refreshUi() {
    setState(() {});
  }

  @override
  void dispose() {
    storage.removeListener(refreshUi);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schoolClassStorage = context.select((PlanStorage ps) => ps.schoolClassStorage);
    final bookmarkedClasses = context.select((PlanStorage ps) => ps.schoolClassStorage.getBookmarkedByType());
    if (!listenerAdded) {
      schoolClassStorage.addListener(refreshUi);
      storage = schoolClassStorage;
      listenerAdded = true;
    }

    return Wrap(
        direction: Axis.horizontal,
        spacing: 5,
        children: List<Widget>.generate(
          bookmarkedClasses.length, (index) => ClassChipUi(chipElem: bookmarkedClasses.elementAt(index))
        )
      );
  }
}

class LessonChipCollectionUi extends StatefulWidget {

  const LessonChipCollectionUi({super.key});
  
  @override
  State<StatefulWidget> createState() => _LessonChipCollectionUi();

}

class _LessonChipCollectionUi extends State<LessonChipCollectionUi> {

  bool listenerAdded = false;
  late SchoolClassStorage storage;

  void refreshUi() {
    setState(() {});
  }

  @override
  void dispose() {
    storage.removeListener(refreshUi);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schoolClassStorage = context.select((PlanStorage ps) => ps.schoolClassStorage);
    final bookmarkedLessons = context.select((PlanStorage ps) => ps.schoolClassStorage.getBookmarkedLessonsByClass());
    if (!listenerAdded) {
      schoolClassStorage.addListener(refreshUi);
      storage = schoolClassStorage;
      listenerAdded = true;
    }

    return Wrap(
        direction: Axis.horizontal,
        spacing: 5,
        children: List<Widget>.generate(
          bookmarkedLessons.length, (index) => LessonChipUi(chipElem: bookmarkedLessons.elementAt(index))
        )
      );
  }
}

class TeacherChipCollectionUi extends StatefulWidget {

  const TeacherChipCollectionUi({super.key});
  
  @override
  State<StatefulWidget> createState() => _TeacherChipCollectionUi();

}

class _TeacherChipCollectionUi extends State<TeacherChipCollectionUi> {

  bool listenerAdded = false;
  late TeacherStorage storage;

  void refreshUi() {
    setState(() {});
  }

  @override
  void dispose() {
    storage.removeListener(refreshUi);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teacherStorage = context.select((PlanStorage ps) => ps.teacherStorage);
    if (!listenerAdded) {
      teacherStorage.addListener(refreshUi);
      storage = teacherStorage;
      listenerAdded = true;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.generate(
        teacherStorage.teachers.length, (index) => TeacherChipUi(chipElem: teacherStorage.teachers.elementAt(index))
      )
    );
  }
}

class SchoolChipUi extends StatefulWidget {
  final SchoolType chipElem;

  const SchoolChipUi({super.key, required this.chipElem});
  
  @override
  State<StatefulWidget> createState() => _SchoolChipUi();

}

class _SchoolChipUi extends State<SchoolChipUi> {

  @override
  Widget build(BuildContext context) {
    final schoolClassStorage = context.select((PlanStorage ps) => ps.schoolClassStorage);

    return InputChip(
      label: Text(widget.chipElem.name),
      labelStyle: TextStyle(
        color: widget.chipElem.bookmarked ? Colors.white : widget.chipElem.getColor(),
        fontWeight: FontWeight.bold
      ),
      selectedColor: widget.chipElem.getColor(),
      selected: widget.chipElem.bookmarked,
      showCheckmark: false,
      onSelected: (bool selected) {
        setState(() {
          widget.chipElem.setBookmarked(selected);
          schoolClassStorage.disableClassesByType(widget.chipElem.schoolTypeId);
        });
      },
      backgroundColor: Colors.white,
      side: BorderSide(color: widget.chipElem.getColor())
    );
  }
}

class ClassChipUi extends StatefulWidget {
  final SchoolClass chipElem;

  const ClassChipUi({super.key, required this.chipElem});
  
  @override
  State<StatefulWidget> createState() => _ClassChipUi();

}

class _ClassChipUi extends State<ClassChipUi> {

  @override
  Widget build(BuildContext context) {
    SchoolClassStorage scs = context.select((PlanStorage ps) => ps.schoolClassStorage);

    return InputChip(
      label: Text(widget.chipElem.name),
      labelStyle: TextStyle(
        color: widget.chipElem.bookmarked ? Colors.white : scs.getType(widget.chipElem.schoolType).getColor(),
        fontWeight: FontWeight.bold
      ),
      selectedColor: scs.getType(widget.chipElem.schoolType).getColor(),
      selected: widget.chipElem.bookmarked,
      showCheckmark: false,
      onSelected: (bool selected) {
        setState(() {
          widget.chipElem.setBookmarked(selected);
        });
      },
      backgroundColor: Colors.white,
      side: BorderSide(color: scs.getType(widget.chipElem.schoolType).getColor())
    );
  }
}

class LessonChipUi extends StatefulWidget {
  final Lesson chipElem;

  const LessonChipUi({super.key, required this.chipElem});
  
  @override
  State<StatefulWidget> createState() => _LessonChipUi();

}

class _LessonChipUi extends State<LessonChipUi> {

  @override
  Widget build(BuildContext context) {
    SchoolClassStorage scs = context.select((PlanStorage ps) => ps.schoolClassStorage);

    return InputChip(
      label: Text(widget.chipElem.getText()),
      labelStyle: TextStyle(
        color: widget.chipElem.bookmarked ? Colors.white : scs.getTypeByClass(widget.chipElem.name).getColor(),
        fontWeight: FontWeight.bold
      ),
      selectedColor: scs.getTypeByClass(widget.chipElem.name).getColor(),
      selected: widget.chipElem.bookmarked,
      showCheckmark: false,
      onSelected: (bool selected) {
        setState(() {
          widget.chipElem.setBookmarked(selected);
        });
      },
      backgroundColor: Colors.white,
      side: BorderSide(color: scs.getTypeByClass(widget.chipElem.name).getColor())
    );
  }
}

class TeacherChipUi extends StatefulWidget {
  final Teacher chipElem;

  const TeacherChipUi({super.key, required this.chipElem});
  
  @override
  State<StatefulWidget> createState() => _TeacherChipUi();

}

class _TeacherChipUi extends State<TeacherChipUi> {

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(widget.chipElem.listName),
      labelStyle: TextStyle(
        color: widget.chipElem.bookmarked ? Colors.white : PlanColors.PrimaryTextColor,
        fontWeight: FontWeight.bold
      ),
      selectedColor: PlanColors.PrimaryTextColor,
      selected: widget.chipElem.bookmarked,
      showCheckmark: false,
      onSelected: (bool selected) {
        setState(() {
          widget.chipElem.setBookmarked(selected);
        });
      },
      backgroundColor: Colors.white,
      side: BorderSide(color: PlanColors.PrimaryTextColor)
    );
  }
}
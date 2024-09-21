import 'package:auto_route/auto_route.dart';
import 'package:de_fls_wiesbaden_vplan/controllers/authcontroller.dart';
import 'package:de_fls_wiesbaden_vplan/models/school.dart';
import 'package:de_fls_wiesbaden_vplan/routes/routes.gr.dart';
import 'package:de_fls_wiesbaden_vplan/storage/config.dart';
import 'package:de_fls_wiesbaden_vplan/ui/authui.dart';
import 'package:de_fls_wiesbaden_vplan/ui/helper/consts.dart';
import 'package:de_fls_wiesbaden_vplan/ui/styles/plancolors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

/// Widget to show the general settings.
/// E.g. plan mode
/// and offers possibility to log out.
class GeneralSettingsUi extends StatefulWidget {
  final bool isWizard;

  const GeneralSettingsUi({super.key, this.isWizard = false});

  @override
  State<StatefulWidget> createState() => _GeneralSettingsUi();
}

class _GeneralSettingsUi extends State<GeneralSettingsUi> {
  final AuthController _authController = AuthController.getInstance();
  bool listenerAdded = false;

  void refreshUi() {
    setState(() {});
  }

  @override
  initState() {
    super.initState();
    _authController.addListener(listenOnAuthState);
  }

  @override
  void dispose() {
    _authController.removeListener(listenOnAuthState);
    super.dispose();
  }

  void listenOnAuthState() {
    refreshUi();
  }

  @override
  Widget build(BuildContext context) {
    final log = Logger(vplanLoggerId);
    final Config config = context.select((Config ps) => ps);
    final School school = config.getSchoolObj();

    return FutureBuilder(
        future: _authController.isLoggedIn().then((value) {
          log.finer(
              "[mainsettings] Got a value whether we're logged in: ${value.toString()}");
          if (!value) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AuthUi()),
            );
          }
          return value;
        }),
        builder: (context, snapshot) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Tooltip(
                message: AppLocalizations.of(context)!.helpSettingMode,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.planModeForm,
                      style: TextStyle(
                          color: PlanColors.PrimaryTextColor,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(AppLocalizations.of(context)!.pupil),
                    Switch(
                        // This bool value toggles the switch.
                        value: config.mode == PlanType.teacher,
                        activeColor: PlanColors.SelectedIconColor,
                        inactiveTrackColor: Colors.grey,
                        onChanged: !config.teacherPermission
                            ? null
                            : (bool value) {
                                // This is called when the user toggles the switch.
                                setState(() {
                                  config.setMode(value
                                      ? PlanType.teacher
                                      : PlanType.pupil);
                                });
                              }),
                    Text(AppLocalizations.of(context)!.teacher),
                  ],
                ),
              ),
              Tooltip(
                message: AppLocalizations.of(context)!.helpSettingRegular,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.displayRegularPlan,
                      style: TextStyle(
                          color: PlanColors.PrimaryTextColor,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(AppLocalizations.of(context)!.no),
                    Switch(
                      // This bool value toggles the switch.
                      value: config.addRegularPlan,
                      activeColor: PlanColors.SelectedIconColor,
                      onChanged: (bool value) {
                        // This is called when the user toggles the switch.
                        setState(() {
                          config.setAddRegularPlan(value);
                        });
                      }),
                    Text(AppLocalizations.of(context)!.yes),
                  ],
                ),
              ),
              /* Disabled, as its confusing people.
            Row(children: [
              Text(AppLocalizations.of(context)!.pushNotification, style: TextStyle(color: PlanColors.PrimaryTextColor, fontWeight: FontWeight.bold),),
              Text(
                config.notifyRegistered ? AppLocalizations.of(context)!.enabled : AppLocalizations.of(context)!.disabled, 
                style: TextStyle(color: PlanColors.SecondaryTextColor),),
            ]),*/
              Container(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(AppLocalizations.of(context)!.school,
                      style: TextStyle(
                        color: PlanColors.PrimaryTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left)),
              Divider(color: PlanColors.BorderColor, height: 5),
              Container(
                padding: const EdgeInsets.only(left: 5, right: 5),
                decoration: BoxDecoration(
                  color: config.school.id == school.id
                      ? PlanColors.PageIndicatorSelectedColor
                      : null,
                ),
                child: IconButton(
                  icon: Image.asset(school.assetName),
                  iconSize: 50,
                  isSelected: config.school.id == school.id,
                  style: const ButtonStyle(
                    elevation: MaterialStatePropertyAll(2.0),
                  ),
                  onPressed: () {
                    _logout(context);
                  },
                ),
              ),
              Container(
                child: Text(AppLocalizations.of(context)!.clickToLogout),
              )
            ],
          );
        });
  }

  void _logout(BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CupertinoAlertDialog(
            title: Text(AppLocalizations.of(context)!.pleaseConfirm),
            content: Text(AppLocalizations.of(context)!.confirmLogout),
            actions: [
              // The "Yes" button
              CupertinoDialogAction(
                onPressed: confirmLogout,
                isDefaultAction: false,
                isDestructiveAction: true,
                child: Text(AppLocalizations.of(context)!.yes),
              ),
              // The "No" button
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                isDefaultAction: true,
                isDestructiveAction: false,
                child: Text(AppLocalizations.of(context)!.no),
              )
            ],
          );
        });
  }

  Future<void> confirmLogout() async {
    await Future.wait([
      AuthController.getInstance().logout(),
      Config.getInstance().setFirstCallDone(false)
    ]);
    if (mounted && context.mounted) {
      context.router.replaceAll([AuthUiRoute()]);
    }
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:de_fls_wiesbaden_vplan/controllers/authcontroller.dart';
import 'package:de_fls_wiesbaden_vplan/routes/routes.gr.dart';
import 'package:de_fls_wiesbaden_vplan/storage/config.dart';
import 'package:de_fls_wiesbaden_vplan/ui/helper/consts.dart';
import 'package:de_fls_wiesbaden_vplan/ui/styles/plancolors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

@RoutePage()
class AuthUi extends StatefulWidget {
  const AuthUi({super.key, this.errorMessage});

  /// From extern given error message - e.g.
  /// tokens expired and automatic refreshing
  /// is not possible.
  final String? errorMessage;

  @override
  State<AuthUi> createState() => _AuthUi();
}

class _AuthUi extends State<AuthUi> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController.getInstance();
  ValueNotifier<bool> loginOngoing = ValueNotifier(false);
  TextEditingController userName = TextEditingController();
  TextEditingController loginSecret = TextEditingController();

  /// external as well as internal error message.
  /// External: e.g. token is invalid and cannot be refreshed.
  /// Internal: e.g. username / password is wrong.
  String? errorMessage;

  @override
  initState() {
    super.initState();
    if (widget.errorMessage != null) {
      errorMessage = widget.errorMessage;
    }
  }

  @override
  void dispose() {
    loginOngoing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final log = Logger(vplanLoggerId);
    final Config config = Config.getInstance();

    return Scaffold(
        backgroundColor: PlanColors.AppBackgroundColor,
        body: ValueListenableBuilder(
            // rebuilds whenever loginOngoing changes (receives an event)
            valueListenable: loginOngoing,
            builder: (context, value, child) {
              if (value) {
                return const Center(
                    child: SizedBox(
                        height: 80,
                        width: 80,
                        child: CircularProgressIndicator()));
              }

              return SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 30, right: 30, bottom: 15, top: 15),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: Text(AppLocalizations.of(context)!.title,
                                    style: TextStyle(
                                        color: PlanColors.PrimaryTextColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 32))),
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: 15.0, bottom: 15.0),
                                child: Text(
                                    AppLocalizations.of(context)!
                                        .loginDescription,
                                    style: TextStyle(
                                        color: PlanColors.SecondaryTextColor))),
                            Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: Text(
                                    AppLocalizations.of(context)!.school,
                                    style: TextStyle(
                                        color: PlanColors.PrimaryTextColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16))),
                            Divider(color: PlanColors.BorderColor, height: 5),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(Config.schools.length,
                                    (index) {
                                  final school =
                                      Config.schools.elementAt(index);
                                  return Container(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    decoration: BoxDecoration(
                                      color: config.school.id == school.id
                                          ? PlanColors
                                              .PageIndicatorSelectedColor
                                          : null,
                                    ),
                                    child: IconButton(
                                      icon: Image.asset(school.assetName),
                                      iconSize: 50,
                                      isSelected: config.school.id == school.id,
                                      style: const ButtonStyle(
                                        elevation:
                                            MaterialStatePropertyAll(2.0),
                                      ),
                                      onPressed: () {
                                        log.fine("Selected ${school.name}!");
                                        setState(() {
                                          config.setSchool(school.id);
                                        });
                                      },
                                    ),
                                  );
                                })),
                            Padding(
                                padding: const EdgeInsets.only(top: 30.0),
                                child: Text(
                                    AppLocalizations.of(context)!.credentials,
                                    style: TextStyle(
                                        color: PlanColors.PrimaryTextColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16))),
                            Divider(color: PlanColors.BorderColor, height: 5),
                            Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  errorMessage ?? "",
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                )),
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  TextFormField(
                                    autofocus: true,
                                    controller: userName,
                                    decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)!
                                          .username,
                                    ),
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return AppLocalizations.of(context)!
                                            .errorUsername;
                                      }
                                      return null;
                                    },
                                    textInputAction: TextInputAction.next,
                                  ),
                                  TextFormField(
                                    controller: loginSecret,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)!
                                          .password,
                                    ),
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return AppLocalizations.of(context)!
                                            .errorPassword;
                                      }
                                      return null;
                                    },
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (value) async {
                                      return _checkFormLoginResult(
                                          _formKey.currentState);
                                    },
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0),
                                      child: Wrap(
                                          spacing: 5,
                                          runSpacing: 5,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                return _checkFormLoginResult(
                                                    _formKey.currentState);
                                              },
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .login),
                                            ),
                                            ElevatedButton.icon(
                                              icon: const Icon(
                                                  Icons.qr_code_scanner),
                                              label: Text(
                                                  AppLocalizations.of(context)!
                                                      .loginCard),
                                              onPressed: _checkLoginCard,
                                            ),
                                            ElevatedButton(
                                                onPressed: () {
                                                  context.pushRoute(const AboutUiRoute());
                                                },
                                                child: Text(AppLocalizations.of(
                                                        context)!
                                                    .aboutApp))
                                          ])),
                                ],
                              ),
                            )
                          ])));
            }));
  }

  Future<void> _checkLoginCard() async {
    if (context.mounted) {
      context.router.push(AuthScanUiRoute(onScanCompleted: (res) {
        final log = Logger(vplanLoggerId);
        log.finest("Response: $res");
        if (mounted && context.mounted) {
          String? localErrorMessage;
          if (res.isCancelled()) {
            localErrorMessage = AppLocalizations.of(context)?.scanCanceled;
          } else if (res.isInvalidBarcode()) {
            localErrorMessage = AppLocalizations.of(context)?.invalidBarcodeScanned;
          } else if (res.isNoInternet()) {
            localErrorMessage = AppLocalizations.of(context)?.loginNotPossibleInternet;
          } else if (res.isSchoolNotSupported()) {
            localErrorMessage = AppLocalizations.of(context)?.schoolNotSupported;
          }
          setState(() {
            errorMessage = localErrorMessage;
            loginOngoing.value = false;
          });
        }
      }));
    }
  }

  Future<void> _checkFormLoginResult(FormState? loginCardForm) async {
    if (mounted && context.mounted) {
      setState(() => loginOngoing.value = true);
    }
    return _send(loginCardForm).then((value) {
      if (mounted && context.mounted) {
        if (!value) {
          setState(() => loginOngoing.value = false);
        } else {
          context.navigateTo(const WizardRoute());
        }
      }
    });
  }

  /// Get authentication form details in secret store / configuration
  /// and trigger login.
  /// TODO: Make similar / unifi with authscanui!
  Future<bool> _send(FormState? loginCardForm) async {
    final log = Logger(vplanLoggerId);
    final config = Config.getInstance();
    String? localErrorMessage;
    bool loginResult = false;
    if (!context.mounted) return false;
    if (loginCardForm == null || loginCardForm.validate()) {
      await config.setAuthUser(userName.text);
      await config.setAuthSecret(loginSecret.text);
      loginResult = await _authController
          .login()
          .timeout(const Duration(seconds: 2), onTimeout: () {
        if (context.mounted) {
          localErrorMessage = AppLocalizations.of(context)?.loginNotPossibleInternet;
        }
        return false;
      });

    log.finest(
        "Login triggered and got result: ${loginResult ? "Perfect!" : "Failed!"}");
    }
    if (mounted && context.mounted && !loginResult) {
      if (!loginResult && localErrorMessage == null) {
          localErrorMessage =
              AppLocalizations.of(context)?.loginNotPossibleCredentials;
      }
      setState(() => errorMessage = localErrorMessage);
    }

    return loginResult;
  }
}

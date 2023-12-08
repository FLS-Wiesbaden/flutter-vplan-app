import 'dart:convert';
import 'package:de_fls_wiesbaden_vplan/controllers/authcontroller.dart';
import 'package:de_fls_wiesbaden_vplan/storage/config.dart';
import 'package:de_fls_wiesbaden_vplan/ui/aboutui.dart';
import 'package:de_fls_wiesbaden_vplan/ui/authscanui.dart';
import 'package:de_fls_wiesbaden_vplan/ui/flsvplanmainui.dart';
import 'package:de_fls_wiesbaden_vplan/ui/helper/consts.dart';
import 'package:de_fls_wiesbaden_vplan/ui/helper/exceptions.dart';
import 'package:de_fls_wiesbaden_vplan/ui/styles/plancolors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

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
  ValueNotifier<bool> isLoggedIn = ValueNotifier(false);
  TextEditingController userName = TextEditingController();
  TextEditingController loginSecret = TextEditingController();
  /// external as well as internal error message.
  /// External: e.g. token is invalid and cannot be refreshed.
  /// Internal: e.g. username / password is wrong.
  String? errorMessage;

  @override
  initState() {
    super.initState();
    _authController.addListener(listenOnAuthState);
    if (widget.errorMessage != null) {
      errorMessage = widget.errorMessage;
    }
  }

  @override
  void dispose() {
    loginOngoing.dispose();
    _authController.removeListener(listenOnAuthState);
    super.dispose();
  }

  /// Whenever login state is changing, local isLoggedIn
  /// listenable value must be updated.
  void listenOnAuthState() {
    _authController.isLoggedIn().then((value) => isLoggedIn.value = value);
  }

  @override
  Widget build(BuildContext context) {
    final log = Logger(vplanLoggerId);
    final Config config = Config.getInstance();

    return Scaffold(
        backgroundColor: PlanColors.AppBackgroundColor,
        body: FutureBuilder(
            future: _authController.isLoggedIn().then((value) {
              log.finer(
                  "[authui] Got a value whether we're logged in: ${value.toString()}");
              if (value) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          FlsVplanMainUi(title: AppLocalizations.of(context)!.title)),
                );
              }
              return value;
            }),
            builder: (context, snapshot) {
              return ValueListenableBuilder(
                  valueListenable: isLoggedIn,
                  builder: (context, value, child) {
                    if (!snapshot.hasData) {
                      return const Center(
                          child: SizedBox(
                              height: 80,
                              width: 80,
                              child: CircularProgressIndicator()));
                    }

                    return ValueListenableBuilder(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                top: 15.0),
                                            child: Text(AppLocalizations.of(context)!.title,
                                                style: TextStyle(
                                                    color: PlanColors
                                                        .PrimaryTextColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 32))),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                top: 15.0, bottom: 15.0),
                                            child: Text(
                                                AppLocalizations.of(context)!.loginDescription,
                                                style: TextStyle(
                                                    color: PlanColors
                                                        .SecondaryTextColor))),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                top: 15.0),
                                            child: Text(AppLocalizations.of(context)!.school,
                                                style: TextStyle(
                                                    color: PlanColors
                                                        .PrimaryTextColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16))),
                                        Divider(
                                            color: PlanColors.BorderColor,
                                            height: 5),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: List.generate(
                                                Config.schools.length, (index) {
                                              final school = Config.schools
                                                  .elementAt(index);
                                              return Container(
                                                padding: const EdgeInsets.only(
                                                    left: 5, right: 5),
                                                decoration: BoxDecoration(
                                                  color: config.school.id ==
                                                          school.id
                                                      ? PlanColors
                                                          .PageIndicatorSelectedColor
                                                      : null,
                                                ),
                                                child: IconButton(
                                                  icon: Image.asset(
                                                      school.assetName),
                                                  iconSize: 50,
                                                  isSelected: config.school.id ==
                                                      school.id,
                                                  style: const ButtonStyle(
                                                    elevation:
                                                        MaterialStatePropertyAll(
                                                            2.0),
                                                  ),
                                                  onPressed: () {
                                                    log.fine(
                                                        "Selected ${school.name}!");
                                                    setState(() {
                                                      config
                                                          .setSchool(school.id);
                                                    });
                                                  },
                                                ),
                                              );
                                            })),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                top: 30.0),
                                            child: Text(AppLocalizations.of(context)!.credentials,
                                                style: TextStyle(
                                                    color: PlanColors
                                                        .PrimaryTextColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16))),
                                        Divider(
                                            color: PlanColors.BorderColor,
                                            height: 5),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: Text(
                                              errorMessage ?? "",
                                              style: const TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        Form(
                                          key: _formKey,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              TextFormField(
                                                autofocus: true,
                                                controller: userName,
                                                decoration:
                                                    InputDecoration(
                                                  hintText: AppLocalizations.of(context)!.username,
                                                ),
                                                validator: (String? value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return AppLocalizations.of(context)!.errorUsername;
                                                  }
                                                  return null;
                                                },
                                                textInputAction:
                                                    TextInputAction.next,
                                              ),
                                              TextFormField(
                                                controller: loginSecret,
                                                obscureText: true,
                                                decoration:
                                                    InputDecoration(
                                                  hintText: AppLocalizations.of(context)!.password,
                                                ),
                                                validator: (String? value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return AppLocalizations.of(context)!.errorPassword;
                                                  }
                                                  return null;
                                                },
                                                textInputAction:
                                                    TextInputAction.done,
                                                onFieldSubmitted:
                                                    (value) async {
                                                  await _send();
                                                },
                                              ),
                                              Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 16.0),
                                                  child: Wrap(
                                                      spacing: 5,
                                                      runSpacing: 5,
                                                      children: [
                                                        ElevatedButton(
                                                          onPressed: _send,
                                                          child: Text(
                                                              AppLocalizations.of(context)!.login),
                                                        ),
                                                        ElevatedButton.icon(
                                                          icon: const Icon(Icons
                                                              .qr_code_scanner),
                                                          label: Text(
                                                              AppLocalizations.of(context)!.loginCard),
                                                          onPressed: () async {
                                                            final String?
                                                                answer =
                                                                await Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                const AuthScanUi()));
                                                            if (answer != null) {
                                                              try {
                                                                log.finer("Scanned $answer");
                                                                final object = jsonDecode(answer);
                                                                userName.value =
                                                                    TextEditingValue(text: object['clientId']);
                                                                loginSecret.value =
                                                                    TextEditingValue(text: object['clientSecret']);
                                                                config.setSchool(object['school']);
                                                                if (object['mode'] != null) {
                                                                  config.setModeString(object['mode']);
                                                                }
                                                                await _send();
                                                              } on SchoolNotFoundException {
                                                                setState(() {
                                                                  errorMessage =
                                                                      AppLocalizations.of(context)!.schoolNotSupported;
                                                                });
                                                              } on Exception {
                                                                setState(() {
                                                                  errorMessage =
                                                                      AppLocalizations.of(context)!.invalidBarcodeScanned;
                                                                });
                                                              }
                                                            } else {
                                                              setState(() {
                                                                errorMessage =
                                                                    AppLocalizations.of(context)!.scanCanceled;
                                                              });
                                                            }
                                                          },
                                                        ),
                                                        ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            const AboutUi()),
                                                              );
                                                            },
                                                            child: Text(
                                                                AppLocalizations.of(context)!.aboutApp))
                                                      ])),
                                            ],
                                          ),
                                        )
                                      ])));
                        });
                  });
            }));
  }

  /// Get authentication form details in secret store / configuration
  /// and trigger login.
  Future<void> _send() async {
    loginOngoing.value = true; // show spinner
    final config = Config.getInstance();
    if (_formKey.currentState!.validate()) {
      await config.setAuthUser(userName.text);
      await config.setAuthSecret(loginSecret.text);
      if (await _login()) {
        // Force reload!
        setState(() {});
      } else {
        loginOngoing.value = false; // hide spinner
      }
    } else {
      loginOngoing.value = false; // hide spinner
    }
  }

  /// Execute login and set an error message if 
  /// required.
  Future<bool> _login() async {
    final log = Logger(vplanLoggerId);
    bool before = isLoggedIn.value;
    final appLocalizer = AppLocalizations.of(context)!;

    // login call happens here ↓
    errorMessage = null;
    bool loginOK = await _authController
        .login()
        .timeout(const Duration(seconds: 2), onTimeout: () {
      errorMessage = appLocalizer.loginNotPossibleInternet;
      return false;
    });
    log.finest(
        "Login triggered and got result: ${loginOK ? "Perfect!" : "Failed!"}");

    if (!loginOK && errorMessage == null) {
      errorMessage = appLocalizer.loginNotPossibleCredentials;
    }
    bool after = await _authController.isLoggedIn();
    if (before != after) {
      isLoggedIn.value = after;
      log.finest(
          "Login state changed: ${after ? "Logged in" : "Not logged in"}!");
      return true;
    }
    return false;
  }
}

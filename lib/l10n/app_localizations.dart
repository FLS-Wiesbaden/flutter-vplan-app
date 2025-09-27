import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About app'**
  String get aboutApp;

  /// No description provided for @authenticationError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error. Please re-authenticate.'**
  String get authenticationError;

  /// No description provided for @by.
  ///
  /// In en, this message translates to:
  /// **'by'**
  String get by;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @changedRoom.
  ///
  /// In en, this message translates to:
  /// **'Changed room: {room}'**
  String changedRoom(String room);

  /// No description provided for @changedSubject.
  ///
  /// In en, this message translates to:
  /// **'Changed subject: {subject}'**
  String changedSubject(String subject);

  /// No description provided for @changeNotice.
  ///
  /// In en, this message translates to:
  /// **'Change notice: {note}'**
  String changeNotice(String note);

  /// No description provided for @changeType.
  ///
  /// In en, this message translates to:
  /// **'Art: {type}'**
  String changeType(String type);

  /// No description provided for @chooseFilter.
  ///
  /// In en, this message translates to:
  /// **'Select your school type, classes and optionally courses. The list is constantly updated.'**
  String get chooseFilter;

  /// No description provided for @classes.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get classes;

  /// No description provided for @concept.
  ///
  /// In en, this message translates to:
  /// **'Concept'**
  String get concept;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to log out?'**
  String get confirmLogout;

  /// No description provided for @courses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get courses;

  /// No description provided for @createCalendarEntry.
  ///
  /// In en, this message translates to:
  /// **'Create calendar entry'**
  String get createCalendarEntry;

  /// No description provided for @credentials.
  ///
  /// In en, this message translates to:
  /// **'Credentials'**
  String get credentials;

  /// No description provided for @design.
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get design;

  /// No description provided for @development.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get development;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error message: {message}'**
  String errorMessage(String message);

  /// No description provided for @errorOnLoading.
  ///
  /// In en, this message translates to:
  /// **'Error on loading.'**
  String get errorOnLoading;

  /// No description provided for @errorPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter the password.'**
  String get errorPassword;

  /// No description provided for @errorUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter the username.'**
  String get errorUsername;

  /// No description provided for @eventTitle.
  ///
  /// In en, this message translates to:
  /// **'{title}: Hours {hours}'**
  String eventTitle(String title, String hours);

  /// No description provided for @everythingOnSchedule.
  ///
  /// In en, this message translates to:
  /// **'Everything on schedule'**
  String get everythingOnSchedule;

  /// No description provided for @forSomeone.
  ///
  /// In en, this message translates to:
  /// **'for'**
  String get forSomeone;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get go;

  /// No description provided for @helpSettingMode.
  ///
  /// In en, this message translates to:
  /// **'Change of plan mode ist only possible by teachers.'**
  String get helpSettingMode;

  /// No description provided for @helpSettingRegular.
  ///
  /// In en, this message translates to:
  /// **'Adds the regular timetable entries to the personal plan. Requires selection of courses/classes.'**
  String get helpSettingRegular;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'O\'clock'**
  String get hour;

  /// No description provided for @hourTo.
  ///
  /// In en, this message translates to:
  /// **'O\'clock to'**
  String get hourTo;

  /// No description provided for @inClass.
  ///
  /// In en, this message translates to:
  /// **'in class'**
  String get inClass;

  /// No description provided for @inRoom.
  ///
  /// In en, this message translates to:
  /// **'in room'**
  String get inRoom;

  /// No description provided for @invalidBarcodeScanned.
  ///
  /// In en, this message translates to:
  /// **'Invalid barcode scanned!'**
  String get invalidBarcodeScanned;

  /// No description provided for @lastUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last update {updateDate}'**
  String lastUpdate(String updateDate);

  /// No description provided for @license.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginCard.
  ///
  /// In en, this message translates to:
  /// **'Login card'**
  String get loginCard;

  /// No description provided for @loginDescription.
  ///
  /// In en, this message translates to:
  /// **'Log in with the data provided by your school!'**
  String get loginDescription;

  /// No description provided for @loginLoginCard.
  ///
  /// In en, this message translates to:
  /// **'Login via login card'**
  String get loginLoginCard;

  /// No description provided for @loginNotPossibleCredentials.
  ///
  /// In en, this message translates to:
  /// **'Registration was not possible. Please check your access data!'**
  String get loginNotPossibleCredentials;

  /// No description provided for @loginNotPossibleInternet.
  ///
  /// In en, this message translates to:
  /// **'Registration was not possible. You need internet for registration!'**
  String get loginNotPossibleInternet;

  /// No description provided for @myPlan.
  ///
  /// In en, this message translates to:
  /// **'My plan'**
  String get myPlan;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @planModeForm.
  ///
  /// In en, this message translates to:
  /// **'Plan mode: '**
  String get planModeForm;

  /// No description provided for @pleaseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Please confirm'**
  String get pleaseConfirm;

  /// No description provided for @publisher.
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get publisher;

  /// No description provided for @pupil.
  ///
  /// In en, this message translates to:
  /// **'Learner'**
  String get pupil;

  /// No description provided for @regular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get regular;

  /// No description provided for @regularPlan.
  ///
  /// In en, this message translates to:
  /// **'Regular plan'**
  String get regularPlan;

  /// No description provided for @displayRegularPlan.
  ///
  /// In en, this message translates to:
  /// **'Display regular plan: '**
  String get displayRegularPlan;

  /// No description provided for @roomChange.
  ///
  /// In en, this message translates to:
  /// **'Room change'**
  String get roomChange;

  /// No description provided for @scanCanceled.
  ///
  /// In en, this message translates to:
  /// **'Login via the login card was canceled'**
  String get scanCanceled;

  /// No description provided for @school.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get school;

  /// No description provided for @schoolNotSupported.
  ///
  /// In en, this message translates to:
  /// **'The school from the login card is not supported.'**
  String get schoolNotSupported;

  /// No description provided for @schoolPlan.
  ///
  /// In en, this message translates to:
  /// **'School plan'**
  String get schoolPlan;

  /// No description provided for @schoolTypes.
  ///
  /// In en, this message translates to:
  /// **'School types'**
  String get schoolTypes;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Suchen'**
  String get search;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @shareAsPicture.
  ///
  /// In en, this message translates to:
  /// **'Share as picture'**
  String get shareAsPicture;

  /// No description provided for @shareAsText.
  ///
  /// In en, this message translates to:
  /// **'Share as text'**
  String get shareAsText;

  /// No description provided for @standin.
  ///
  /// In en, this message translates to:
  /// **'Standin'**
  String get standin;

  /// No description provided for @standInPlan.
  ///
  /// In en, this message translates to:
  /// **'Standin plan'**
  String get standInPlan;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @storeUnknown.
  ///
  /// In en, this message translates to:
  /// **'Installed via no known store'**
  String get storeUnknown;

  /// No description provided for @substituteTeacher.
  ///
  /// In en, this message translates to:
  /// **'Substitute teacher: {teacherName}'**
  String substituteTeacher(String teacherName);

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'Standin Plan App made by Friedrich-List-Schule Wiesbaden'**
  String get subtitle;

  /// No description provided for @supervision.
  ///
  /// In en, this message translates to:
  /// **'Supervision'**
  String get supervision;

  /// No description provided for @teacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get teacher;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'FLS Standin plan'**
  String get title;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get from;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @sourcecode.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get sourcecode;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @youGetNotified.
  ///
  /// In en, this message translates to:
  /// **'You will be notified when there are new\n substitutions.\nPull to update.'**
  String get youGetNotified;

  /// No description provided for @pushNotification.
  ///
  /// In en, this message translates to:
  /// **'Push notification: '**
  String get pushNotification;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @clickToLogout.
  ///
  /// In en, this message translates to:
  /// **'To logout, please click on the school icon.'**
  String get clickToLogout;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get aboutApp => 'About app';

  @override
  String get authenticationError =>
      'Authentication error. Please re-authenticate.';

  @override
  String get by => 'by';

  @override
  String get cancel => 'Cancel';

  @override
  String changedRoom(String room) {
    return 'Changed room: $room';
  }

  @override
  String changedSubject(String subject) {
    return 'Changed subject: $subject';
  }

  @override
  String changeNotice(String note) {
    return 'Change notice: $note';
  }

  @override
  String changeType(String type) {
    return 'Art: $type';
  }

  @override
  String get chooseFilter =>
      'Select your school type, classes and optionally courses. The list is constantly updated.';

  @override
  String get classes => 'Classes';

  @override
  String get concept => 'Concept';

  @override
  String get confirmLogout => 'Do you really want to log out?';

  @override
  String get courses => 'Courses';

  @override
  String get createCalendarEntry => 'Create calendar entry';

  @override
  String get credentials => 'Credentials';

  @override
  String get design => 'Design';

  @override
  String get development => 'Development';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get email => 'E-mail';

  @override
  String errorMessage(String message) {
    return 'Error message: $message';
  }

  @override
  String get errorOnLoading => 'Error on loading.';

  @override
  String get errorPassword => 'Please enter the password.';

  @override
  String get errorUsername => 'Please enter the username.';

  @override
  String eventTitle(String title, String hours) {
    return '$title: Hours $hours';
  }

  @override
  String get everythingOnSchedule => 'Everything on schedule';

  @override
  String get forSomeone => 'for';

  @override
  String get general => 'General';

  @override
  String get go => 'Let\'s go';

  @override
  String get helpSettingMode =>
      'Change of plan mode ist only possible by teachers.';

  @override
  String get helpSettingRegular =>
      'Adds the regular timetable entries to the personal plan. Requires selection of courses/classes.';

  @override
  String get hour => 'O\'clock';

  @override
  String get hourTo => 'O\'clock to';

  @override
  String get inClass => 'in class';

  @override
  String get inRoom => 'in room';

  @override
  String get invalidBarcodeScanned => 'Invalid barcode scanned!';

  @override
  String lastUpdate(String updateDate) {
    return 'Last update $updateDate';
  }

  @override
  String get license => 'License';

  @override
  String get licenses => 'Licenses';

  @override
  String get login => 'Login';

  @override
  String get loginCard => 'Login card';

  @override
  String get loginDescription =>
      'Log in with the data provided by your school!';

  @override
  String get loginLoginCard => 'Login via login card';

  @override
  String get loginNotPossibleCredentials =>
      'Registration was not possible. Please check your access data!';

  @override
  String get loginNotPossibleInternet =>
      'Registration was not possible. You need internet for registration!';

  @override
  String get myPlan => 'My plan';

  @override
  String get name => 'Name';

  @override
  String get no => 'No';

  @override
  String get password => 'Password';

  @override
  String get phone => 'Phone';

  @override
  String get planModeForm => 'Plan mode: ';

  @override
  String get pleaseConfirm => 'Please confirm';

  @override
  String get publisher => 'Publisher';

  @override
  String get pupil => 'Learner';

  @override
  String get regular => 'Regular';

  @override
  String get regularPlan => 'Regular plan';

  @override
  String get displayRegularPlan => 'Display regular plan: ';

  @override
  String get roomChange => 'Room change';

  @override
  String get scanCanceled => 'Login via the login card was canceled';

  @override
  String get school => 'School';

  @override
  String get schoolNotSupported =>
      'The school from the login card is not supported.';

  @override
  String get schoolPlan => 'School plan';

  @override
  String get schoolTypes => 'School types';

  @override
  String get search => 'Suchen';

  @override
  String get settings => 'Settings';

  @override
  String get shareAsPicture => 'Share as picture';

  @override
  String get shareAsText => 'Share as text';

  @override
  String get standin => 'Standin';

  @override
  String get standInPlan => 'Standin plan';

  @override
  String get store => 'Store';

  @override
  String get storeUnknown => 'Installed via no known store';

  @override
  String substituteTeacher(String teacherName) {
    return 'Substitute teacher: $teacherName';
  }

  @override
  String get subtitle =>
      'Standin Plan App made by Friedrich-List-Schule Wiesbaden';

  @override
  String get supervision => 'Supervision';

  @override
  String get teacher => 'Teacher';

  @override
  String get title => 'FLS Standin plan';

  @override
  String get username => 'Username';

  @override
  String get version => 'Version';

  @override
  String get from => 'from';

  @override
  String get website => 'Website';

  @override
  String get sourcecode => 'Source code';

  @override
  String get yes => 'Yes';

  @override
  String get youGetNotified =>
      'You will be notified when there are new\n substitutions.\nPull to update.';

  @override
  String get pushNotification => 'Push notification: ';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get activate => 'Activate';

  @override
  String get disable => 'Disable';

  @override
  String get clickToLogout => 'To logout, please click on the school icon.';
}

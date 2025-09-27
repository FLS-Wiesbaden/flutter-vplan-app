// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get aboutApp => 'Über die App';

  @override
  String get authenticationError =>
      'Authentifizierungsfehler. Bitte erneut authentifizieren.';

  @override
  String get by => 'bei';

  @override
  String get cancel => 'Abbrechen';

  @override
  String changedRoom(String room) {
    return 'Geänderter Raum: $room';
  }

  @override
  String changedSubject(String subject) {
    return 'Geändertes Fach: $subject';
  }

  @override
  String changeNotice(String note) {
    return 'Änderungshinweis: $note';
  }

  @override
  String changeType(String type) {
    return 'Type: $type';
  }

  @override
  String get chooseFilter =>
      'Wählen Sie Ihre Schulform, Klassen und optional Kurse. Die Liste wird ständig aktualisiert.';

  @override
  String get classes => 'Klassen';

  @override
  String get concept => 'Konzept';

  @override
  String get confirmLogout => 'Möchten Sie sich wirklich abmelden?';

  @override
  String get courses => 'Kurse';

  @override
  String get createCalendarEntry => 'Kalendereintrag erstellen';

  @override
  String get credentials => 'Zugangsdaten';

  @override
  String get design => 'Design';

  @override
  String get development => 'Entwicklung';

  @override
  String get cancelled => 'Entfall';

  @override
  String get email => 'E-Mail';

  @override
  String errorMessage(String message) {
    return 'Fehlermeldung: $message';
  }

  @override
  String get errorOnLoading => 'Fehler beim Laden.';

  @override
  String get errorPassword => 'Bitte geben Sie das Kennwort ein.';

  @override
  String get errorUsername => 'Bitte geben Sie den Benutzernamen ein.';

  @override
  String eventTitle(String title, String hours) {
    return '$title: Stunden $hours';
  }

  @override
  String get everythingOnSchedule => 'Alles nach Plan';

  @override
  String get forSomeone => 'für';

  @override
  String get general => 'Allgemein';

  @override
  String get go => 'Los geht\'s';

  @override
  String get helpSettingMode =>
      'Wechsel des Plantyps ist nur durch Lehrkräfte möglich.';

  @override
  String get helpSettingRegular =>
      'Fügt die regulären Stundenplaneinträge zum persönlichen Plan hinzu. Erfordert die Selektion von Kursen/Klassen.';

  @override
  String get hour => 'Uhr';

  @override
  String get hourTo => 'Uhr bis';

  @override
  String get inClass => 'in Klasse';

  @override
  String get inRoom => 'in Raum';

  @override
  String get invalidBarcodeScanned => 'Ungültiger Barcode gescannt!';

  @override
  String lastUpdate(String updateDate) {
    return 'Letzte Aktualisierung $updateDate';
  }

  @override
  String get license => 'Lizenz';

  @override
  String get licenses => 'Lizenzen';

  @override
  String get login => 'Anmelden';

  @override
  String get loginCard => 'Anmeldekarte';

  @override
  String get loginDescription =>
      'Melden Sie sich mit den bereitgestellten Daten Ihrer Schule ein!';

  @override
  String get loginLoginCard => 'Anmelden über Anmeldekarte';

  @override
  String get loginNotPossibleCredentials =>
      'Eine Anmeldung war nicht möglich. Bitte überprüfen Sie Ihre Zugangsdaten!';

  @override
  String get loginNotPossibleInternet =>
      'Eine Anmeldung war nicht möglich. Sie benötigen Internet für die Anmeldung!';

  @override
  String get myPlan => 'Mein Plan';

  @override
  String get name => 'Name';

  @override
  String get no => 'Nein';

  @override
  String get password => 'Kennwort';

  @override
  String get phone => 'Telefon';

  @override
  String get planModeForm => 'Planmodus: ';

  @override
  String get pleaseConfirm => 'Bitte bestätigen';

  @override
  String get publisher => 'Herausgeber';

  @override
  String get pupil => 'Lernende';

  @override
  String get regular => 'Regulär';

  @override
  String get regularPlan => 'Stundenplan';

  @override
  String get displayRegularPlan => 'Stundenplananzeige: ';

  @override
  String get roomChange => 'Raumänderung';

  @override
  String get scanCanceled => 'Anmelden über die Anmeldekarte wurde abgebrochen';

  @override
  String get school => 'Schule';

  @override
  String get schoolNotSupported =>
      'Die Schule aus der Anmeldekarte wird nicht unterstützt.';

  @override
  String get schoolPlan => 'Vertretungsplan';

  @override
  String get schoolTypes => 'Schulformen';

  @override
  String get search => 'Suchen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get shareAsPicture => 'Als Bild teilen';

  @override
  String get shareAsText => 'Als Text teilen';

  @override
  String get standin => 'Vertretung';

  @override
  String get standInPlan => 'Vertretungsplan';

  @override
  String get store => 'Store';

  @override
  String get storeUnknown => 'Über keinen bekannten Store installiert';

  @override
  String substituteTeacher(String teacherName) {
    return 'Vertretungslehrkraft: $teacherName';
  }

  @override
  String get subtitle =>
      'Vertretungsplan-App made by Friedrich-List-Schule Wiesbaden';

  @override
  String get supervision => 'Aufsicht';

  @override
  String get teacher => 'Lehrkräfte';

  @override
  String get title => 'FLS Vertretungsplan';

  @override
  String get username => 'Benutzername';

  @override
  String get version => 'Version';

  @override
  String get from => 'von';

  @override
  String get website => 'Homepage';

  @override
  String get sourcecode => 'Quellcode';

  @override
  String get yes => 'Ja';

  @override
  String get youGetNotified =>
      'Du wirst benachrichtigt, wenn neue\n Vertretungen vorliegen.\nZiehen zum Aktualisieren.';

  @override
  String get pushNotification => 'Push-Benachrichtigung: ';

  @override
  String get enabled => 'Aktiviert';

  @override
  String get disabled => 'Deaktiviert';

  @override
  String get activate => 'Aktivieren';

  @override
  String get disable => 'Deaktivieren';

  @override
  String get clickToLogout => 'Zum Abmelden bitte auf das Schullogo klicken.';
}

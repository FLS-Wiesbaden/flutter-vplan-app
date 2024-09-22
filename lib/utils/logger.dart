import 'package:de_fls_wiesbaden_vplan/ui/helper/consts.dart';
import 'package:logging/logging.dart';

void configureVPlanLogger() {
  const String log_level = const String.fromEnvironment('LOG_LEVEL');
  if (log_level == null) {
    Logger.root.level = Level.INFO;
  } else if (log_level == 'ALL') {
    Logger.root.level = Level.ALL;
  } else if (log_level == 'FINEST') {
    Logger.root.level = Level.FINEST;
  } else if (log_level == 'FINER') {
    Logger.root.level = Level.FINER;
  } else if (log_level == 'CONFIG') {
    Logger.root.level = Level.CONFIG;
  } else if (log_level == 'INFO') {
    Logger.root.level = Level.INFO;
  } else if (log_level == 'WARNING') {
    Logger.root.level = Level.WARNING;
  } else if (log_level == 'SEVERE') {
    Logger.root.level = Level.SEVERE;
  } else if (log_level == 'SHOUT') {
    Logger.root.level = Level.SHOUT;
  } else if (log_level == 'OFF') {
    Logger.root.level = Level.OFF;
  } else {  
    Logger.root.level = Level.INFO;
  }
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.time} ($vplanAppId) [${record.level.name}]: ${record.message}');
  });
}

Logger getVPlanLogger() {
  return Logger(vplanLoggerId);
}

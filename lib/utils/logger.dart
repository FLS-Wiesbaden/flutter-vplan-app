import 'package:de_fls_wiesbaden_vplan/ui/helper/consts.dart';
import 'package:logging/logging.dart';

void configureVPlanLogger() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.time} ($vplanAppId) [${record.level.name}]: ${record.message}');
  });
}

Logger getVPlanLogger() {
  return Logger(vplanLoggerId);
}



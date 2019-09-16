import 'package:insightops_dart/insightops_dart.dart';
import 'package:logging/logging.dart';

main() {
  // Create handler and pass the URL from log settings.
  final handler = InsightOpsLogger('__LOG_URL__');

  // Define settings for the logger.
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(handler);

  // Create logger.
  final logger = Logger('Test logger');

  // Log info message.
  logger.info('test message');

  // Log errors with stacktrace.
  try {
    throw Error();
  } catch (e, stackTrace) {
    logger.severe('Test failure', e, stackTrace);
  }
}

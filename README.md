![](https://github.com/ookami-kb/insightops_dart/workflows/Dart%20CI/badge.svg)

Unofficial wrapper for using Rapid7 insightOps logs (former LogEntries) with Dart.

This package is using [logging](https://pub.dev/packages/logging) package to do the actual logging, and implements a handler to post the message to insightOps.

## Setting up

Set up a new log by following the [instructions](https://insightops.help.rapid7.com/docs/insightops-webhook#section-create-a-log-to-send-your-data-to), copy a URL that you will use to send your log data to.

## Usage

A simple usage example:

```dart
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

  // Log info message
  logger.info('test message');

  // Log errors with stacktrace
  try {
    throw Error();
  } catch (e, stackTrace) {
    logger.severe('Test failure', e, stackTrace);
  }
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/ookami-kb/insightops_dart/issues

Unofficial wrapper for using Rapid7 insightOps logs (former LogEntries) with Dart.

This package is using [logging](https://pub.dev/packages/logging) package to do the actual logging, and implements a handler to post the message to insightOps.

## Setting up

Set up a new log by following the [instructions](https://insightops.help.rapid7.com/docs/insightops-webhook#section-create-a-log-to-send-your-data-to), copy a URL that you will use to send your log data to.

## Usage

A simple usage example:

```dart
import 'package:insightops_dart/insightops_dart.dart';

main() {
  final handler = InsightOpsLogger('__URL__');

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(handler);

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

[tracker]: http://example.com/issues/replaceme

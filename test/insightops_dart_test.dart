import 'dart:convert';

import 'package:insightops_dart/insightops_dart.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  Logger.root.level = Level.ALL;

  final sentMessages = [];
  final logger = Logger('test');
  final PostHandler testPostHandler =
      (dynamic url, {Map<String, String> headers, dynamic body}) async {
    sentMessages.add(body);
  };
  const _url = 'http://example.com';

  setUp(() {
    sentMessages.clear();
  });

  tearDown(() {
    Logger.root.clearListeners();
  });

  test('posts standard messages', () async {
    Logger.root.onRecord.listen(InsightOpsLogger(_url, post: testPostHandler));

    logger.info('message 1');
    logger.info('message 2');

    await Future.delayed(Duration(seconds: 1));

    expect(json.decode(sentMessages[0])['message'], 'message 1');
    expect(json.decode(sentMessages[1])['message'], 'message 2');
  });

  test('posts message with sync meta info', () async {
    Logger.root.onRecord.listen(InsightOpsLogger(
      _url,
      post: testPostHandler,
      transformBody: (body) => {
        'meta': {'deviceId': 'ID'},
        ...body,
      },
    ));

    logger.info('message');

    await Future.delayed(Duration(seconds: 1));

    expect(json.decode(sentMessages.first)['meta']['deviceId'], 'ID');
  });

  test('posts message with async meta info', () async {
    Logger.root.onRecord.listen(InsightOpsLogger(
      _url,
      post: testPostHandler,
      transformBody: (body) async => {
        'meta': {'deviceId': 'ID'},
        ...body,
      },
    ));

    logger.info('message');

    await Future.delayed(Duration(seconds: 1));

    expect(json.decode(sentMessages.first)['meta']['deviceId'], 'ID');
  });

  test('retries after timeout on error', () async {
    var attempt = 0;
    final PostHandler testPostHandler =
        (dynamic url, {Map<String, String> headers, dynamic body}) async {
      if (attempt == 0) {
        attempt++;
        throw Error();
      }
      sentMessages.add(body);
    };

    Logger.root.onRecord.listen(InsightOpsLogger(
      _url,
      post: testPostHandler,
    ));

    logger.info('message');

    await Future.delayed(Duration(seconds: 1));
    expect(sentMessages.isEmpty, true);

    await Future.delayed(Duration(seconds: 2));
    expect(json.decode(sentMessages.first)['message'], 'message');
  });
}

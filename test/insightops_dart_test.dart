import 'dart:convert';

import 'package:insightops_dart/insightops_dart.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  Logger.root.level = Level.ALL;

  final List<dynamic> sentMessages = [];
  final List<Future> sending = [];
  final logger = Logger('test');
  final PostHandler testPostHandler =
      (dynamic url, {Map<String, String> headers, dynamic body}) {
    sentMessages.add(body);
    final v = Future.value();
    sending.add(v);
    return v;
  };
  final String _url = 'http://example.com';

  setUp(() {
    sentMessages.clear();
    sending.clear();
  });

  tearDown(() {
    Logger.root.clearListeners();
  });

  test('posts standard message', () async {
    Logger.root.onRecord.listen(InsightOpsLogger(_url, post: testPostHandler));

    logger.info('message');
    await Future.wait(sending);

    expect(json.decode(sentMessages.first)['message'], 'message');
  });

  test('posts message with meta info', () async {
    Logger.root.onRecord.listen(InsightOpsLogger(
      _url,
      post: testPostHandler,
      getMeta: () => {'deviceId': 'ID'},
    ));

    logger.info('message');
    await Future.wait(sending);

    expect(json.decode(sentMessages.first)['meta']['deviceId'], 'ID');
  });
}

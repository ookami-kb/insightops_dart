import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

typedef PostHandler = Future<dynamic> Function(
  Uri url, {
  Map<String, String>? headers,
  dynamic body,
});

/// Transforms body of the message.
///
/// [body] is original body of the message, formed by the library.
/// It should return an updated body that will be posted to server.
typedef BodyTransformer = FutureOr<Map<String, dynamic>> Function(
    Map<String, dynamic> body);

/// Creates logger handler for sending messages to insightOps.
///
/// [url] is an insightOps webhook URL defined for your log.
///
/// You can optionally pass [transformBody] parameter that will be called
/// with each request and can be used to change the body. By default,
/// it just returns the original structure.
///
/// [post] parameter does the real HTTP POST request to a server, and is
/// intended mainly for testing.
class InsightOpsLogger {
  InsightOpsLogger(
    this.url, {
    BodyTransformer transformBody = _noTransform,
    PostHandler post = http.post,
  })  : _post = post,
        _transformBody = transformBody {
    _messages = StreamQueue(_records.stream);
    _process();
  }

  /// URL to send log data to. See setup instruction on how to get this URL.
  final Uri url;

  final BodyTransformer _transformBody;
  final PostHandler _post;

  late final StreamQueue<String> _messages;
  final StreamController<String> _records = StreamController();

  void call(LogRecord record) {
    _createBody(record).then((body) {
      if (_records.isClosed) {
        throw StateError('InsightOpsLogger is also disposed');
      }
      _records.add(json.encode(body));
    });
  }

  Future<void> _process() async {
    while (await _messages.hasNext) {
      final record = await _messages.next;
      while (await _sendMessage(record) == false) {
        await Future<void>.delayed(_currentTimeout);
        if (_currentTimeout * _timeoutMultiplier <= _maxTimeout) {
          _currentTimeout *= _timeoutMultiplier;
        }
      }
      _currentTimeout = _initialTimeout;
    }
  }

  Future<bool> _sendMessage(String message) async {
    try {
      await _postRecord(message);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> _postRecord(String body) async {
    await _post(
      url,
      headers: {
        'ContentType': 'application/json',
      },
      body: body,
    );
  }

  /// Call this method when this logger is no longer needed.
  ///
  /// It's an error to add log messages after this method is called.
  Future<void> dispose() async {
    await _records.close();
    await _messages.cancel();
  }

  Future<Map<String, dynamic>> _createBody(LogRecord record) async {
    final body = {
      'message': record.message,
      'loggerName': record.loggerName,
      'sequenceNumber': record.sequenceNumber,
      'time': record.time.toIso8601String(),
      'level': record.level.name,
    };
    if (record.stackTrace != null) {
      body['stackTrace'] = record.stackTrace.toString();
    }
    if (record.error != null) {
      body['error'] = record.error.toString();
    }

    return _transformBody(body);
  }

  Duration _currentTimeout = _initialTimeout;
}

Future<Map<String, dynamic>> _noTransform(Map<String, dynamic> v) async => v;

const Duration _initialTimeout = Duration(seconds: 2);
const Duration _maxTimeout = Duration(minutes: 2);
const int _timeoutMultiplier = 2;

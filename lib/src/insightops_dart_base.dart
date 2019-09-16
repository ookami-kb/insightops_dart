import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

typedef PostHandler = Future Function(dynamic url,
    {Map<String, String> headers, dynamic body});

typedef MetaGetter = Map<String, dynamic> Function();

class InsightOpsLogger {
  InsightOpsLogger(
    this.url, {
    MetaGetter getMeta = _defaultMeta,
    PostHandler post = http.post,
  })  : this._post = post,
        this._getMeta = getMeta {
    _subscription = _records.stream.listen(_postRecord);
  }

  final String url;
  final Map<String, dynamic> Function() _getMeta;
  final PostHandler _post;

  final StreamController<LogRecord> _records = StreamController();
  StreamSubscription _subscription;

  void call(LogRecord record) {
    _records.add(record);
  }

  Future<void> _postRecord(LogRecord record) async {
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
    final meta = _getMeta();
    if (meta?.isNotEmpty == true) {
      body['meta'] = meta;
    }
    await _post(
      url,
      headers: {
        'ContentType': 'application/json',
      },
      body: json.encode(body),
    );
  }

  void dispose() {
    _subscription?.cancel();
    _records.close();
  }
}

Map<String, dynamic> _defaultMeta() => {};

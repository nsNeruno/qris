import 'dart:collection';
import 'dart:convert';

import 'package:flutter/widgets.dart' show StringCharacters;
import 'package:qris/src/errors.dart';

class QRISDecoder extends Converter<String, Map<int, String>> {

  const QRISDecoder({this.lenient = false,});

  @override
  Map<int, String> convert(String input) {
    final i = input.characters.iterator;
    final result = <int, String>{};
    try {
      while (i.moveNext(2,)) {
        int id = int.parse(i.currentCharacters.string,);
        if (i.moveNext(2,)) {
          int length = int.parse(i.currentCharacters.string,);
          if (i.moveNext(length,)) {
            result[id] = i.currentCharacters.string;
            continue;
          }
        }
        break;
      }
    } on FormatException catch (_) {
      final entries = result.entries;
      int? lastTag;
      if (entries.isNotEmpty) {
        lastTag = entries.last.key;
      }
      throw QRISError(
        QRISError.invalidTagOrLength,
        message: 'Unexpected tag/length at ${i.stringBeforeLength} (Last tag: $lastTag)',
      );
    }
    if (!lenient && i.stringAfterLength > 0) {
      throw QRISError(
        QRISError.malformedQRIS, message: 'Unexpected characters "${i.stringAfter}"',
      );
    }
    return result;
  }

  final bool lenient;
}

/// Base class for containing a decoded QRIS information (main or subtag) using
/// [QRISDecoder]
abstract class DecodedQRISData extends UnmodifiableMapBase<int, String> {

  /// Create a decoded [Map] of raw [String] data containing information of
  /// QRIS or it's subtag(s)
  DecodedQRISData(String data, {
    bool lenient = false,
  })
      : _raw = data,
        _internal = Map.unmodifiable(
          QRISDecoder(lenient: lenient,).convert(data,),
        );

  /// Fetch an entry by subtag
  /// Shouldn't override
  @override
  String? operator [](covariant int? key) => _internal[key];

  @override
  Iterable<int> get keys => _internal.keys;

  Map<String, dynamic> toEncodable() => _internal.map(
    (key, value) => MapEntry(key.toString(), value,),
  );

  /// Returns the base data
  @override
  String toString() => _raw;

  final String _raw;
  final Map<int, String> _internal;
}
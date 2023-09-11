import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qris/qris.dart';

import 'sample_data.dart';

void main() {
  test(
    'Decoder Test',
    () {
      final qris = QRIS(sample2,);
      debugPrint(const JsonEncoder.withIndent('\t',).convert(qris.toEncodable(),),);
      expect(true, true,);
    },
  );
}
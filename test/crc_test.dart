import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qris/qris.dart';

import 'sample_data.dart';

void main() {
  group(
    'CRC Test Scenarios',
    () {
      test(
        'CRC Validation test',
        () async {
          const expectedCRC = 'A402';
          final qris = QRIS(sample2,);
          final crc = qris.crcHex;
          expect(crc != null, true,);
          debugPrint('CRC: $crc',);
          final calculatedCRC = qris.calculatedCRCHex;
          debugPrint('Calculated CRC: $calculatedCRC',);
          expect(calculatedCRC?.toUpperCase(), expectedCRC,);
          final isValid = await qris.isCRCValidAsync;
          expect(isValid, true,);
        },
      );

      test(
        'Sample #7 Test',
        () {
          final qris = QRIS(sample7,);
          debugPrint('CRC: ${qris.crc?.toRadixString(16,)}',);
          debugPrint('Calculated CRC: ${qris.calculatedCRC?.toRadixString(16,)}',);
          expect(qris.isCRCValid, true,);
        },
      );
    },
  );
}
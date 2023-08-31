import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qris/qris.dart';

void main() {
  test(
    'CRC Validation test',
    () async {
      const test = '00020101021126550016ID.CO.SHOPEE.WWW01189360091800000000180202180303UBE51440014ID.CO.QRIS.WWW0215ID20190022915550303UBE5204839853033605802ID5906Baznas6013Jakarta Pusat61051034062070703A016304A402';
      const expectedCRC = 'A402';
      final qris = QRIS(test,);
      final crc = qris.crcHex;
      expect(crc != null, true,);
      debugPrint('CRC: $crc',);
      final calculatedCRC = qris.calculatedCRC;
      debugPrint('Calculated CRC: $calculatedCRC',);
      expect(calculatedCRC?.toUpperCase(), expectedCRC,);
      final isValid = await qris.isCRCValidAsync;
      expect(isValid, true,);
    },
  );
}
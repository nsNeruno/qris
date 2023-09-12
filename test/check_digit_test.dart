import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qris/qris.dart';

import 'sample_data.dart';

void main() {
  group(
    'Mod 10 Group Test',
    () {
      test(
        'Basic Test',
        () {
          const samples = {
            '123': 0,
            '1234': 6,
            '12345': 5,
            '123456': 4,
            '1234567': 6,
            '12345678': 8,
            '123456789': 3,
            '1234567890': 7,
            '93600867045678': 9,
          };
          samples.forEach(
            (key, value) {
              debugPrint('Testing "$key" for $value',);
              expect(key.getMod10(verbose: true,), value,);
            },
          );
        },
      );
      test(
        'Check digit verifier test',
        () {
          // const test = '9360077701234567897'; // Whole mPAN
          // const test = '1234567897'; // Merchant Sequence only
          // const test = '9101010138'; // Merchant Sequence only (Tag 51)
          // const test = '19101010138'; // Instrument Code + Merchant Sequence (Tag 51)
          // const test = '36019101010138'; // With Currency, Instrument Code + Merchant Sequence (Tag 51)
          const test = '0123456789'; // Instrument Code + Merchant Sequence
          const checkDigit = 7;
          // 9 + 3 + 6 + 0 + 0 + 7 + 7 + 7 + 0 + 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9
          // 1 * 2 * 1 * 2 * 1 * 2 * 1 * 2 * 1 * 2 * 1 * 2 * 1 * 2 * 1 * 2 * 1 * 2
          // 9 + 6 + 6 + 0 + 0 + 5 + 7 + 5 + 0 + 2 + 2 + 6 + 4 + 1 + 6 + 5 + 8 + 9
          // = 10 - (81 % 10) = 9
          //
          // Merchant Sequence Number only
          // 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9
          // 1 * 2 * 1 * 2 * 1 * 2 * 1 * 2 * 1
          // 1 + 4 + 3 + 8 + 5 + 3 + 7 + 7 + 9
          // = 10 - (47 % 10) = 3
          expect(10 - test.getMod10(verbose: true,), checkDigit,);
        },
      );
      test(
        'Real QRIS Test',
        () {
          const samples = <String, bool>{
            sample1: true,
            sample2: false,
            sample3: false,
            sample4: false,
            sample5: true,
            sample6: false,
          };
          for (final entry in samples.entries) {
            final data = entry.key;
            expect(
              QRIS(data,).defaultDomesticMerchant!.isValidCheckDigitVerbose(),
              entry.value,
            );
          }
        },
      );
    },
  );
}
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qris/qris.dart';

import 'sample_data.dart';

void main() {
  group(
    'Mod 10 Group Test',
    () {
      test(
        'Check Digit Compare',
        () {
          const data = '000201'
              '010211'
              '2667'
              '0018ID.CO.EXAMPLE2.WWW'
              '0115936000140456789'
              '0215MIDCONTOH123456'
              '0303UMI'
              '5137'
              '0014ID.CO.QRIS.WWW'
              '0215ID1019123456781'
              '52041234'
              '5303360'
              '5802ID'
              '5914NamaMerchantC1'
              '6009NamaKota1'
              '61101234567890'
              '62070703K19'
              '6304B22E';
          final qris = QRIS(data,);
          final m26 = qris.defaultDomesticMerchant!;
          final panCode = m26.panCode!;
          debugPrint('PAN Code: $panCode',);
          expect(panCode, '936000140456789',);
          final checkDigit = m26.checkDigit!;
          expect(checkDigit, 6,);
        },
      );
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
            '936000140456789': 4,
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
          final samples = <String, bool>{
            sample1: true,
            sample2: false,
            sample3: false,
            sample4: false,
            sample5: false,
            sample6: false,
          }.entries;
          for (int i = 0; i < samples.length; i++) {
            final entry = samples.elementAt(i,);
            final data = entry.key;
            final qris = QRIS(data,);
            debugPrint('\nReal QRIS Test #${i + 1}',);
            expect(
              qris.defaultDomesticMerchant!.isValidCheckDigitVerbose(),
              entry.value,
            );
            final merchant51 = qris.merchantAccountDomestic;
            if (merchant51 != null) {
              debugPrint('\nReal QRIS Test #${i + 1} (Tag 51)',);
              expect(
                merchant51.isValidCheckDigitVerbose(
                  useDeduction: true,
                ),
                entry.value,
              );
            }
          }
        },
      );
    },
  );
}
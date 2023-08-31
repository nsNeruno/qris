import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Check digit verifier test',
    () {
      // const test = '9360077701234567897'; // Whole mPAN
      // const test = '1234567897'; // Merchant Sequence only
      // const test = '9101010138'; // Merchant Sequence only (Tag 51)
      // const test = '19101010138'; // Instrument Code + Merchant Sequence (Tag 51)
      // const test = '36019101010138'; // With Currency, Instrument Code + Merchant Sequence (Tag 51)
      const test = '01234567897'; // Instrument Code + Merchant Sequence
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
      final checkDigit = int.parse(test[test.length - 1],);
      final chars = test.characters;
      int multiplier = 1;
      int sum = 0;
      for (int i = 0; i < chars.length - 1; i++) {
        int factor = int.parse(
          chars.elementAt(i,),
        ) * multiplier;
        if (factor > 9) {
          sum += 1 + factor % 10;
        } else {
          sum += factor;
        }
        multiplier = multiplier == 1 ? 2 : 1;
      }
      debugPrint('Sum: $sum',);
      debugPrint('Check Digit: $checkDigit',);
      final calculatedCheckDigit = 10 - (sum % 10);
      expect(calculatedCheckDigit, checkDigit,);
    },
  );
}
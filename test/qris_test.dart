import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qris/qris.dart';

import 'sample_data.dart';

void main() {
  test(
    "Test Data Parser",
    () {
      final qris = QRIS(sample1,);
      debugPrint(qris.toString(),);
    },
  );

  test(
    "Test Data Parser #2",
    () {
      final qris = QRIS(sample2,);
      debugPrint(
        qris.merchantName,
      );
      for (var merchant in qris.merchants) {
        debugPrint(
          "${merchant.globallyUniqueIdentifier} | ${merchant.merchantCriteria.toString()}",
        );
      }
      debugPrint(
        qris.pointOfInitiation?.toString(),
      );
    },
  );

  test(
    "Test Data Parser #3",
    () {
      final qris = QRIS(sample3,);
      debugPrint(qris.tipIndicator?.toString(),);
    },
  );
}

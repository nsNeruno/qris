import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qris/qris.dart';

void main() {
  test(
    "Test Data Parser",
    () {
      const qrisData = "00020101021126610014COM.GO-JEK.WWW"
          "01189360091435456007810210G545"
          "6007810303UMI51440014ID.CO.QRIS.WWW"
          "0215ID10190000023280303UMI5204581253033605802ID"
          "5916Kantin Ibu Lilik6013Jakarta Pusat61051031062070703A0163044C6B";
      final qris = QRIS(qrisData,);
      debugPrint(qris.toString(),);
    },
  );

  test(
    "Test Data Parser #2",
    () {
      const qrisData = "00020101021126550016ID.CO.SHOPEE.WWW01189360091800000000180202180303UBE51440014ID.CO.QRIS.WWW0215ID20190022915550303UBE5204839853033605802ID5906Baznas6013Jakarta Pusat61051034062070703A016304A402";
      final qris = QRIS(qrisData,);
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
      const qrisData = "00020101021126610016ID.CO.BPDDIY.WWW01189360011200000015850208000015850303UMI520458125303360550203570505.005802ID5913RM SORE MALAM6015JAKARTA SELATAN61051513262070703D0163045C1C";
      final qris = QRIS(qrisData,);
      debugPrint(qris.tipIndicator?.toString(),);
    },
  );
}

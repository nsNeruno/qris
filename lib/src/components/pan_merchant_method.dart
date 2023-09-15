import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:qris/src/components/merchant.dart';
import 'package:qris/src/extensions.dart';

/// Represents the Transaction/Payment Method using this QRIS Code
enum PANMerchantMethod {
  unspecified,
  /// Debit Cards
  debit,
  /// Credit Cards
  credit,
  /// Common/Popular Electronic Money Providers, e.g: GoPay, OVO, DANA, etc
  electronicMoney,
  /// Reserved for Future Use
  rfu,
}

extension PANMerchantMethodUtils on PANMerchantMethod {

  int get indicator {
    switch (this) {
      case PANMerchantMethod.unspecified: return 0;
      case PANMerchantMethod.debit: return 1;
      case PANMerchantMethod.credit: return 2;
      case PANMerchantMethod.electronicMoney: return 3;
      // TODO: Add [rfu] handler
      default:
        return 0;
    }
  }
}

/// See [Merchant]
mixin PANCodeMixin on MapBase<int, String> {

  /// Personal Account Number (PAN)
  String? get panCode => this[1];

  int? get _panMerchantMethod {
    return int.tryParse('${panCode?[8]}',);
  }

  /// The main transaction/payment method.
  late final PANMerchantMethod panMerchantMethod = () {
    final code = _panMerchantMethod;
    switch (code) {
      case 0: return PANMerchantMethod.unspecified;
      case 1: return PANMerchantMethod.debit;
      case 2: return PANMerchantMethod.credit;
      case 3: return PANMerchantMethod.electronicMoney;
      default:
        if (code != null) {
          if (code >= 4 && code <= 9) {
            return PANMerchantMethod.rfu;
          }
        }
        return PANMerchantMethod.unspecified;
    }
  }();

  /// National Numbering System (NNS), which is the first 8 digits of PAN
  late final String? nationalNumberingSystemDigits = () {
    final panCode = this.panCode;
    if (panCode != null) {
      if (panCode.length >= 8) {
        return panCode.substring(0, 8,);
      }
    }
    return null;
  }();

  /// Currency Code, positioned as 3 digits on [nationalNumberingSystemDigits]
  /// after the first digit (typically **360**)
  late final String? currencyCode = () {
    final nns = nationalNumberingSystemDigits;
    if (nns != null && nns.length >= 4) {
      return nns.substring(1, 4,);
    }
    return null;
  }();

  /// Institution Code, positioned as the last 4 digits on
  /// [nationalNumberingSystemDigits]
  ///
  /// Under [NationalMerchantIdentifier] on tag 51, expected to return _**0000**_
  late final String? institutionCode = () {
    final nns = nationalNumberingSystemDigits;
    if (nns != null && nns.length >= 8) {
      return nns.substring(4, 8,);
    }
    return null;
  }();

  /// Merchant Sequence Data
  ///
  /// Also available under
  /// [NationalMerchantIdentifier.sequenceNumberAndCheckDigit]
  String? get merchantSequence {
    final pan = panCode;
    if (pan != null) {
      return pan.substring(9, pan.length - 1,);
    }
    return null;
  }

  /// Check Digit of the mPAN sequence
  ///
  /// Must be the last digit of the sequence
  int? get checkDigit {
    final pan = panCode;
    if (pan?.isNotEmpty ?? false) {
      return int.tryParse(pan![pan.length - 1],);
    }
    return null;
  }

  /// Performs a Check Digits validation with mod 10 / Luhn Algorithm
  ///
  /// Using serial of [panMerchantMethod] and [merchantSequence] as payload.
  /// If [useDeduction] is true, apply the original `10 - (mod % 10)` result,
  /// else compare the plain Mod 10 result with the Check Digit.
  bool isValidCheckDigit({bool useDeduction = false,}) {
    final mPan = panCode?.toString();
    if (mPan != null) {
      final checkSequence = mPan.substring(0, mPan.length - 1,);
      final mod = checkSequence.getMod10();
      if (useDeduction) {
        final calculatedCheckDigit = 10 - mod;
        return calculatedCheckDigit == checkDigit;
      }
      return mod == checkDigit;
    }
    return false;
  }

  @visibleForTesting
  bool isValidCheckDigitVerbose({bool useDeduction = false,}) {
    final mPan = panCode?.toString();
    if (mPan != null) {
      debugPrint('-----------------',);
      debugPrint('mPAN: $mPan',);
      final checkSequence = mPan.substring(0, mPan.length - 1,);
      debugPrint('Check Digit: $checkDigit',);
      debugPrint('Check Sequence: $checkSequence',);
      final mod = checkSequence.getMod10(verbose: true,);
      debugPrint('Mod 10 Result: $mod',);
      if (useDeduction) {
        final calculatedCheckDigit = 10 - mod;
        debugPrint(
          'Calculated Check Digit: 10 - $mod = $calculatedCheckDigit',
        );
        final result = calculatedCheckDigit == checkDigit;
        debugPrint(
          'Verdict: $calculatedCheckDigit == $checkDigit => $result',
        );
        debugPrint('-----------------',);
        return result;
      } else {
        debugPrint(
          'Calculated Check Digit: $mod',
        );
        final result = mod == checkDigit;
        debugPrint(
          'Verdict: $mod == $checkDigit => $result',
        );
        debugPrint('-----------------',);
        return result;
      }
    }
    return false;
  }
}
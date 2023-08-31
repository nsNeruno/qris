import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:qris/src/components/merchant.dart';

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
  /// Using serial of [panMerchantMethod] and [merchantSequence] as payload
  bool get isValidCheckDigit {
    final merchantSequence = this.merchantSequence;
    final method = _panMerchantMethod;
    final checkDigit = this.checkDigit;
    if (method != null && merchantSequence != null && checkDigit != null) {
      final chars = '$method$merchantSequence'.characters;
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
      final calculatedCheckDigit = 10 - (sum % 10);
      return calculatedCheckDigit == checkDigit;
    }
    return false;
  }
}
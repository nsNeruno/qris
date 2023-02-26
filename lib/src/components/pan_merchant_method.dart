import 'dart:collection';

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

  /// The main transaction/payment method.
  late final PANMerchantMethod panMerchantMethod = () {
    final panCode = this.panCode;
    if (panCode != null) {
      if (panCode.length >= 9) {
        final indicator = panCode[8];
        switch (indicator) {
          case "0": return PANMerchantMethod.unspecified;
          case "1": return PANMerchantMethod.debit;
          case "2": return PANMerchantMethod.credit;
          case "3": return PANMerchantMethod.electronicMoney;
          default:
            final indicatorValue = int.tryParse(indicator,);
            if (indicatorValue != null) {
              if (indicatorValue >= 4 && indicatorValue <= 9) {
                return PANMerchantMethod.rfu;
              }
            }
            return PANMerchantMethod.unspecified;
        }
      }
    }
    return PANMerchantMethod.unspecified;
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
}
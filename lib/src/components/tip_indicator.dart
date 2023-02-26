import 'dart:collection';

/// Tip Indicator indicates how the Tip to the merchant should be calculated/provided.
enum TipIndicator {
  /// The mobile app should ask for consumer's confirmation to provide the tip amount.
  mobileAppRequiresConfirmation,
  /// The tip value must be a fixed numeric amount.
  tipValueFixed,
  /// The tip value must be calculated as percentage amount between 00.01 - 99.99%.
  tipValuePercentage,
}

extension TipIndicatorUtils on TipIndicator {

  String get code {
    switch (this) {
      case TipIndicator.mobileAppRequiresConfirmation:
        return '01';
      case TipIndicator.tipValueFixed:
        return '02';
      case TipIndicator.tipValuePercentage:
        return '03';
    }
  }
}

mixin QRISTipIndicator on MapBase<int, String> {

  /// The [TipIndicator] of the QRIS Code.
  ///
  /// Indicates the origin of the provided Tip to the merchant, if available.
  late final TipIndicator? tipIndicator = () {
    final data = this[55];
    switch (data) {
      case "01": return TipIndicator.mobileAppRequiresConfirmation;
      case "02": return TipIndicator.tipValueFixed;
      case "03": return TipIndicator.tipValuePercentage;
    }
    return null;
  }();

  /// This should be a non-null value if [tipIndicator] is [TipIndicator.tipValueFixed]
  late final num? tipValueOfFixed = () {
    final data = this[56];
    if (data != null) {
      return num.tryParse(data,);
    }
    return null;
  }();

  /// This should be a non-null value if [tipIndicator] is [TipIndicator.tipValuePercentage]
  ///
  /// Expected range is 00.01 to 99.99 (in percentage)
  late final double? tipValueOfPercentage = () {
    final data = this[57];
    if (data != null) {
      return double.tryParse(data,);
    }
    return null;
  }();
}
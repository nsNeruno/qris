import 'dart:collection';

/// Indicator of the merchant's size/scale.
///
/// Excluding the asset values of occupied land for business and infrastructures.
/// Number figures are represented in IDR.
enum MerchantCriteria {
  /// The smallest merchant size with average net profit up to 50 millions and
  /// sales average up to 300 millions.
  micro,
  /// The small merchant size above [MerchantCriteria.micro] with net profit
  /// up to 500 millions and sales average up to 2.5 billions.
  small,
  /// The medium size specifies a net profit range between 500 millions, up to
  /// 10 billions, with sales average up to 50 billions.
  medium,
  /// Number figures are higher than [MerchantCriteria.medium].
  large,
  /// No clear specifications
  regular,
}

extension MerchantCriteriaUtils on MerchantCriteria {

  /// String representation of the criteria (UMI, UKE, UME, UBE, or URE)
  String get criteriaString {
    switch (this) {
      case MerchantCriteria.micro: return 'UMI';
      case MerchantCriteria.small: return 'UKE';
      case MerchantCriteria.medium: return 'UME';
      case MerchantCriteria.large: return 'UBE';
      case MerchantCriteria.regular: return 'URE';
    }
  }
}

/// See [Merchant]
mixin MerchantCriteriaMixin on MapBase<int, String> {

  /// Merchant Criteria which describes the size/scale of the merchant
  MerchantCriteria get merchantCriteria {
    final data = this[3];
    switch (data) {
      case "UMI": return MerchantCriteria.micro;
      case "UKE": return MerchantCriteria.small;
      case "UME": return MerchantCriteria.medium;
      case "UBE": return MerchantCriteria.large;
    }
    return MerchantCriteria.regular;
  }
}
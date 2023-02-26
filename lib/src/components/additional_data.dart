import 'package:qris/src/components/consumer_data_request.dart';
import 'package:qris/src/decoder.dart';

import 'proprietary.dart';

/// Additional data that supports the current QRIS transaction with more
/// technical details.
class AdditionalData
    extends DecodedQRISData
    with AdditionalConsumerDataRequestMixin {

  AdditionalData(String data) : super(data,);

  /// Bill Number or Invoice Number.
  ///
  /// Indicates that the mobile app should ask the consumer for a Bill Number,
  /// such as for Utility Payments.
  String? get billNumber => this[1];

  /// The mobile number that interacts with this transaction.
  ///
  /// Indicates that the consumer should provide a mobile number, especially for
  /// transactions like Phone Utility Payment or Phone Credit Charging.
  String? get mobileNumber => this[2];

  /// Information related to the store's label.
  ///
  /// Indicates that the mobile app should ask the consumer for the store's
  /// label. For example, the store's label will be shown for ease of specific
  /// store identification.
  String? get storeLabel => this[3];

  /// Loyalty card number, if available.
  ///
  /// Indicates that the mobile app should ask the consumer to provide the
  /// loyalty card number, if available.
  String? get loyaltyNumber => this[4];

  /// Merchant/Acquirer defined value for transaction identification.
  ///
  /// Typically used in transaction log or receipts.
  String? get referenceLabel => this[5];

  /// Identifier for a customer.
  ///
  /// Usually depicted as unique Customer IDs, such as Subscription Number,
  /// Student Registration Number, etc.
  String? get customerLabel => this[6];

  /// Value related to the payment terminal of a merchant.
  ///
  /// Can be used to identify a distinct payment terminal within many choices at
  /// a merchant.
  String? get terminalLabel => this[7];

  /// Describes the purpose of the transaction.
  String? get purposeOfTransaction => this[8];

  /// Acquirer's use
  late final ProprietaryData? proprietaryData = () {
    final data = this[99];
    if (data != null) {
      return ProprietaryData(data,);
    }
    return null;
  }();
}
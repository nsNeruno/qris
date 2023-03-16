/// A library to help with interpreting and processing the contents of QRIS
/// (QR Indonesian Standard) code which is widely distributed as a standardized
/// payment medium which integrates with various Payment Systems, mostly mobile
/// banking apps and popular Electronic Money providers that enable QR Code
/// scanning.
library qris;

import 'package:qris/src/components/additional_data.dart';
import 'package:qris/src/components/initiation_point.dart';
import 'package:qris/src/components/merchant.dart';
import 'package:qris/src/components/tip_indicator.dart';
import 'package:qris/src/decoder.dart';

export 'src/components/initiation_point.dart' show InitiationPoint, InitiationPointUtils;
export 'src/components/merchant_criteria.dart' show MerchantCriteria, MerchantCriteriaUtils;
export 'src/components/pan_merchant_method.dart' show PANMerchantMethod, PANMerchantMethodUtils;
export 'src/components/tip_indicator.dart' show TipIndicator, TipIndicatorUtils;

export 'src/errors.dart';

/// Creates an object that holds various information of a QRIS (QR Indonesian
/// Standard) Code.
///
/// Default implementation requires a [String] containing a well-formatted QR
/// text data according to ISO/IEC 18004, which is usually obtainable after
/// scanning a physically printed QR Codes, or the one generated dynamically
/// from certain merchant digital devices.
class QRIS
    extends DecodedQRISData
    with QRISTipIndicator, QRISInitiationPoint {

  /// Generates a QRIS instance with parsed information, given a [data] String.
  ///
  /// Throws a [QRISError] if the provided data is not a valid String that
  /// conforms to QRIS standard.
  QRIS(String data, {
    bool lenient = false,
  }): super(data, lenient: lenient,);

  /// The Payload Format Indicator, indicates the version of the QRIS Code.
  ///
  /// A valid QRIS Code must have this field.
  int get payloadFormatIndicator => int.parse(this[0] ?? "",);

  /// List of merchants associated with Primitive Payment Systems such as
  /// VISA, MasterCard, Union Pay, etc.
  ///
  /// Consisted of Strings referring to the payment identifiers such as the
  /// number of credit/debit card provided.
  late final List<String> primitivePaymentSystemMerchants = () {
    final merchants = <String>[];
    for (int i = 2; i <= 25; i++) {
      final merchant = this[i];
      if (merchant != null) {
        merchants.add(merchant,);
      }
    }
    return merchants.toList(growable: false,);
  }();

  List<String> _getPrimitiveMerchantsByRange(int start, int end,) {
    final merchants = <String>[];
    for (int i = start; i <= end; i++) {
      final merchant = this[i];
      if (merchant != null) {
        merchants.add(merchant,);
      }
    }
    return merchants.toList(growable: false,);
  }

  /// VISA Merchants (ID "02" and "03")
  List<String> get visaMerchants => _getPrimitiveMerchantsByRange(2, 3,);
  /// MasterCard Merchants (ID "04" and "05)
  List<String> get mastercardMerchants => _getPrimitiveMerchantsByRange(4, 5,);
  /// EMVCo Merchants (ID "06" - "08")
  List<String> get emvCoMerchants => _getPrimitiveMerchantsByRange(6, 8,);
  /// Discover Credit Card Merchants (ID "09" and "10")
  List<String> get discoverMerchants => _getPrimitiveMerchantsByRange(9, 10,);
  /// AMEX (American Express) Merchants (ID "11" and "12")
  List<String> get amExMerchants => _getPrimitiveMerchantsByRange(11, 12,);
  /// JCB (Japan Credit Bureau) Merchants (ID "13" and "14")
  List<String> get jcbMerchants => _getPrimitiveMerchantsByRange(13, 14,);
  /// Union Pay Merchants (ID "15" and "16")
  List<String> get unionPayMerchants => _getPrimitiveMerchantsByRange(15, 16,);
  /// EMVCo Merchants (ID "17" - "25")
  List<String> get emvCoMerchants2 => _getPrimitiveMerchantsByRange(17, 25,);

  late final Map<int, Merchant> _merchants = () {
    final merchants = <int, Merchant>{};
    for (int i = 26; i <= 50; i++) {
      final data = this[i];
      if (data != null) {
        merchants[i] = Merchant(data,);
      }
    }
    return merchants;
  }();

  /// All available non-primitive merchants listed on this QRIS Code
  List<Merchant> get merchants => _merchants.values.toList(
    growable: false,
  );

  List<Merchant> _getMerchantsByRange(int start, int end,) {
    final merchants = <Merchant>[];
    for (int i = start; i <= end; i++) {
      final merchant = _merchants[i];
      if (merchant != null) {
        merchants.add(merchant,);
      }
    }
    return merchants.toList(growable: false,);
  }

  /// Domestic Merchants, most common QRIS Codes are used by domestic merchants (ID "26" - "45")
  List<Merchant> get domesticMerchants => _getMerchantsByRange(26, 45,);
  /// Additional Domestic Merchants information as reserve list, usually empty (ID "46" - "50")
  List<Merchant> get reservedDomesticMerchants => _getMerchantsByRange(46, 50,);

  /// Merchant Account Information Domestic Central Repository
  ///
  /// If [merchants] is empty, then most likely there's a single Merchant Account
  /// available at ID "51". (No merchant information between ID "02" to "45")
  late final Merchant? merchantAccountDomestic = this[51] != null
      ? Merchant(this[51]!)
      : null;

  /// Merchant Category Code (MCC in short)
  ///
  /// Code references are available at [https://github.com/greggles/mcc-codes/](https://github.com/greggles/mcc-codes/)
  int? get merchantCategoryCode => int.tryParse(this[52] ?? "",);

  /// The Transaction Currency, conforms to ISO 4217, represented as 3 digits Numeric.
  ///
  /// Should default to constant **"360"** to represent IDR currency (Indonesian).
  /// Reference: [https://en.wikipedia.org/wiki/ISO_4217](https://en.wikipedia.org/wiki/ISO_4217)
  String? get transactionCurrency => this[53];

  num? _userInputTransactionAmount;

  /// The transaction amount contained within this QRIS, or the one entered manually
  /// through [transactionAmount]'s setter, if any.
  num? get transactionAmount => _userInputTransactionAmount ?? originalTransactionAmount;

  /// Set the transaction amount to override the [originalTransactionAmount]
  set transactionAmount(num? amount,) => _userInputTransactionAmount = amount;

  /// The original transaction amount available within this QRIS, fetched from
  /// the raw data, if available.
  late final num? originalTransactionAmount = num.tryParse(this[54] ?? "",);

  num inferTipAmount({
    bool useOriginalAmount = true,
  }) {
    switch (tipIndicator) {
      case TipIndicator.mobileAppRequiresConfirmation:
        return 0;
      case TipIndicator.tipValueFixed:
        return tipValueOfFixed ?? 0;
      case TipIndicator.tipValuePercentage:
        final amount = (useOriginalAmount ? originalTransactionAmount : transactionAmount) ?? 0;
        final pct = tipValueOfPercentage ?? 0;
        return pct / 100 * amount;
      case null:
        return 0;
    }
  }

  /// The country code of the merchant, conforming to ISO 3166-1's Alpha 2 Code.
  ///
  /// Should default to "ID", if available.
  String? get countryCode => this[58];

  /// Name of the merchant, usually presented in UPPER-CASED String.
  String? get merchantName => this[59];

  /// City name of where the merchant is located, usually presented in UPPER-CASED
  /// String.
  String? get merchantCity => this[60];

  /// The postal code that corresponds to merchant's location.
  ///
  /// A non-null value is expected for [countryCode] equals to **"ID"**.
  String? get postalCode => this[61];

  /// Additional data that complements the QRIS data with more technical details.
  late final AdditionalData? additionalDataField = this[62] != null
      ? AdditionalData(this[62]!,)
      : null;

  /// The additional information about the merchant, represented in a preferred
  /// language preference.
  late final LocalizedMerchantInfo? merchantInformationLocalized = this[64] != null
      ? LocalizedMerchantInfo(this[64]!,)
      : null;

  /// The CRC Checksum of the QRIS Code contents as [int].
  late final int? crc = int.tryParse(this[63] ?? '', radix: 16,);

  /// The CRC Checksum of the QRIS Code contents as Hex String
  String? get crcHex => this["63"];

  List<String> get emvCo {
    return List.generate(
      15, (index) => index + 65,
    ).map(
      (e) => this[e],
    ).whereType<String>().toList();
  }
}
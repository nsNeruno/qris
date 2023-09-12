import 'package:flutter/widgets.dart' show StringCharacters;
import 'package:qris/src/components/merchant_criteria.dart';
import 'package:qris/src/components/pan_merchant_method.dart';
import 'package:qris/src/decoder.dart';

/// The information of a Merchant Account
///
/// Plain merchants usually only have a single Merchant Account embedded in the
/// QRIS code.
class Merchant
    extends DecodedQRISData
    with MerchantCriteriaMixin, PANCodeMixin {

  /// Creates Merchant instance from a QRIS subtag information
  Merchant(String data,): super(data);

  /// Merchant identifier in the form of reverse domain name. Usually presented
  /// in UPPER-CASED.
  ///
  /// e.g: COM.EXAMPLE.DEMO
  String? get globallyUniqueIdentifier => this[0];

  /// Merchant ID, with length up to 15 characters
  String? get id => this[2];

  /// (Tag 51 only) Merchant ID, with length between 15-19 characters,
  /// including additional information
  ///
  /// Falls back to [id] return value on tags 26-45
  late final NationalMerchantIdentifier? nationalMerchantId = () {
    if (id != null) {
      try {
        return NationalMerchantIdentifier._(id!,);
      } catch (_) {}
    }
    return null;
  }();

  /// Checks the validity of mPAN sequence
  ///
  /// No checks performed on Merchant obtained on sub tag 51
  @override
  bool isValidCheckDigit({bool useDeduction = false,}) {
    if (nationalMerchantId != null) {
      return true;
    }
    return super.isValidCheckDigit(useDeduction: useDeduction,);
  }
}

/// National Merchant Identifier contained within Entry ID 51 of the QRIS.
class NationalMerchantIdentifier {

  NationalMerchantIdentifier._(String data,): _raw = data {
    String? countryCode;
    int? entityTypeCode;
    int? centuryCode;
    String? generatedYearLastTwoDigits;
    String? sequenceNumberAndCheckDigit;
    final i = data.characters.iterator;
    if (i.moveNext(2,)) {
      countryCode = i.currentCharacters.string;
      if (i.moveNext()) {
        entityTypeCode = int.tryParse(i.currentCharacters.string,);
        if (i.moveNext()) {
          centuryCode = int.tryParse(i.currentCharacters.string,);
          if (i.moveNext(2,)) {
            generatedYearLastTwoDigits = i.currentCharacters.string;
            sequenceNumberAndCheckDigit = i.stringAfter;
          }
        }
      }
    }
    this.countryCode = countryCode;
    this.entityTypeCode = entityTypeCode;
    this.centuryCode = centuryCode;
    this.generatedYearLastTwoDigits = generatedYearLastTwoDigits;
    this.sequenceNumberAndCheckDigit = sequenceNumberAndCheckDigit;
  }

  @override
  String toString() => _raw;

  /// Expected to default to "ID" (Indonesia)
  late final String? countryCode;

  /// Numeric identifier for Business Entity (1 or 2)
  late final int? entityTypeCode;

  late final int? centuryCode;

  /// QR Code Generated year, last two digits
  late final String? generatedYearLastTwoDigits;

  late final String? sequenceNumberAndCheckDigit;
  String? get checkDigit {
    final s = sequenceNumberAndCheckDigit;
    if (s?.isNotEmpty ?? false) {
      return s![s.length - 1];
    }
    return null;
  }

  final String _raw;
}

///
/// Information of the Main Merchant, presented in a preferred language setting.
///
class LocalizedMerchantInfo extends DecodedQRISData {

  LocalizedMerchantInfo(String data) : super(data);

  /// The preferred language, presented in ISO 639 standard (two letters alphabet).
  String? get languagePreference => this[0];

  /// The merchant name, localized by [languagePreference]
  String? get merchantName => this[1];

  /// The city of the merchant location, localized by [languagePreference]
  String? get merchantCity => this[2];
}
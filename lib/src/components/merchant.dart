import 'package:flutter/widgets.dart' show StringCharacters;
import 'package:qris/qris.dart';
import 'package:qris/src/components/merchant_criteria.dart';
import 'package:qris/src/components/pan_merchant_method.dart';
import 'package:qris/src/decoder.dart';

/// The information of a Merchant Account
///
/// A typical QRIS code could be consisting of one of these scenarios:
/// * Single Merchant at Tag 26
/// * Single Merchant at Tag 51
/// * Double Merchant Information at both Tag 26 and 51
///
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
  ///
  /// Typically processed only on tag 51, else ignored.
  String? get id => this[2];

  /// See [PANCodeMixin.institutionCode]
  ///
  /// On Tag 51, returns default value *0000*
  @override
  String? get institutionCode {
    if (super.panCode == null && nationalMerchantId != null) {
      return '0000';
    }
    return super.institutionCode;
  }

  /// See [PANCodeMixin.panCode]
  ///
  /// If subtag `01` and subtag `02` exists at the same time, subtag `02` is
  /// ignored, Merchant on non-51st tag typically might contains both subtags.
  @override
  String? get panCode {
    // Reads default PAN Code from subtag 01 first
    final originPanCode = super.panCode;
    final nmId = nationalMerchantId;
    // Only process NMID, if original PAN Code is missing
    if (originPanCode == null && nmId != null) {
      // Always use `360` for tag 51's currency
      const defaultCurrency = '360';
      final genYear = nmId.generatedYearLastTwoDigits ?? '';
      if (genYear.isEmpty) {
        throw QRISError(
          'MalformedMerchant',
          tag: 51,
          data: nmId.toString(),
          message: 'Invalid Generated Year "$genYear"',
        );
      }
      final lastSegment = '$genYear${nmId.sequenceNumberAndCheckDigit ?? ''}';
      if (lastSegment.length < 11) {
        throw QRISError(
          'MalformedMerchant',
          tag: 51,
          data: nmId.toString(),
          message: 'Invalid NMID 11 Last Digits',
        );
      }
      // mPAN Code formed from tag 51 uses this format
      // [9][360][0000][11 digits consisting of the year, last sequence and check digit]
      return '9$defaultCurrency$institutionCode$genYear$lastSegment';
    }
    return originPanCode;
  }

  /// (Tag 51 only) Merchant ID, with length between 15-19 characters,
  /// including additional information
  ///
  /// Falls back to [id] return value on tags 26-45
  ///
  /// Typically returns null on Merchant that doesn't belong to tag 51.
  late final NationalMerchantIdentifier? nationalMerchantId = () {
    if (id != null) {
      try {
        return NationalMerchantIdentifier._(id!,);
      } catch (_) {}
    }
    return null;
  }();
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
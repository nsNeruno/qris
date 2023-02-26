import 'package:qris/src/decoder.dart';

/// Additional information for Acquirer's purposes.
class ProprietaryData extends DecodedQRISData {

  ProprietaryData(String data) : super(data);

  /// Unique Identifier for this Proprietary Data. Mostly defaults to "00".
  ///
  /// Max length of 32 characters.
  String? get globallyUniqueIdentifier => this[0];

  /// The proprietary data content.
  ///
  /// Max length of 81 characters.
  String? get proprietary => this[1];
}
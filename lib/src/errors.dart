class QRISError extends Error {

  QRISError(this.code, {
    this.tag, this.data, this.message,
  });

  static const invalidTagOrLength = 'invalid_tag_length';
  static const malformedQRIS = 'malformed';

  @override
  String toString() => '$runtimeType($code, ${message ?? 'QRIS Error'})';

  final String code;
  final int? tag;
  final String? data;
  final String? message;
}
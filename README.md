# qris [![Pub](https://img.shields.io/pub/v/qris.svg)](https://pub.dartlang.org/packages/qris)

QR Code Indonesian Standard Interpreter.

## Features

This package enables to break down a valid read QRIS (QR Indonesian Standard) Code into pieces of useful information, such as the QRIS type, merchant name, transaction amount, and various merchant information.

## Usage
For example, given a String read by any QR Reading utilities, stored as variable ``qrisData``
```terminal
00020101021126550016ID.CO.SHOPEE.WWW0118936009180000000018020218
0303UBE51440014ID.CO.QRIS.WWW0215ID20190022915550303UBE520483985
3033605802ID5906Baznas6013Jakarta Pusat61051034062070703A016304A
402
```

```dart
final qris = QRIS(qrisData,);
debugPrint(
  qris.merchantName,
);
// Baznas
      
qris.merchants.forEach(
  (merchant) {
    debugPrint(
      "${merchant.globallyUniqueIdentifier} | ${merchant.merchantCriteria.toString()}",
    );
  },
);
// ID.CO.SHOPEE.WWW | QRISMerchantCriteria.large
      
debugPrint(
qris.pointOfInitiation?.toString(),
);
// QRISInitiationPoint.staticCode
```

## Additional information

Will try to document the available fields when I have time. Issue reports are welcome.

## TO-DOs
- Documenting the available fields
- Adding more factory constructors/object copy utilities
- Usage guide localized in Bahasa
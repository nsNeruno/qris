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

### Reading from Image File/Gallery
I recommend to try out [barcode_finder](https://pub.dev/packages/barcode_finder). 
Here's the modified sample usage of that plugin. (The example implements 
[file_picker](https://pub.dev/packages/file_picker) to pick a file, you may replace it with 
[image_picker](https://pub.dev/packages/image_picker))
```dart
Future<QRIS?> scanFile() async {
  // Used to pick a file from device storage
  final pickedFile = await FilePicker.platform.pickFiles();
  if (pickedFile != null) {
    final filePath = pickedFile.files.single.path;
    if (filePath != null) {
      final scannedData = await BarcodeFinder.scanFile(
        path: path,
        formats: [BarcodeFormat.QR_CODE],
      );
      if (scannedData != null) {
        return QRIS(scannedData,);
      }
    }
  }
  return null;
}
```

### Personal Notes
I documented most of the fields available, but if I miss something, will add in the future. I am 
also welcome for suggestion regarding documenting the fields.

## TO-DOs
- Adding more factory constructors/object copy utilities
- Add a QR Code generator from data
- Usage guide localized in Bahasa
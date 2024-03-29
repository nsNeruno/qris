## 0.7.1

* Adjusted `checkDigit` getter logic under `Merchant` to behave differently under specific tags
* Updated Unit Tests

## 0.7.0

* Exported `Merchant` class and other classes on same file
* Added `getMerchantOnTag` method

## 0.6.6

* Updated CRC Validation logic to perform numeric comparison right away instead of Hex String comparison
* Removed `visibleForTesting` annotation for `calculatedCRC` and `calculatedCRCHex` getters
* Updated Unit Tests

## 0.6.5

* Updated `Merchant` to properly process check digit and mPAN reading from tag 51
* Updated Unit Tests
* Note: Based on Unit Tests, it is recommended to perform check digit validation with deduction enabled for Merchants on Tag 51

## 0.6.4

* Fixed Mod 10 logic for initial multiplier application during calculating the check digit
* *\[BREAKING\]* Getter `isValidCheckDigit` replaced with function with the same name, accepting 
a boolean flag `useDeduction`, defaults to `false` for QRIS specific requirement.
* Updated Unit Tests

## 0.6.3

* Exposed convenient access to `defaultDomesticMerchant`
* Mod 10 logic fixed for Merchant PAN and exposed as String extension
* Updated Unit Tests

## 0.6.1

* Raised Dart SDK Support to `<4.0.0`
* Fixed sub tag 63 getter using wrong index
* Added CRC check utilities

## 0.6.0

* Exposed Check Digit utilities on Merchant PAN code

## 0.5.1+1

* Added example app

## 0.5.1

* Fixed wrong `merchantCity` Tag ID (61 -> 60)
* Raised min Dart SDK to `2.19.3`
* Raised min Flutter version to `2.5.0`

## 0.5.0

* Raised minimum Dart version to `2.18.0`
* Refactored sections as mixins
* Reworked parser decoder
* Added more convenient getters, especially related to `TipIndicator`
* Updated `README.md`

## 0.3.0

* *\[BREAKING\]* Replaced String value of `QRISMerchantAccountDomestic.merchantId` to new type `QRISNationalMerchantIdentifier`

## 0.2.2

* Changed `merchantCriteriaString` to return "URE" to specify Regular Merchants as default value.

## 0.2.1

* Added getter `merchantCriteriaString` for Merchant Information.

## 0.2.0

* Fixed inappropriate data type for Primitive Payment System Merchants, replaced to String.

## 0.1.0

* Initial Release.

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

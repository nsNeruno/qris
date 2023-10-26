import 'package:flutter/foundation.dart';

extension StringUtils on String {

  int getMod10({bool verbose = false,}) {
    final modSum = getMod10Sum(verbose: verbose,);
    final result = modSum % 10;
    if (verbose) {
      debugPrint('getMod10: $modSum % 10 = $result',);
    }
    return result;
  }

  int getMod10Sum({bool verbose = false,}) {
    if (RegExp(r'\D',).hasMatch(this,)) {
      throw ArgumentError.value(
        this, 'String', 'is not a valid numeric String',
      );
    }
    final length = this.length;
    int sum = 0;
    bool multiply = true;
    StringBuffer? buffer;
    List<int>? dBuffer;
    if (verbose) {
      buffer = StringBuffer();
      dBuffer = [];
    }
    for (int i = length - 1; i >= 0; i--) {
      final digit = int.parse(this[i],);
      final factor = multiply ? 2 * digit : digit;
      if (factor > 9) {
        final x = factor % 10 + factor ~/ 10;
        sum += x;
        dBuffer?.add(x,);
      } else {
        sum += factor;
        dBuffer?.add(factor,);
      }
      multiply = !multiply;
    }
    if (dBuffer != null) {
      buffer?.write(
        dBuffer.join(' + ',),
      );
    }
    buffer?.write(' = $sum',);
    if (buffer != null) {
      debugPrint('Mod 10 for $this: $buffer',);
    }
    return sum;
  }
}
import 'dart:convert';
import 'dart:core';

const String b64Zero = 'MA==';

class Amount {
  int number = 0;
  String text = '0';
  String b64 = b64Zero;

  Amount._default()
      : number = 0,
        text = '0',
        b64 = b64Zero;

  Amount._internal(this.number, this.text, this.b64);

  factory Amount.fromNumber(int input) {
    if (input < 0) {
      return Amount._default();
    }

    var n = input;
    var t = input.toString();
    var b = base64Encode(utf8.encode(t));
    return Amount._internal(n, t, b);
  }

  factory Amount.fromText(String input) {
    var test = int.tryParse(input);
    if (test == null) {
      return Amount._default();
    }

    var n = test;
    var t = input;
    var b = base64Encode(utf8.encode(t));
    return Amount._internal(n, t, b);
  }

  factory Amount.fromBase64(String input) {
    try {
      var decodedVal = utf8.decode(base64Decode(input), allowMalformed: false);
      return Amount.fromText(decodedVal);
    } catch (ex) {
      return Amount._default();
    }
  }
}

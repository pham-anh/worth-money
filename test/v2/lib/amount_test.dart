import 'package:my_financial/v2/lib/amount.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('amount from number', () {
    test('number 0', () {
      var a = Amount.fromNumber(0);
      expect(a.number, equals(0));
      expect(a.text, equals('0'));
      expect(a.b64, equals('MA=='));
    });

    test('number 1', () {
      var a = Amount.fromNumber(1);
      expect(a.number, equals(1));
      expect(a.text, equals('1'));
      expect(a.b64, equals('MQ=='));
    });

    test('number -1', () {
      var a = Amount.fromNumber(-1);
      expect(a.number, equals(0));
      expect(a.text, equals('0'));
      expect(a.b64, equals('MA=='));
    });

    test('number 500', () {
      var a = Amount.fromNumber(500);
      expect(a.number, equals(500));
      expect(a.text, equals('500'));
      expect(a.b64, equals('NTAw'));
    });
  });

  group('amount from text', () {
    test('non number text', () {
      var a = Amount.fromText('a');
      expect(a.number, 0);
      expect(a.text, equals('0'));
      expect(a.b64, equals('MA=='));
    });
    test('number text int', () {
      var a = Amount.fromText('1936');
      expect(a.number, 1936);
      expect(a.text, equals('1936'));
      expect(a.b64, equals('MTkzNg=='));
    });
    test('number text not int', () {
      var a = Amount.fromText('19.36');
      expect(a.number, 0);
      expect(a.text, equals('0'));
      expect(a.b64, equals('MA=='));
    });
  });

  group('amount from base64 text', () {
    test('base64 encoded text', () {
      var a = Amount.fromBase64('YWFh');
      expect(a.number, 0);
      expect(a.text, equals('0'));
      expect(a.b64, equals('MA=='));
    });

    test('base64 encoded int', () {
      var a = Amount.fromBase64('MTkzNg==');
      expect(a.number, 1936);
      expect(a.text, equals('1936'));
      expect(a.b64, equals('MTkzNg=='));
    });

    test('base64 encoded double', () {
      var a = Amount.fromBase64('MMTIzLjQ1Ng=='); // echo -n 123.456 | base64
      expect(a.number, 0);
      expect(a.text, equals('0'));
      expect(a.b64, equals('MA=='));
    });
  });
}

import 'dart:core';
import 'package:intl/intl.dart';

class Currency {
  static const String jpy = "jpy";
  static const String vnd = "vnd";
  static const String krw = "krw";

  static List<String> get supportingList {
    return [vnd, jpy, krw];
  }

  static String getIntlMoney(num amount, String? currencyName) {
    String? locale = _getLocale(currencyName);
    String? nameUpper = currencyName?.toUpperCase();

    NumberFormat f =
        NumberFormat.simpleCurrency(locale: locale, name: nameUpper);
    return f.format(amount);
  }

  static String getIntlMoneyCompact(num amount, String? currencyName) {
    NumberFormat f = currencyFormatterForChart(currencyName);
    return f.format(amount);
  }

  static String? _getLocale(String? currencyName) {
    String? locale;
    switch (currencyName) {
      case jpy:
        locale = "ja";
        break;
      case vnd:
        locale = "vi";
        break;
      case krw:
        locale = "ko";
        break;
    }
    return locale;
  }

  static NumberFormat currencyFormatterForChart(String? currencyName) {
    String? locale = _getLocale(currencyName);
    String? nameUpper = currencyName?.toUpperCase();

    return NumberFormat.compactSimpleCurrency(
      locale: locale,
      name: nameUpper,
    );
  }
}

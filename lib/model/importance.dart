import 'dart:core';
import 'package:flutter/material.dart';
import '../shared/app_theme.dart';

class Importance {
  static const basic = 'basic';
  static const nice = 'nice';
  static const wasted = 'wasted';
  static const notSet = 'not_set';

  static const filterAll = 'all';

  static List<String> list() {
    return [basic, nice, wasted, notSet];
  }

  static IconData getIcon(String importance) {
    switch (importance) {
      case basic:
        return Icons.check_circle_outline;
      case nice:
        return Icons.auto_awesome_outlined;
      case wasted:
        return Icons.warning_amber_rounded;
      default:
        return Icons.help_center_outlined;
    }
  }

  static Color getColor(String importance) {
    switch (importance) {
      case basic:
        return MyAppTheme.myPrimarySwatch.shade200;
      case nice:
        return MyAppTheme.myPrimarySwatch.shade300;
      case wasted:
        return MyAppTheme.myPrimarySwatch.shade900;
      default:
        return MyAppTheme.myPrimarySwatch.shade50;
    }
  }

  static String getI18nText(String? lang, String importance) {
    switch (importance) {
      case basic:
        return 'Basic';
      case nice:
        return 'Nice';
      case wasted:
        return 'Wasted';
      default:
        return 'Not set';
    }
  }
}

import 'dart:core';
import 'package:flutter/material.dart';

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

  static Color getColor(BuildContext context, String importance) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (importance) {
      case basic:
        return colorScheme.primary;
      case nice:
        return colorScheme.secondary;
      case wasted:
        return colorScheme.tertiary;
      default:
        return colorScheme.outline;
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

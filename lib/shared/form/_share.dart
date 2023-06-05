import 'dart:core';
import 'package:flutter/material.dart';

import '../../model/cate.dart';
import '../../model/importance.dart';

const textInputMaxLength = 40;
String? validateTextInput(String description) {
  if (description.length > textInputMaxLength) {
    return 'Description is 40 characters max';
  }
  return null;
}

String? validateAmount(String amount) {
  if (amount.isEmpty) {
    return 'Amount is required';
  }
  if (int.parse(amount) < 0) {
    return 'Amount cannot be less than 0';
  }
  return null;
}

List<DropdownMenuItem<String>> buildImportanceSelect(List<String> list) {
  final selectList = <DropdownMenuItem<String>>[];

  for (var p in list) {
    var item = DropdownMenuItem(
      value: p,
      child: Row(
        children: [
          Icon(Importance.getIcon(p), size: 18),
          const SizedBox(width: 3),
          Text(Importance.getI18nText('en', p)),
        ],
      ),
    );

    selectList.add(item);
  }

  return selectList;
}

List<DropdownMenuItem<String>> buildCategorySelect(List<Category> list) {
  final selectList = <DropdownMenuItem<String>>[];
  for (var c in list) {
    var item = DropdownMenuItem(
      value: c.id,
      child: Text(c.name),
    );

    selectList.add(item);
  }

  return selectList;
}

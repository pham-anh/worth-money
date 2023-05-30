import 'dart:core';

const nameMaxLength = 20;
String? validateName(String description) {
  if (description.isEmpty) {
    return 'Description is required';
  }

  if (description.length > nameMaxLength) {
    return 'Description is $nameMaxLength characters max';
  }
  return null;
}

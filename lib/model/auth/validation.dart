import 'dart:core';
import 'package:email_validator/email_validator.dart';

class UserValidation {
  static bool isValidEmail(String email) {
    return EmailValidator.validate(email);
  }

  static int passwordMinLength = 6;
  static String? isValidPassword(String password) {
    if (password.length < passwordMinLength) {
      return 'Password must be at least ${UserValidation.passwordMinLength} characters';
    }

    if (password.contains(' ')) {
      return 'Password cannot contain spaces';
    }

    return null;
  }

  static String? isValidId(String id) {
    // alphabets, numbers, and underscore only
    if (!id.contains(RegExp(r'^[\w\d]+$'))) {
      return 'ID can only contain alphabets, numbers and underscore';
    }

    return null;
  }
}

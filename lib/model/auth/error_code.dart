import 'dart:core';

class SignUpErrorCode {
  static const emailAlreadyInUse = 'email-already-in-use';
  static const invalidEmail = 'invalid-email';
  static const notAllowed = 'operation-not-allowed';
  static const weakPassword = 'weak-password';
}

class LoginErrorCode {
  static const invalidEmail = 'invalid-email';
  static const userDisabled = 'user-disabled';
  static const userNotFound = 'user-not-found';
  static const wrongPassword = 'wrong-password';
}

class CommonCode {
  static const unknownException = 'unknown-exception';
  static const ok = 'ok';
}

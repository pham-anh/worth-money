import 'dart:core';
import 'package:firebase_auth/firebase_auth.dart';
import 'validation.dart';
import 'error_code.dart';

class AppAuth {
  final String id;
  final String password;
  late final String email;

  AppAuth({
    required this.id,
    required this.password,
  }) {
    email = '$id@example.com';
  }

  signUp() async {
    // check ID
    String? idError = UserValidation.isValidId(id);
    if (idError != null) {
      return idError;
    }

    // check password
    String? passwordError = UserValidation.isValidPassword(password);
    if (passwordError != null) {
      return passwordError;
    }

    String code;
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      code = CommonCode.ok;
    } on FirebaseAuthException catch (e) {
      code = e.code;
    } on Exception {
      code = CommonCode.unknownException;
    }

    switch (code) {
      case CommonCode.ok:
        return null;
      case SignUpErrorCode.emailAlreadyInUse:
        return 'This ID has been used. Please choose anther ID.';
      case SignUpErrorCode.invalidEmail:
        return 'ID can only contain alphabets, numbers and underscore.';
      case SignUpErrorCode.weakPassword:
        return 'Password is not safe. Please use a stronger password.';
      default:
        return 'App is not available at this moment. Please try again later';
    }
  }

  login() async {
    String code;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      code = CommonCode.ok;
    } on FirebaseAuthException catch (e) {
      code = e.code;
    } on Exception {
      code = CommonCode.unknownException;
    }

    switch (code) {
      case CommonCode.ok:
        return null;
      case LoginErrorCode.invalidEmail:
      case LoginErrorCode.wrongPassword:
      case LoginErrorCode.userNotFound:
      case LoginErrorCode.userDisabled:
        return 'ID or password is invalid.';
      default:
        return 'App is not available at this moment. Please try again later';
    }
  }

  verifyEmail() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  delete() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 'Please sign in';
    }

    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'requires-recent-login':
          var message = await _reAuthenticateUser();
          return message;
        default:
          return e.message;
      }
    }
  }

  _reAuthenticateUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    AuthCredential credential =
        EmailAuthProvider.credential(email: email, password: password);
    try {
      await user!.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-mismatch':
        case 'user-not-found':
        case 'invalid-credential':
        // this is of EmailAuthProvider.credential
        case 'invalid-email':
        case 'wrong-password':
        // this is of PhoneAuthProvider.credential, so not relate
        case 'invalid-verification-code':
        case 'invalid-verification-id':
          return e.message;
        default:
          return e.message;
      }
    }
  }

  changePassword(String newPass) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 'Please sign in';
    }

    try {
      await user.updatePassword(newPass);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return e.message;
        case 'requires-recent-_login':
          var message = await _reAuthenticateUser();
          return message;
      }
    }
  }
}

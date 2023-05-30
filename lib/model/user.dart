import 'dart:core';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_financial/model/currency.dart';

class AppUser {
  static Future<bool> add(String loginId) async {
    // TODO 2: what if user is deleted in Firebase Auth but login session is still available?
    // --> show message tell user to delete the app
    // --> is that really OK?

    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference profileDoc =
        FirebaseFirestore.instance.doc('users/$uid/config/profile');

    return await profileDoc
        .set({
          'id': loginId,
          'email': '$loginId@example.com',
          'currency': 'jpy',
        })
        .then((value) => true)
        .catchError((error) {
          log(error);
          if (FirebaseAuth.instance.currentUser != null) {
            FirebaseAuth.instance.currentUser!.delete();
          }
          return false;
        });
  }

  static Future<Object?> read() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference profileDoc =
        FirebaseFirestore.instance.doc('users/$uid/config/profile');
    return await profileDoc
        .get()
        .then((value) => value.data())
        .onError((error, stackTrace) => null);
  }

  static Future<Object?> getCurrency() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference profileDoc =
        FirebaseFirestore.instance.doc('users/$uid/config/profile');

    return await profileDoc.get().then((value) {
      var profile = value.data() as Map<String, dynamic>;
      return profile["currency"];
    }).onError((error, stackTrace) {
      log(error.toString());
      return null;
    });
  }

  static Future<bool> updateCurrency(String currencyValue) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference profileDoc =
        FirebaseFirestore.instance.doc('users/$uid/config/profile');
    // check if it is a supported currency
    if (!Currency.supportingList.contains(currencyValue)) {
      log('Unsupported currency: $currencyValue');
      return false;
    }

    return profileDoc
        .update({'currency': currencyValue})
        .then((value) => true)
        .catchError((error) {
          log("Failed to update user: $error");
          return false;
        });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

var uid = FirebaseAuth.instance.currentUser!.uid;
CollectionReference expensesCol =
    FirebaseFirestore.instance.collection('users/$uid/expenses');
DateTime now = DateTime.now();

enum Name { expense, v1Expense }

String getCollectionPath(Name name, [isTest = false]) {
  if (isTest) {
    return '/users/test_uid/test_expense';
  }

  var uid = FirebaseAuth.instance.currentUser!.uid;
  var root = '/users/$uid';

  switch (name) {
    case Name.expense:
      return '$root/v2_expenses';
    case Name.v1Expense:
      return '$root/expenses';
    default:
      throw Exception('unknown name: $name');
  }
}


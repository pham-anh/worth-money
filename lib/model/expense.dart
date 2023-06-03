import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_financial/entity/amount.dart';
import 'package:my_financial/model/_db.dart';

class ExpenseItem {
  Amount amount = Amount.fromNumber(0);
  Timestamp date = Timestamp.now();
  String? category;
  String? detail;
  String? store;
  late final CollectionReference collection;

  ExpenseItem(this.amount, this.date, [this.store, this.detail, this.category])
      : collection = FirebaseFirestore.instance
            .collection(getCollectionPath(Name.expense));

  Future<bool> add() {
    var data = {
      'amount': amount.b64,
      'category': category,
      'detail': detail,
      'store': store,
      'date': date,
    };
    return collection.doc().set(data).then((value) => true).catchError((error) {
      throw error;
    });
  }
}

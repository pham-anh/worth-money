import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_financial/entity/amount.dart';
import 'package:my_financial/model/_db.dart';
import 'dart:developer';

class ExpenseItem {
  Amount amount = Amount.fromNumber(0);
  Timestamp date = Timestamp.now();
  List<String>? labels = [];
  String? detail;
  String? store;
  late final CollectionReference collection;

  ExpenseItem(this.amount, this.date, [this.store, this.detail, this.labels])
      : collection = FirebaseFirestore.instance
            .collection(getCollectionPath(Name.expense));

  Future<bool> add() {
    return collection
        .doc()
        .set({
          'amount': amount.b64,
          'labels': labels,
          'detail': detail,
          'store': store,
          'date': date,
        })
        .then((value) => true)
        .catchError((error) {
          log(error);
          return false;
        });
  }
}

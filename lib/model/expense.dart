import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_financial/model/_db.dart';

class ExpenseItem {
  num amount;
  Timestamp date = Timestamp.now();
  String? category;
  String? detail;
  String? store;
  late final CollectionReference collection;

  ExpenseItem({
    required this.amount,
    required this.date,
    this.store,
    this.detail,
    this.category,
  }) : collection = FirebaseFirestore.instance
            .collection(getCollectionPath(Name.expense));

  @override
  String toString() {
    var data = {
      'amount': amount,
      'category': category,
      'detail': detail,
      'store': store,
      'date': date.toDate().toUtc(),
    };

    return data.toString();
  }

  Future<bool> add() async {
    var data = {
      'amount': amount,
      'category': category,
      'detail': detail,
      'store': store,
      'date': date,
    };
    return collection.doc().set(data).then((value) => true).catchError((error) {
      if (kDebugMode) {
        print(error);
        print(toString());
      }
      return false;
    });
  }

  factory ExpenseItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return ExpenseItem(
      amount: data?["amount"],
      date: data?["date"],
      category: data?["category"],
      detail: data?["detail"],
      store: data?["store"],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "amount": amount,
      "date": date,
      if (category != null) "category": category,
      if (detail != null) "detail": detail,
      if (store != null) "store": store,
    };
  }

  static Future<List<QueryDocumentSnapshot<ExpenseItem>>> list() async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection(getCollectionPath(Name.expense));

    final ref = collection.orderBy('date', descending: true).withConverter(
        fromFirestore: ExpenseItem.fromFirestore,
        toFirestore: (ExpenseItem item, _) => item.toFirestore());

    final docSnap = await ref.get();
    return docSnap.docs;
  }
}

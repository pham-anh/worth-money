import 'dart:core';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '_shared.dart';
import 'protector.dart';

class MonthlyIncomeDetail {
  List<Income> children;
  num total;
  DateTime? month;

  MonthlyIncomeDetail({
    required this.children,
    required this.total,
    this.month,
  });
}

class Income {
  static const noFilter = "no_filter";
  static const collectionName = "incomes";
  String? id;
  late final String description;
  late final num amount;

  /// save date into DB as milliseconds
  late final Timestamp ts;

  Income({
    this.id,
    required this.description,
    required this.amount,
    required this.ts,
  });

  Income._fromDB(Map<String, dynamic> rawData) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    Protector protector = Protector(firebaseUid: uid);
    // create Income object
    id = rawData['id'];
    description = protector.decryptBase64(rawData['description']!);
    amount = num.parse(protector.decryptBase64(rawData['amount']!));
    ts = rawData['ts'];
  }

  /// Encrypt data then make a json to save into DB
  static Map<String, dynamic> _toDBJson(Income i) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    Protector protector = Protector(firebaseUid: uid);

    return {
      'id': i.id,
      'description': protector.encryptToBase64(i.description),
      'amount': protector.encryptToBase64(i.amount.toString()),
      'ts': i.ts,
    };
  }

  static Future<bool> add(Income i) {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference collection =
        FirebaseFirestore.instance.collection('users/$uid/$collectionName');

    // set id
    var docId = Shared.jst1stMillisecondsSinceEpoch(i.ts.toDate());
    i.id = const Uuid().v1();
    return collection
        .doc(docId)
        .set({i.id!: _toDBJson(i)}, SetOptions(merge: true))
        .then((value) => true)
        .catchError((error) {
          log(error);
          return false;
        });
  }

  // Return incomes grouped by each month decreasingly
  static Future<Object?> listAllMonths(
      {String filterDescription = noFilter}) async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference collection =
        FirebaseFirestore.instance.collection('users/$uid/$collectionName');

    return collection.get().then((snapshot) {
      if (snapshot.docs.isEmpty) {
        return [];
      }

      // get all docs (months) in DB and sort them by time
      List<QueryDocumentSnapshot<Object?>> docList = snapshot.docs;
      docList.sort((a, b) {
        return b.id.compareTo(a.id);
      });

      // the final result to return
      List<MonthlyIncomeDetail> monthlyData = [];
      for (QueryDocumentSnapshot<Object?> doc in docList) {
        if (doc.data() == null) {
          continue;
        }
        var docData = doc.data() as Map<String, dynamic>;
        if (docData.isEmpty) {
          continue;
        }

        MonthlyIncomeDetail mon = MonthlyIncomeDetail(
          children: [],
          total: 0,
        );
        for (var element in docData.entries) {
          Map<String, dynamic> rawData = element.value as Map<String, dynamic>;

          Income decryptedIncome = Income._fromDB(rawData);
          if (filterDescription == noFilter) {
            mon.children.add(decryptedIncome);
            mon.total += decryptedIncome.amount;
            continue;
          }
          // add income data into return data of the description contains the filtering key
          if (decryptedIncome.description
              .toLowerCase()
              .contains(filterDescription.toLowerCase())) {
            mon.children.add(decryptedIncome);
            mon.total += decryptedIncome.amount;
            continue;
          }
        }

        if (mon.children.isEmpty) {
          continue;
        }

        mon.children.sort((a, b) => b.ts.compareTo(a.ts));
        var d = mon.children[0].ts.toDate();
        mon.month = DateTime(d.year, d.month, 1);
        monthlyData.add(mon);
      }

      return monthlyData;
    }).catchError((error) {
      log(error);
      return error;
    });
  }

  /// date: any DateTime in the month, it will be use to calculate the timestamp of 1st day of the month
  /// 1st day of the month at 0h at user timezone is the document id for expenses of that month
  static Future<Object?> _listOneMonth(DateTime localTime,
      {String filterDescription = noFilter}) async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference collection =
        FirebaseFirestore.instance.collection('users/$uid/$collectionName');

    return collection
        .doc(Shared.jst1stMillisecondsSinceEpoch(localTime))
        .get()
        .then((snapshot) {
      if (!snapshot.exists) {
        return [];
      }
      var docData = snapshot.data() as Map<String, dynamic>;
      if (docData.isEmpty) {
        return [];
      }
      List<Income> monthData = [];
      for (var element in docData.entries) {
        Map<String, dynamic> rawData = element.value as Map<String, dynamic>;
        // make expense data
        Income decryptedIncome = Income._fromDB(rawData);
        // if there are not any filters
        if (filterDescription == noFilter) {
          monthData.add(decryptedIncome);
          continue;
        }

        // add income data into return data of the description contains the filtering key
        if (!decryptedIncome.description
            .toLowerCase()
            .contains(filterDescription.toLowerCase())) {
          continue;
        }

        monthData.add(decryptedIncome);
      }

      monthData.sort((a, b) => b.ts.compareTo(a.ts));
      return monthData;
    }).catchError((error) {
      log(error);
      return [];
    });
  }

  /// sumEachMonth should returns the number element as `count` number
  /// There are sum = 0 in the result
  /// DateTime should be the 1st of the month
  static Future<Map<DateTime, num>> sumEachMonth({int count = 12}) async {
    Map<DateTime, num> monthlySum = {};
    DateTime date = DateTime.now();
    List<Object?> list = [];
    for (int i = 0; i < count; i++) {
      if (i == 0) {
        list = await _listOneMonth(date) as List<Object?>;
      } else {
        date = Shared.getOneMonthAgo(date);
        list = await _listOneMonth(date) as List<Object?>;
      }
      if (list.isEmpty) {
        monthlySum[DateTime(date.year, date.month, 1)] = 0;
        continue;
      }

      num sum = 0;
      for (var el in list) {
        Income e = el as Income;
        sum += e.amount;
      }
      monthlySum[DateTime(date.year, date.month, 1)] = sum;
    }

    return monthlySum;
  }

  /// Delete current expense and add new expense
  static Future<bool> update(Income e, Timestamp oldts) async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference collection =
        FirebaseFirestore.instance.collection('users/$uid/$collectionName');

    // find old document from old date
    var oldDocId = Shared.jst1stMillisecondsSinceEpoch(oldts.toDate());
    var newDocId = Shared.jst1stMillisecondsSinceEpoch(e.ts.toDate());
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(
        collection.doc(oldDocId),
        {e.id!: FieldValue.delete()},
      );

      // add new data with updated info
      // override expense id
      e.id = const Uuid().v1();
      transaction.set(collection.doc(newDocId), {e.id!: _toDBJson(e)},
          SetOptions(merge: true));

      return true;
    }).then((value) {
      return true;
    }).catchError((error) {
      log(error);
      return false;
    });
  }

  static Future<bool> delete(String id, Timestamp ts) async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference collection =
        FirebaseFirestore.instance.collection('users/$uid/$collectionName');

    var docId = Shared.jst1stMillisecondsSinceEpoch(ts.toDate());
    return await collection
        .doc(docId)
        .update({id: FieldValue.delete()})
        .then((value) => true)
        .catchError((error) {
          log(error);
          return false;
        });
  }
}

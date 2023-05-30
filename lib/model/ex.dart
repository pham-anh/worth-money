import 'dart:core';
import 'dart:developer';
import 'package:logging/logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_financial/model/cate.dart';
import 'package:my_financial/model/importance.dart';
import 'package:uuid/uuid.dart';
import '_db.dart';
import '_shared.dart';
import 'analytics.dart';
import 'protector.dart';

class Expense {
  String? id;
  String? categoryName;
  int? categoryColor;
  late final String description;
  late final num amount;

  /// save date into DB as milliseconds. The key in DB is 'date'
  late final Timestamp ts;
  late final String importance;

  /// category is available when getting data
  late final String categoryId;

  Expense({
    this.id,
    required this.description,
    required this.amount,
    required this.ts,
    required this.categoryId,
    required this.importance,
  });

  /// Convert encrypted rawData in DB to decrypted expense data,
  /// filling category info
  Expense._fromDB(Map<String, dynamic> rawData, Map<String, Category> catList) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    Protector protector = Protector(firebaseUid: uid);
    // create Expense object
    id = rawData['id'];
    description = protector.decryptBase64(rawData['description']!);
    amount = num.parse(protector.decryptBase64(rawData['amount']!));
    ts = rawData['date'];
    importance = rawData['importance'];

    // adjust category, set to default for orphan category
    var cateId = rawData['category_id'];
    if (!catList.containsKey(cateId)) {
      categoryId = Category.notSet;
      categoryName = Category.notSetText;
      categoryColor = Category.notSetColorCode;
    } else {
      categoryId = cateId;
      categoryName = catList[cateId]!.name;
      categoryColor = catList[cateId]!.colorCode;
    }
  }

  /// Encrypt data then make a json to save into DB
  static Map<String, dynamic> _toDBJson(Expense e) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    Protector protector = Protector(firebaseUid: uid);

    return {
      'id': e.id,
      'description': protector.encryptToBase64(e.description),
      'amount': protector.encryptToBase64(e.amount.toString()),
      'category_id': e.categoryId,
      'importance': e.importance,
      'date': e.ts,
    };
  }

  static Future<bool> add(Expense e) {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference collection =
        FirebaseFirestore.instance.collection('users/$uid/expenses');

    // set id
    var docId = Shared.jst1stMillisecondsSinceEpoch(e.ts.toDate());
    e.id = const Uuid().v1();
    return collection
        .doc(docId)
        .set({e.id!: _toDBJson(e)}, SetOptions(merge: true))
        .then((value) => true)
        .catchError((error) {
          log(error);
          return false;
        });
  }

  static Future<Object?> listAllMonths(
      {String filterImportance = Importance.filterAll}) async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference collection =
        FirebaseFirestore.instance.collection('users/$uid/expenses');

    List<Expense> allMonthData = [];
    Map<String, Category> catList = await Category.list().then((categories) {
      return {for (var cate in categories) cate.id: cate};
    });

    return collection.get().then((snapshot) {
      if (snapshot.docs.isEmpty) {
        return [];
      }
      List<QueryDocumentSnapshot<Object?>> docList = snapshot.docs;
      docList.sort((a, b) {
        return b.id.compareTo(a.id);
      });
      for (QueryDocumentSnapshot<Object?> doc in docList) {
        if (doc.data() == null) {
          continue;
        }
        var docData = doc.data() as Map<String, dynamic>;
        if (docData.isEmpty) {
          continue;
        }

        List<Expense> monthData = [];
        for (var element in docData.entries) {
          Map<String, dynamic> rawData = element.value as Map<String, dynamic>;
          Expense decryptedExpense = Expense._fromDB(rawData, catList);
          if (filterImportance == Importance.filterAll) {
            monthData.add(decryptedExpense);
            continue;
          }
          if (filterImportance != decryptedExpense.importance) {
            continue;
          }
          monthData.add(decryptedExpense);
        }

        monthData.sort((a, b) => b.ts.compareTo(a.ts));
        allMonthData.addAll(monthData);
      }

      return allMonthData;
    }).catchError((error) {
      log(error);
      return error;
    });
  }

  /// date: any DateTime in the month, it will be use to calculate the timestamp of 1st day of the month
  /// 1st day of the month at 0h at user timezone is the document id for expenses of that month
  static Future<Object?> listOneMonth(DateTime date,
      {String filterImportance = Importance.filterAll,
      String filterCategory = Category.filterAll}) async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference collection =
        FirebaseFirestore.instance.collection('users/$uid/expenses');

    Map<String, Category> catList = await Category.list().then((categories) {
      return {for (var cate in categories) cate.id: cate};
    }).catchError((err) {
      log('Error: $err');
      return <String, Category>{};
    });

    return collection
        .doc(Shared.jst1stMillisecondsSinceEpoch(date))
        .get()
        .then((snapshot) {
      if (!snapshot.exists) {
        return [];
      }
      var docData = snapshot.data() as Map<String, dynamic>;
      if (docData.isEmpty) {
        return [];
      }
      List<Expense> monthData = [];
      for (var element in docData.entries) {
        Map<String, dynamic> rawData = element.value as Map<String, dynamic>;
        // make expense data
        Expense decryptedExpense = Expense._fromDB(rawData, catList);
        // if there are not any filters
        if (filterImportance == Importance.filterAll &&
            filterCategory == Category.filterAll) {
          monthData.add(decryptedExpense);
          continue;
        }

        // here we have some importance or/ and category filter
        // if no importance filter then there should be category filter
        if (filterImportance == Importance.filterAll) {
          // check category
          if (decryptedExpense.categoryId == filterCategory) {
            monthData.add(decryptedExpense);
            continue;
          }
        }

        // if no category filter then there should be importance filter
        if (filterCategory == Category.filterAll) {
          // check category
          if (decryptedExpense.importance == filterImportance) {
            monthData.add(decryptedExpense);
            continue;
          }
        }

        // if we have both importance and category filter
        if (decryptedExpense.categoryId == filterCategory &&
            decryptedExpense.importance == filterImportance) {
          monthData.add(decryptedExpense);
          continue;
        }
      }
      monthData.sort((a, b) => b.ts.compareTo(a.ts));
      return monthData;
    }).catchError((error) {
      log(error);
      return [];
    });
  }

  /// Calculate since the 1st month we have data
  static Future<Map<String, List<MonthTotal>>> monthlyTotalByCategory() async {
    Map<String, Category> catList = await Category.list().then((categories) {
      return {for (var cate in categories) cate.id: cate};
    });
    // calculate the range to get data
    // (don't include current month because its data is not fixed)
    String end = Shared.docIdFromLocalTime(Shared.getOneMonthAgo(now));
    // get all docs until now
    return expensesCol
        .where(FieldPath.documentId, isLessThanOrEqualTo: end)
        .orderBy(FieldPath.documentId)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isEmpty) {
        return Future.value({});
      }
      // map<category id<doc id, CategoryStat>>
      // this data is a map for easily to access
      Map<String, Map<String, MonthTotal>> tmp = {};
      // this is to know where the stat data should begin
      String? startedDoc;
      for (var doc in snapshot.docs) {
        if (doc.data() == null) {
          continue;
        }
        var docData = doc.data() as Map<String, dynamic>;
        if (docData.isEmpty) {
          continue;
        }

        startedDoc ??= doc.id;

        DateTime month = DateTime.fromMillisecondsSinceEpoch(int.parse(doc.id));
        for (var el in docData.entries) {
          Map<String, dynamic> raw = el.value as Map<String, dynamic>;
          // make expense data (decrypt)
          Expense ex = Expense._fromDB(raw, catList);
          // if the category is not init yet then init it
          if (!tmp.containsKey(ex.categoryId)) {
            tmp[ex.categoryId] = <String, MonthTotal>{
              doc.id: MonthTotal(month: month, total: ex.amount)
            };
            continue;
          }
          // if this docId (month) is not yet assign into the list
          if (!tmp[ex.categoryId]!.containsKey(doc.id)) {
            tmp[ex.categoryId]![doc.id] =
                MonthTotal(month: month, total: ex.amount);
            continue;
          }
          // if the category of the month exists in the list, add amount for it
          tmp[ex.categoryId]?[doc.id]?.accumulate(ex.amount);
        }
      }
      // in case we have some docs but they are all empty in the specified range
      if (tmp.isEmpty) {
        return {};
      }
      // Make return data: map<category id, List<month: datetime, total: num>>
      // and pad 0 for empty month
      List<String> allDocId = [];
      // make a list of all months continuously
      for (var m = DateTime.fromMillisecondsSinceEpoch(int.parse(startedDoc!));
          m.isBefore(Shared.getOneMonthAgo(now));
          m = Shared.getOneMonthNext(m)) {
        allDocId.add(Shared.docIdFromLocalTime(m));
      }
      // the final result
      Map<String, List<MonthTotal>> result = {};
      // loop through each month to create an timeline order list of data
      for (var id in allDocId) {
        tmp.forEach((catId, mapVal) {
          // if category was not added to the result then initialize it
          if (!result.containsKey(catId)) {
            result[catId] = <MonthTotal>[];
          }
          // if the month total map doesn't contain the docid then give it total 0
          // else give it the accumulated data we have summed in the previous process
          if (mapVal.containsKey(id)) {
            result[catId]?.add(mapVal[id]!);
          } else {
            result[catId]?.add(MonthTotal(
                month: DateTime.fromMillisecondsSinceEpoch(int.parse(id)),
                total: 0));
          }
        });
      }
      return result;
    });
  }

  /// date: any DateTime in the month, it will be use to calculate the timestamp of 1st day of the month
  static Future<num> sumOneMonth(DateTime date) async {
    var list = await listOneMonth(date) as List<Object?>;
    if (list.isEmpty) {
      return 0;
    }

    num sum = 0;
    for (var el in list) {
      Expense e = el as Expense;
      sum += e.amount;
    }
    return sum;
  }

  // map key DateTime is 1st 00:00 of the month
  static Future<Map<DateTime, num>> sumEachMonth({int count = 12}) async {
    Map<DateTime, num> monthlySum = {};
    DateTime date = DateTime.now();
    List<Object?> list = [];
    for (int i = 0; i < count; i++) {
      if (i == 0) {
        list = await listOneMonth(date) as List<Object?>;
      } else {
        date = Shared.getOneMonthAgo(date);
        list = await listOneMonth(date) as List<Object?>;
      }
      if (list.isEmpty) {
        monthlySum[DateTime(date.year, date.month, 1)] = 0;
      }

      num sum = 0;
      for (var el in list) {
        Expense e = el as Expense;
        sum += e.amount;
      }
      monthlySum[DateTime(date.year, date.month, 1)] = sum;
    }

    return monthlySum;
  }

  /// Delete current expense and add new expense
  static Future<bool> update(Expense e, Timestamp oldts) async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference collection =
        FirebaseFirestore.instance.collection('users/$uid/expenses');

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
      log(error.toString());
      return false;
    });
  }

  static Future<bool> delete(String id, Timestamp time) async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference collection =
        FirebaseFirestore.instance.collection('users/$uid/expenses');

    var docId = Shared.jst1stMillisecondsSinceEpoch(time.toDate());
    return await collection
        .doc(docId)
        .update({id: FieldValue.delete()})
        .then((value) => true)
        .catchError((error) {
          log(error);
          return false;
        });
  }

  /// Update max line expenses in a month
  static Future<bool> setMax(num max) async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference doc = FirebaseFirestore.instance
        .collection('users/$uid/config')
        .doc("figures");

    return await doc
        .set({"expense_max": max})
        .then((value) => true)
        .catchError((error) {
          throw Exception(error);
        });
  }

  /// Get max line expenses in a month
  /// If the data doesn't exist in DB, return -1
  /// Else, return the error
  /// throw on exception
  static Future<num> max() async {
    final logger = Logger('expense');
    var uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference doc = FirebaseFirestore.instance
        .collection('users/$uid/config')
        .doc("figures");

    return doc.get().then((snapshot) {
      if (!snapshot.exists) {
        return -1;
      }

      var docData = snapshot.data() as Map<String, dynamic>;
      if (!docData.containsKey("expense_max")) {
        return -1;
      }

      return docData["expense_max"] as num;
    }).catchError((error, stacktrace) {
      logger.warning('Oops, an error occurred', error);
      throw Exception(error);
    });
  }
}

import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:my_financial/model/_db.dart';

class Store {
  static final CollectionReference collection =
      FirebaseFirestore.instance.collection(getCollectionPath(Name.store));

  static Future<List<String>?> list() async {
    return collection.limit(1).get().then((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }

      Map<String, dynamic> list =
          snapshot.docs.elementAt(0).data() as Map<String, dynamic>;
      if (!list.containsKey('list')) {
        return null;
      }

      List<String> result = [];
      for (var s in list['list'] as List<dynamic>) {
        result.add(s as String);
      }

      return result;
    }).catchError((error, stackTrace) {
      if (kDebugMode) {
        print(error);
        print(stackTrace);
      }
      return null;
    });
  }
}

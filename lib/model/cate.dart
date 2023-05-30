import 'dart:core';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'protector.dart';
import 'package:diacritic/diacritic.dart';

class Category {
  static const notSet = 'not_set';
  static const notSetText = 'Not set';
  static const notSetColorCode = 0xffD9D9D9;
  static const defaultColorCode = 0xFF36AE7C;

  static const filterAll = 'all';

  late final String name;
  late final num budget;
  late final String id;
  late final int colorCode;

  Category._({
    required this.name,
    required this.budget,
    required this.id,
    required this.colorCode,
  });

  /// Convert encrypted data from DB to human-readable Category
  Category._fromDB(Map<String, dynamic> dbData) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    Protector protector = Protector(firebaseUid: uid);

    id = dbData['id'];
    name = protector.decryptBase64(dbData['name']);
    budget = num.parse(protector.decryptBase64(dbData['budget']));
    // color is added in v1.7
    colorCode =
        dbData.containsKey('color') ? dbData['color'] : defaultColorCode;
  }

  /// Encrypt data then make a json to save into DB
  static Map<String, dynamic> _toDBJson(
      String id, String name, num budget, int colorCode) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    Protector protector = Protector(firebaseUid: uid);

    return {
      'id': id,
      'name': protector.encryptToBase64(name),
      'budget': protector.encryptToBase64(budget.toString()),
      // color is added in v1.7
      'color': colorCode,
    };
  }

  /// Add category with normal, non-encrypted name and budget
  static Future<bool> add(String name, num budget, int colorCode) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference categoryDoc =
        FirebaseFirestore.instance.doc('users/$uid/config/categories');

    // check if name exists
    bool duplicated = await isDuplicated(name).then((value) => value);
    if (duplicated) return false;

    var catUuid = const Uuid().v1();
    return await categoryDoc
        .set(
          {catUuid: _toDBJson(catUuid, name, budget, colorCode)},
          SetOptions(merge: true),
        )
        .then((value) => true)
        .catchError((error) {
          log(error.toString());
          return false;
        });
  }

  /// Update category with normal, non-encrypted name and budget.
  /// Note: The category of old expenses data in DB will be unchanged.
  /// It will be override to Not Set on data retrieving
  static Future<bool> update(
      String id, String name, num budget, int colorCode) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference categoryDoc =
        FirebaseFirestore.instance.doc('users/$uid/config/categories');

    // check if name exists in other categories
    bool duplicated = await isDuplicated(name, id: id).then((value) => value);
    if (duplicated) return false;

    return await categoryDoc
        .update({id: _toDBJson(id, name, budget, colorCode)})
        .then((value) => true)
        .catchError((error) {
          log(error.toString());
          return false;
        });
  }

  /// List all category. Return data is decrypted to normal human-readable
  /// data that can be directly used in front-end
  static Future<List<Category>> list({bool includeNotSet = false}) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference categoryDoc =
        FirebaseFirestore.instance.doc('users/$uid/config/categories');

    List<Category> decryptedList = [];
    return categoryDoc.get().then((snapshot) {
      if (!snapshot.exists) {
        return decryptedList;
      }
      var data = snapshot.data() as Map<String, dynamic>;
      // convert to category object list
      data.entries.map((record) {
        Map<String, dynamic> rawData = record.value as Map<String, dynamic>;
        decryptedList.add(Category._fromDB(rawData));
      }).toList();

      // order by name
      decryptedList.sort((a, b) {
        return removeDiacritics(a.name).compareTo(removeDiacritics(b.name));
      });

      // lastly, add default value which is not in DB
      // want this one at the bottom of the list
      if (includeNotSet) {
        decryptedList.add(Category._(
            id: notSet,
            name: notSetText,
            budget: 0,
            colorCode: notSetColorCode));
      }

      return decryptedList;
    }).catchError((error) {
      log(error.toString());
      return decryptedList;
    });
  }

  /// Read 1 category. Return data is decrypted to normal human-readable
  /// data that can be directly used in front-end
  static Future<Object?> read(String id) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference categoryDoc =
        FirebaseFirestore.instance.doc('users/$uid/config/categories');

    return categoryDoc.get().then((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      var dbData = snapshot.data() as Map<String, dynamic>;
      // decrypt and convert to category object
      return Category._fromDB(dbData);
    });
  }

  /// Delete category by its id
  static Future<bool> delete(String id) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference categoryDoc =
        FirebaseFirestore.instance.doc('users/$uid/config/categories');

    return await categoryDoc
        .update({id: FieldValue.delete()})
        .then((value) => true)
        .catchError((error) {
          log(error);
          return false;
        });
  }

  /// Check if category name duplicated. Name parameter is normal, human-readable
  static Future<bool> isDuplicated(String name, {String? id}) async {
    var cateList = await list().then((category) {
      return category;
    });

    if (cateList.isEmpty) return false;
    var index = cateList.indexWhere((category) {
      if (id != null) {
        return (category.id != id && category.name == name);
      }
      return category.name == name;
    });

    return index != -1;
  }
}

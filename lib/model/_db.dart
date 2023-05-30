import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

var uid = FirebaseAuth.instance.currentUser!.uid;
CollectionReference expensesCol =
    FirebaseFirestore.instance.collection('users/$uid/expenses');
DateTime now = DateTime.now();

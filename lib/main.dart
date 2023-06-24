import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_financial/screen/expense/list.dart';
import 'package:my_financial/firebase_options.dart';
import 'package:my_financial/screen/login/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // check if we have user logged in
    User? user = FirebaseAuth.instance.currentUser;
    return MaterialApp(
      title: 'My Money',
      home: user == null ? const LoginPage() : const ExpenseListPage(),
      theme: ThemeData(
          colorSchemeSeed: const Color(0xff6750a4), useMaterial3: true, ),
    );
  }
}

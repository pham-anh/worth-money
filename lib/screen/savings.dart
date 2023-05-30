import 'package:flutter/material.dart';
import '../shared/menu_bottom.dart';

class SavingListPage extends StatelessWidget {
  const SavingListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Savings'),
      ),
      body: Container(),
      bottomNavigationBar: const MenuBottom(menuName: AppMenuItem.dashboard),
    );
  }
}

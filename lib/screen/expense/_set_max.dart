import 'package:flutter/material.dart';
import 'package:my_financial/screen/expense/list.dart';

import '../../model/ex.dart';

showMaxLineDialog(BuildContext context, num max) {
  final formKey = GlobalKey<FormState>(debugLabel: 'ExpenseMaxSet');
  TextEditingController controller = TextEditingController();
  if (max >= 0) {
    controller = TextEditingController(text: max.toString());
  }

  showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Set max"),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == "") {
                  return null;
                }
                var n = num.tryParse(value!);
                if (n == null) {
                  return "Please enter a number";
                }
                if (n < 0) {
                  return "Max must be greater than 0";
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel')),
            TextButton(
                onPressed: () async {
                  // validate
                  if (!formKey.currentState!.validate()) {
                    return;
                  }

                  // update data
                  num newMax = 0;
                  if (controller.text != "") {
                    var n = num.tryParse(controller.text);
                    if (n != null) {
                      newMax = n;
                    }
                  }
                  // update DB
                  await Expense.setMax(newMax).onError((error, stackTrace) {
                    var err = error.toString() + stackTrace.toString();
                    throw Exception(err);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Max updated ')));
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const ExpenseListPage()),
                      (Route<dynamic> route) => false);
                },
                child: const Text('OK'))
          ],
          elevation: 24,
        );
      });
}

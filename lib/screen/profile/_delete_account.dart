import 'package:flutter/material.dart';
import 'package:my_financial/model/currency.dart';

showAccountDeleteDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete your account'),
          content: const Text(
              'You are about to delete your account. All data will be deleted. It cannot not be reverted.\n\nAre you sure?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel')),
            TextButton(
                onPressed: () async {
                  // update DB
                  return;
                },
                child: const Text('OK'))
          ],
          elevation: 24,
        );
      });
}

class ChangeCurrencyWidget extends StatefulWidget {
  const ChangeCurrencyWidget({
    Key? key,
    required TextEditingController currencyController,
  })  : _currencyController = currencyController,
        super(key: key);

  final TextEditingController _currencyController;

  @override
  State<ChangeCurrencyWidget> createState() => _ChangeCurrencyWidgetState();
}

class _ChangeCurrencyWidgetState extends State<ChangeCurrencyWidget> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_ChangeCurrencyState');
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: DropdownButtonFormField(
        value: widget._currencyController.text,
        items: _buildCurrencySelect(Currency.supportingList),
        onChanged: (String? val) {
          setState(() {
            widget._currencyController.text = val!;
          });
        },
        decoration: const InputDecoration(labelText: 'Currency'),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildCurrencySelect(List<String> list) {
    final selectList = <DropdownMenuItem<String>>[];
    list.sort();

    for (var text in list) {
      var item = DropdownMenuItem(
        value: text,
        child: Text(text.toUpperCase()),
      );

      selectList.add(item);
    }
    return selectList;
  }
}

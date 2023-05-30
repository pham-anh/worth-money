import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_financial/shared/form/_share.dart';
import '../../model/income.dart';
import '../../shared/form/crud.dart';
import '../../shared/menu_bottom.dart';
import 'list.dart';

class IncomeAddPage extends StatefulWidget {
  const IncomeAddPage({this.date, this.amount, this.description, Key? key})
      : super(key: key);

  final String? date;
  final num? amount;
  final String? description;

  @override
  State<IncomeAddPage> createState() => _IncomeAddPageState();
}

class _IncomeAddPageState extends State<IncomeAddPage> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_IncomeAddPageState');
  final _dateController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    // set time to 12:00
    final now = DateTime.now();
    _dateController.text = DateTime(now.year, now.month, now.day, 12)
        .millisecondsSinceEpoch
        .toString();
    _amountController.text =
        widget.amount == null ? '' : widget.amount!.toString();
    _descriptionController.text =
        widget.description == null ? '' : widget.description!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 70.0,
        leading: AppAppBarCancelButton(
          onPress: () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const IncomeListPage()),
                (Route<dynamic> route) => false);
          },
        ),
        automaticallyImplyLeading: false,
        title: const Text('Income add'),
      ),
      bottomNavigationBar: const MenuBottom(menuName: AppMenuItem.income),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppDateField(
                  controller: _dateController,
                ),
                AppNumField(
                  autofocus: true,
                  controller: _amountController,
                  validator: () => validateAmount(_amountController.text),
                  title: 'Amount',
                ),
                AppTextField(
                  maxLength: descriptionMaxLength,
                  autofocus: false,
                  controller: _descriptionController,
                  validator: () =>
                      validateDescription(_descriptionController.text),
                  title: 'Description',
                ),
                const SizedBox(height: 12),
                AppSubmitButton(
                  text: 'Add',
                  isDisabled: _isButtonDisabled,
                  onPressed: _onSubmitButtonClicked,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmitButtonClicked() async {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    // first disable button
    setState(() {
      _isButtonDisabled = true;
    });

    // check validation error
    if (_formKey.currentState!.validate() == false) {
      setState(() {
        _isButtonDisabled = false;
      });
      return;
    }

    // Add income
    var ic = Income(
        amount: num.parse(_amountController.text),
        ts: Timestamp.fromMillisecondsSinceEpoch(
          int.parse(_dateController.text),
        ),
        description: _descriptionController.text);
    var result = await Income.add(ic);

    var message =
        result ? 'The income was added' : 'Failed to add the income';

    // show message
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const IncomeListPage()),
        (Route<dynamic> route) => false);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../model/income.dart';
import '../../shared/form/_share.dart';
import '../../shared/form/crud.dart';
import '../../shared/menu_bottom.dart';
import 'list.dart';

class IncomeUpdatePage extends StatefulWidget {
  const IncomeUpdatePage({
    required this.id,
    required this.ts,
    required this.amount,
    required this.description,
    Key? key,
  }) : super(key: key);

  final String id;
  final Timestamp ts;
  final num amount;
  final String description;

  @override
  _ExpenseDetailPageState createState() => _ExpenseDetailPageState();
}

class _ExpenseDetailPageState extends State<IncomeUpdatePage> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_ExpenseDetailPageState');
  final _dateController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    // date controller text is milliseconds in string
    _dateController.text = widget.ts.millisecondsSinceEpoch.toString();
    _amountController.text = widget.amount.toString();
    _descriptionController.text = widget.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 70.0,
        leading: AppAppBarCancelButton(
          onPress: () {
            ScaffoldMessenger.of(context).clearMaterialBanners();
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const IncomeListPage()),
                (Route<dynamic> route) => false);
          },
        ),
        automaticallyImplyLeading: false,
        title: const Text('Income update'),
      ),
      bottomNavigationBar: const MenuBottom(menuName: AppMenuItem.income),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppDateField(
                  controller: _dateController,
                ),
                AppNumField(
                  autofocus: false,
                  controller: _amountController,
                  validator: () => validateAmount(_amountController.text),
                  title: Icons.monetization_on,
                ),
                AppTextField(
                  maxLength: textInputMaxLength,
                  autofocus: false,
                  controller: _descriptionController,
                  validator: () =>
                      validateTextInput(_descriptionController.text),
                  title: Icons.note_alt,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppDeleteButton(
                        failedMessage: 'Failed to delete the income',
                        successMessage: 'The income was deleted',
                        confirmMessage: 'Do you want to delete this income?',
                        deleteCall: () {
                          return _deleteExpense();
                        },
                      ),
                    ),
                    AppUpdateButton(
                      isDisabled: _isButtonDisabled,
                      onPressed: _onSubmitButtonClicked,
                    ),
                  ],
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

    // Add expense
    Income newIncome = Income(
      amount: num.parse(_amountController.text),
      ts: Timestamp.fromMillisecondsSinceEpoch(
        int.parse(_dateController.text),
      ),
      description: _descriptionController.text,
      id: widget.id,
    );
    var result = await Income.update(newIncome, widget.ts);
    var message = result ? 'Income was updated' : 'Failed to update income';

    // show message
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const IncomeListPage()),
        (Route<dynamic> route) => false);
  }

  Future<void> _deleteExpense() async {
    bool result = await Income.delete(widget.id, widget.ts);
    String message =
        result ? 'The income was deleted' : 'Failed to delete the income';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const IncomeListPage()),
        (Route<dynamic> route) => false);
  }
}

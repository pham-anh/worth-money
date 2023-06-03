import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_financial/model/cate.dart';
import 'package:my_financial/shared/form/_share.dart';
import 'package:my_financial/model/ex.dart';
import 'package:my_financial/shared/form/crud.dart';
import 'package:my_financial/shared/menu_bottom.dart';
import 'package:my_financial/model/importance.dart';
import 'package:my_financial/screen/expense/list.dart';

class ExpenseAddPage extends StatefulWidget {
  const ExpenseAddPage({
    this.date,
    this.amount,
    this.description,
    this.categoryId,
    this.importance,
    required this.start,
    required this.end,
    Key? key,
  }) : super(key: key);

  final String? date;
  final num? amount;
  final String? description;
  final String? categoryId;
  final String? importance;
  // start and end of current list page in case of cancel button

  // any date in the start month
  final DateTime start;
  // any date in the end month
  final DateTime end;

  @override
  State<ExpenseAddPage> createState() => _ExpenseAddPageState();
}

class _ExpenseAddPageState extends State<ExpenseAddPage> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_ExpenseAddPageState');
  final _dateController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _importanceController = TextEditingController();
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
    _categoryController.text =
        widget.categoryId == null ? Category.notSet : widget.categoryId!;
    _importanceController.text =
        widget.importance == null ? Importance.notSet : widget.importance!;
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
                MaterialPageRoute(
                    builder: (context) => ExpenseListPage(
                          start: widget.start,
                          end: widget.end,
                        )),
                (Route<dynamic> route) => false);
          },
        ),
        automaticallyImplyLeading: false,
        title: const Text('Expense add'),
      ),
      bottomNavigationBar: const MenuBottom(menuName: AppMenuItem.expense),
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
                  title: Icons.monetization_on,
                ),
                AppTextField(
                  maxLength: descriptionMaxLength,
                  autofocus: false,
                  controller: _descriptionController,
                  validator: () =>
                      validateDescription(_descriptionController.text),
                  title: Icons.store,
                ),
                AppTextField(
                  maxLength: descriptionMaxLength,
                  autofocus: false,
                  controller: _descriptionController,
                  validator: () =>
                      validateDescription(_descriptionController.text),
                  title: Icons.note_alt,
                ),
                FutureBuilder(
                    future: Category.list(includeNotSet: true),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<Category> list = snapshot.data as List<Category>;
                        return DropdownButtonFormField(
                          value: _categoryController.text,
                          items: buildCategorySelect(list),
                          onChanged: (String? cateId) {
                            setState(() {
                              _categoryController.text = cateId!;
                            });
                          },
                          decoration:
                              const InputDecoration(
                                label: Icon(Icons.category))
                        );
                      }

                      return const Center(child: Text("Loading..."));
                    }),
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

    // Add expense
    var ex = Expense(
        amount: num.parse(_amountController.text),
        categoryId: _categoryController.text,
        ts: Timestamp.fromMillisecondsSinceEpoch(
          int.parse(_dateController.text),
        ),
        description: _descriptionController.text,
        importance: _importanceController.text);
    var result = await Expense.add(ex);

    var message =
        result ? 'The expense was added' : 'Failed to add the expense';

    // show message
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => _getExpenseListPage()),
        (Route<dynamic> route) => false);
  }

  _getExpenseListPage() {
    var now = DateTime.now();
    var exDate =
        DateTime.fromMillisecondsSinceEpoch(int.parse(_dateController.text));
    var nowMonth = DateTime(now.year, now.month, 1, 0);
    var exMonth = DateTime(exDate.year, exDate.month, 1, 0);
    var compare = nowMonth.compareTo(exMonth);

    return ExpenseListPage(
      // in case it comes from the future
      start: compare > 0 ? nowMonth : exMonth,
      end: compare > 0 ? exMonth : nowMonth,
    );
  }
}

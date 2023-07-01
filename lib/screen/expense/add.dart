import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_financial/entity/amount.dart';
import 'package:my_financial/model/cate.dart';
import 'package:my_financial/model/store.dart';
import 'package:my_financial/shared/form/_share.dart';
import 'package:my_financial/model/expense.dart';
import 'package:my_financial/shared/form/form_element.dart';
import 'package:my_financial/shared/menu_bottom.dart';
import 'package:my_financial/screen/expense/list.dart';

class ExpenseAddPage extends StatefulWidget {
  const ExpenseAddPage({
    this.date,
    this.amount,
    this.detail,
    this.category,
    this.store,
    required this.start,
    required this.end,
    Key? key,
  }) : super(key: key);

  final String? date;
  final num? amount;
  final String? detail;
  final String? category;
  final String? store;

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
  final _detailController = TextEditingController();
  final _storeController = TextEditingController();
  int? _categoryIndex;
  bool _isButtonDisabled = false;

  List<Category> categoryList = [];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().millisecondsSinceEpoch.toString();
    _amountController.text =
        widget.amount == null ? '' : widget.amount!.toString();
    _detailController.text = widget.detail == null ? '' : widget.detail!;
    _storeController.text = widget.store == null ? '' : widget.store!;
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                FutureBuilder(
                    future: Store.list(),
                    builder: (context, snapshot) {
                      return Autocomplete(
                        optionsBuilder:
                            (TextEditingValue textEditingValue) async {
                          if (snapshot.hasData && snapshot.data != null) {
                            List<String> storeOptions = snapshot.data!.toList();
                            return storeOptions.where((String option) {
                              return option.contains(
                                  textEditingValue.text.toLowerCase());
                            });
                          }
                          return const Iterable<String>.empty();
                        },
                        fieldViewBuilder: (context, textEditingController,
                                focusNode, onFieldSubmitted) =>
                            TextFormField(
                          controller: textEditingController,
                          decoration:
                              const InputDecoration(label: Icon(Icons.store)),
                          focusNode: focusNode,
                          onFieldSubmitted: (String value) {
                            onFieldSubmitted();
                          },
                        ),
                        onSelected: (String selection) {
                          _storeController.text = selection;
                        },
                      );
                    }),
                AppTextField(
                  maxLength: textInputMaxLength,
                  autofocus: false,
                  controller: _detailController,
                  validator: () => validateTextInput(_detailController.text),
                  title: Icons.note_alt,
                ),
                FutureBuilder(
                    future: Category.list(includeNotSet: true),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        categoryList = snapshot.data as List<Category>;
                        return _buildCategorySelectList(categoryList);
                      }

                      return const Center(child: Text("Loading..."));
                    }),
                const SizedBox(height: 12),
                Center(
                  child: AppSubmitButton(
                    text: 'Add',
                    isDisabled: _isButtonDisabled,
                    onPressed: _onSubmitButtonClicked,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelectList(List<Category> list) {
    Map<int, bool> selected = {};
    list.asMap().forEach((key, value) {
      selected[key] = false;
    });
    List<Widget> children = [];
    list.asMap().forEach((index, value) {
      children.addAll([
        ChoiceChip(
          side: BorderSide(color: Color(value.colorCode), width: 2.0),
          label: Text(value.name),
          labelPadding: const EdgeInsets.all(0),
          padding: const EdgeInsets.all(4),
          selected: _categoryIndex == index,
          onSelected: (bool selected) {
            setState(() {
              _categoryIndex = selected ? index : null;
            });
          },
        ),
        const SizedBox(width: 5.0)
      ]);
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.category),
        Wrap(children: children),
      ],
    );
  }

  void _onSubmitButtonClicked() async {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    // first disable button
    setState(() {
      _isButtonDisabled = true;
    });

    // check validation error
    if (_formKey.currentState!.validate() == false || _categoryIndex == null) {
      setState(() {
        _isButtonDisabled = false;
      });
      return;
    }

    // Add expense
    var ex = ExpenseItem(
      amount: num.parse(_amountController.text),
      date:
          Timestamp.fromMillisecondsSinceEpoch(int.parse(_dateController.text)),
      store: _storeController.text,
      detail: _detailController.text,
      category:
          _categoryIndex == null ? null : categoryList[_categoryIndex!].name,
    );

    var result = await ex.add();
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

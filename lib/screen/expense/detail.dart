import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../model/cate.dart';
import '../../model/ex.dart';
import '../../model/importance.dart';
import '../../shared/form/crud.dart';
import '../../shared/menu_bottom.dart';
import '../../shared/form/_share.dart';
import 'list.dart';

class ExpenseDetailPage extends StatefulWidget {
  const ExpenseDetailPage({
    required this.id,
    required this.ts,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.importance,
    Key? key,
  }) : super(key: key);

  final String id;
  final Timestamp ts;
  final num amount;
  final String description;
  final String categoryId;
  final String importance;

  @override
  _ExpenseDetailPageState createState() => _ExpenseDetailPageState();
}

class _ExpenseDetailPageState extends State<ExpenseDetailPage> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_ExpenseDetailPageState');
  final _dateController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  /// controller for category id
  final _categoryController = TextEditingController();
  final _importanceController = TextEditingController();
  bool _isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    // date controller text is milliseconds in string
    _dateController.text = widget.ts.millisecondsSinceEpoch.toString();
    _amountController.text = widget.amount.toString();
    _descriptionController.text = widget.description;
    _categoryController.text = widget.categoryId;
    _importanceController.text = widget.importance;
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
                MaterialPageRoute(
                    builder: (context) => _getExpenseListPage()),
                (Route<dynamic> route) => false);
          },
        ),
        automaticallyImplyLeading: false,
        title: const Text('Expense detail'),
      ),
      bottomNavigationBar: const MenuBottom(menuName: AppMenuItem.expense),
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
                DropdownButtonFormField(
                  value: _importanceController.text,
                  items: buildImportanceSelect(Importance.list()),
                  onChanged: (String? val) {
                    setState(() {
                      _importanceController.text = val!;
                    });
                  },
                  decoration: const InputDecoration(
                      labelText: 'Importance of spending'),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: FutureBuilder(
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
                                const InputDecoration(labelText: 'Category'),
                          );
                        }

                        return const Center(child: Text("Loading..."));
                      }),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppDeleteButton(
                        failedMessage: 'Failed to delete the expense',
                        successMessage: 'The expense was deleted',
                        confirmMessage: 'Do you want to delete this expense?',
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
    Expense newExpense = Expense(
      amount: num.parse(_amountController.text),
      categoryId: _categoryController.text,
      ts: Timestamp.fromMillisecondsSinceEpoch(
        int.parse(_dateController.text),
      ),
      description: _descriptionController.text,
      id: widget.id,
      importance: _importanceController.text,
    );
    var result = await Expense.update(newExpense, widget.ts);
    var message = result ? 'Expense was updated' : 'Failed to update expense';

    // show message
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => _getExpenseListPage()),
        (Route<dynamic> route) => false);
  }

  Future<void> _deleteExpense() async {
    bool result = await Expense.delete(widget.id, widget.ts);
    String message =
        result ? 'The expense was deleted' : 'Failed to delete the expense';
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

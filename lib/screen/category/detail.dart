import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:my_financial/screen/category/list.dart';
import '../../model/cate.dart';
import '../../shared/app_theme.dart';
import '../../shared/form/form_element.dart';
import '../../shared/menu_bottom.dart';
import '_share.dart';

class CategoryDetailPage extends StatefulWidget {
  const CategoryDetailPage({
    required this.id,
    required this.budget,
    required this.name,
    required this.colorCode,
    Key? key,
  }) : super(key: key);

  final String id;
  final String name;
  final num budget;
  final int colorCode;

  @override
  _CategoryDetailPageState createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_CategoryDetailPageState');
  final _budgetController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isButtonDisabled = false;
  late Color _colorHolder;

  @override
  void initState() {
    super.initState();
    _budgetController.text = widget.budget.toStringAsFixed(0);
    _nameController.text = widget.name;
    _colorHolder = Color(widget.colorCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 70.0,
        leading: AppAppBarCancelButton(
          onPress: () {
            ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const CategoryListPage()),
                (Route<dynamic> route) => false);
          },
        ),
        automaticallyImplyLeading: false,
        title: const Text('Category detail'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              AppTextField(
                maxLength: nameMaxLength,
                autofocus: false,
                controller: _nameController,
                validator: () => validateName(_nameController.text),
                title: Icons.category,
              ),
              AppNumField(
                autofocus: false,
                controller: _budgetController,
                validator: () {
                  return null;
                },
                title: Icons.monetization_on,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Text('Pick a color'),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: (() {
                      showDialog(
                          context: context,
                          builder: ((context) {
                            return AlertDialog(
                              content: BlockPicker(
                                  pickerColor: _colorHolder,
                                  onColorChanged: ((value) {
                                    setState(() {
                                      _colorHolder = value;
                                      Navigator.of(context).pop();
                                    });
                                  })),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel')),
                              ],
                            );
                          }));
                    }),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: _colorHolder,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppDeleteButton(
                      failedMessage: 'Failed to delete the category',
                      successMessage: 'The category was deleted',
                      confirmMessage: 'Do you want to delete this category?',
                      deleteCall: () {
                        return _deleteCategory();
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
      bottomNavigationBar: const MenuBottom(menuName: AppMenuItem.budget),
    );
  }

  Future<void> _deleteCategory() async {
    bool result = await Category.delete(widget.id);
    String message =
        result ? 'The category was deleted' : 'Failed to delete the category';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const CategoryListPage()),
        (Route<dynamic> route) => false);
  }

  void _onSubmitButtonClicked() async {
    ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
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

    // check category name duplicate
    bool duplicated =
        await Category.isDuplicated(_nameController.text, id: widget.id)
            .then((result) => result);
    if (duplicated) {
      ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
        backgroundColor: MyAppTheme.colorBgError,
        content: Text(
          'You already have another category with this name',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        actions: const <Widget>[Text('')],
      ));

      setState(() {
        _isButtonDisabled = false;
      });
      return;
    }
    // update category
    num budget =
        _budgetController.text.isEmpty ? 0 : num.parse(_budgetController.text);
    var result = await Category.update(
        widget.id, _nameController.text, budget, _colorHolder.value);
    var message =
        result ? 'The category was updated' : 'Failed to update the category';

    // show message
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const CategoryListPage()),
        (Route<dynamic> route) => false);
  }
}

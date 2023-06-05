import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../model/cate.dart';
import '../../shared/app_theme.dart';
import '../../shared/form/form_element.dart';
import '../../shared/menu_bottom.dart';
import '_share.dart';
import 'list.dart';

class CategoryAddPage extends StatefulWidget {
  const CategoryAddPage({
    Key? key,
  }) : super(key: key);

  @override
  State<CategoryAddPage> createState() => _CategoryAddPageState();
}

class _CategoryAddPageState extends State<CategoryAddPage> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_CategoryAddState');
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  bool _isButtonDisabled = false;
  Color colorHolder = const Color(Category.defaultColorCode);

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
        title: const Text('Category add'),
      ),
      bottomNavigationBar: const MenuBottom(menuName: AppMenuItem.budget),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppTextField(
                maxLength: nameMaxLength,
                autofocus: true,
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
                                  pickerColor: colorHolder,
                                  onColorChanged: ((value) {
                                    setState(() {
                                      colorHolder = value;
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
                        color: colorHolder,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50)),
                      ),
                    ),
                  ),
                ],
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
    );
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
    bool duplicated = await Category.isDuplicated(_nameController.text)
        .then((result) => result);
    if (duplicated) {
      ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
        backgroundColor: MyAppTheme.colorBgError,
        content: Text(
          'You already have a category with this name',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        actions: const <Widget>[Text('')],
      ));

      setState(() {
        _isButtonDisabled = false;
      });
      return;
    }

    // Add category
    double budget = _budgetController.text.isEmpty
        ? 0
        : double.parse(_budgetController.text);
    var result =
        await Category.add(_nameController.text, budget, colorHolder.value);

    var message = result ? 'Category was added' : 'Failed to add category';

    // show message
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const CategoryListPage()),
        (Route<dynamic> route) => false);
  }
}

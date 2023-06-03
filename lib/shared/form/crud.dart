import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum FormAction { add, update, delete }

var _actionData = <FormAction, Map<String, dynamic>>{
  FormAction.add: {'align': Alignment.center, 'text': 'Add'},
  FormAction.update: {'align': Alignment.centerRight, 'text': 'Update'},
  FormAction.delete: {'align': Alignment.centerLeft, 'text': 'Delete'},
};

class FormActionButton extends StatelessWidget {
  const FormActionButton(
      {this.uuid, required this.action, required this.formKey, Key? key})
      : super(key: key);

  final String? uuid;
  final FormAction action;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _actionData[action]!['align'],
      heightFactor: 2,
      child: ElevatedButton(
          onPressed: () {
            _onPressedValidateProcess(context);
          },
          child: Text(
            _actionData[action]!['text'],
            style: const TextStyle(color: Colors.white),
          )),
    );
  }

  void _onPressedValidateProcess(BuildContext context) {
    if (formKey.currentState!.validate() == false) return;
    Navigator.of(context).pop();
  }
}

class FormActionDeleteButton extends StatelessWidget {
  const FormActionDeleteButton({this.id, Key? key}) : super(key: key);

  final String? id;
  final action = FormAction.delete;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _actionData[action]!['align'],
      heightFactor: 2,
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).colorScheme.error)),
          onPressed: () {
            _onPressedDeleteProcess(context);
          },
          child: Text(
            _actionData[action]!['text'],
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          )),
    );
  }

  void _onPressedDeleteProcess(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Delete?'),
            content: const Text(
              'Do you want to delete this expense record?',
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Expense record deleted!')));
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'))
            ],
            elevation: 24,
          );
        });
  }
}

class AppAppBarCancelButton extends StatelessWidget {
  final void Function()? onPress;
  const AppAppBarCancelButton({
    required this.onPress,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPress,
      child: const Text(
        'Cancel',
        textAlign: TextAlign.right,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final IconData title;
  final TextEditingController controller;
  final String? Function() validator;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool autofocus;

  const AppTextField({
    required this.title,
    required this.controller,
    required this.validator,
    required this.autofocus,
    this.keyboardType,
    this.maxLength,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textCapitalization: TextCapitalization.sentences,
      maxLength: maxLength ?? maxLength,
      autofocus: autofocus,
      controller: controller,
      validator: (val) => validator(),
      decoration: InputDecoration(
        label: Icon(title),
        errorMaxLines: 2,
      ),
      keyboardType: keyboardType ?? keyboardType,
    );
  }
}

class AppNumField extends StatelessWidget {
  final IconData title;
  final TextEditingController controller;
  final String? Function() validator;
  final int? maxLength;
  final bool autofocus;

  const AppNumField({
    required this.title,
    required this.controller,
    required this.validator,
    required this.autofocus,
    this.maxLength,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: maxLength ?? maxLength,
      autofocus: autofocus,
      controller: controller,
      validator: (val) => validator(),
      decoration: InputDecoration(
        label: Icon(title),
        errorMaxLines: 2,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
    );
  }
}

class AppDateField extends StatelessWidget {
  AppDateField({required this.controller, Key? key}) : super(key: key);

  // this controller holds timestamp in milliseconds
  final TextEditingController controller;
  // this internally use if this widget to show the selected date to users
  final _dateToShowController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    if (controller.text.isEmpty) {
      // set today milliseconds
      controller.text = DateTime.now().millisecondsSinceEpoch.toString();
    }

    // set date to show
    _dateToShowController.text = DateFormat.yMMMd().format(
      DateTime.fromMillisecondsSinceEpoch(int.parse(controller.text)),
    );

    return TextFormField(
      controller: _dateToShowController,
      keyboardType: TextInputType.datetime,
      decoration: const InputDecoration(
        label: Icon(Icons.calendar_month_sharp),
      ),
      validator: (val) {
        return (val!.isEmpty) ? 'When did you spend the money?' : null;
      },
      onTap: () async {
        // range 1 year before ~ 1 year later
        var now = DateTime.now();
        DateTime? pickedDate = await showDatePicker(
            context: context, //context of current state
            initialDate: DateTime.now(),
            firstDate: DateTime(now.year - 1, now.month),
            lastDate: DateTime(now.year + 1, now.month));

        if (pickedDate != null) {
          _dateToShowController.text = DateFormat.yMMMd().format(pickedDate);
          // set timestamp in milliseconds to the controller outside. Time must be 12:00
          controller.text =
              DateTime(pickedDate.year, pickedDate.month, pickedDate.day, 12)
                  .millisecondsSinceEpoch
                  .toString();
        }
      },
    );
  }
}

class AppSubmitButton extends StatelessWidget {
  final String text;
  final bool isDisabled;
  final void Function()? onPressed;

  const AppSubmitButton({
    required this.text,
    required this.isDisabled,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isDisabled,
      child: ElevatedButton(
        style: isDisabled
            ? ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.5))
            : null,
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
            ),
          ),
        ),
      ),
    );
  }
}

// TODO: merge with AppSubmitButton
class AppUpdateButton extends StatelessWidget {
  final bool isDisabled;
  final void Function()? onPressed;

  const AppUpdateButton({
    required this.isDisabled,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isDisabled,
      child: ElevatedButton(
        style: isDisabled
            ? ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.5))
            : null,
        onPressed: onPressed,
        child: Text(
          'Update',
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
          ),
        ),
      ),
    );
  }
}

class AppDeleteButton extends StatelessWidget {
  final String confirmMessage;
  final String successMessage;
  final String failedMessage;

  final Future<void> Function() deleteCall;
  const AppDeleteButton({
    required this.deleteCall,
    required this.confirmMessage,
    required this.successMessage,
    required this.failedMessage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  title: const Text('Delete?'),
                  content: Text(confirmMessage),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () async => await deleteCall(),
                        child: const Text('OK'))
                  ],
                  elevation: 24,
                );
              });
        },
        child: Text(
          'Delete',
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
          ),
        ),
      ),
    );
  }
}

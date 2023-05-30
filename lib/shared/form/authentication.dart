import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String? Function() validator;
  const AppTextField({
    required this.title,
    required this.controller,
    required this.validator,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          errorMaxLines: 2,
          labelText: title,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator: (val) => validator(),
      ),
    );
  }
}

class AppObscureTextField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String? Function() validator;
  const AppObscureTextField({
    required this.title,
    required this.controller,
    required this.validator,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        obscureText: true,
        controller: controller,
        decoration: InputDecoration(
          errorMaxLines: 2,
          labelText: title,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator: (val) => validator(),
      ),
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
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5))
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

import 'package:flutter/material.dart';

import '../../shared/form/authentication.dart';

showEmailRegisterDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (_) {
        final emailController = TextEditingController();
        final confirmEmailController = TextEditingController();
        return AlertDialog(
          title: const Text('Register email address'),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppObscureTextField(
                  title: 'Email',
                  controller: emailController,
                  validator: () {
                    return null;
                  },
                ),
                AppObscureTextField(
                    title: 'Confirm email',
                    controller: confirmEmailController,
                    validator: () {
                      return null;
                    }),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Expense record deleted!')));
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'))
          ],
          elevation: 24,
        );
      });
}

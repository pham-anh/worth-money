import 'package:flutter/material.dart';

import '../../shared/form/authentication.dart';

showPasswordChangeDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (_) {
        final passwordController = TextEditingController();
        final newPasswordController = TextEditingController();
        final newPasswordConfirmController = TextEditingController();
        return AlertDialog(
          title: const Text('Change password'),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppObscureTextField(
                  title: 'Current password',
                  controller: passwordController,
                  validator: () {
                    return null;
                  },
                ),
                AppObscureTextField(
                    title: 'New password',
                    controller: newPasswordController,
                    validator: () {
                      return null;
                    }),
                AppObscureTextField(
                    title: 'Confirm new password',
                    controller: newPasswordConfirmController,
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

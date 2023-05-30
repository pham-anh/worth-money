import 'package:flutter/material.dart';
import 'package:my_financial/model/user.dart';
import 'package:my_financial/screen/category/list.dart';

import '../../model/auth/app_auth.dart';
import '../../model/auth/validation.dart';
import '../../screen/login/login.dart';
import '../../shared/widget.dart';
import '../../shared/form/authentication.dart';
import '../../shared/app_theme.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_SignUpPageState');
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _isButtonDisabled = false;
  bool _isPasswordFieldVisible = false;
  String _submitButtonText = 'Next';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Sign up'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
              top: 30.0, right: 45.0, left: 45.0, bottom: 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppTextField(
                title: 'ID',
                controller: _idController,
                validator: _validateId,
              ),
              Visibility(
                visible: _isPasswordFieldVisible,
                child: AppObscureTextField(
                  title: 'Password',
                  controller: _passwordController,
                  validator: _validatePassword,
                ),
              ),
              Visibility(
                visible: _isPasswordFieldVisible,
                child: AppObscureTextField(
                  title: 'Confirm password',
                  controller: _passwordConfirmController,
                  validator: _validateMatchPassword,
                ),
              ),
              AppSubmitButton(
                text: _submitButtonText,
                isDisabled: _isButtonDisabled,
                onPressed: _onSubmitButtonClicked,
              ),
              const LinkToSomePage(
                text: 'Login',
                page: LoginPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateId() {
    String val = _idController.text;
    if (val.isEmpty) {
      _idController.clear();
      return 'Please enter an ID.';
    }
    // validate email
    String? error = UserValidation.isValidId(val);
    if (error != null) {
      return error;
    }

    return null;
  }

  String? _validatePassword() {
    String val = _passwordController.text;
    if (val.isEmpty) {
      return 'Please enter password';
    }
    // validate email
    String? error = UserValidation.isValidPassword(val);
    if (error != null) {
      _passwordController.clear();
      return error;
    }

    return null;
  }

  String? _validateMatchPassword() {
    String val = _passwordController.text;
    String confirmVal = _passwordConfirmController.text;
    // if password field has validation error, then do nothing
    if (_validatePassword() != null) {
      return null;
    }

    // check if empty
    if (confirmVal.isEmpty) {
      return 'Please confirm password';
    }
    // check if 2 passwords match
    if (confirmVal != val) {
      return 'Password doesn\'t match';
    }

    return null;
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

    // if ok and password is not shown, then show password
    if (_isPasswordFieldVisible == false) {
      setState(() {
        _isPasswordFieldVisible = true;
        _submitButtonText = 'Sign up';
        _isButtonDisabled = false;
      });
      return;
    }

    //disable button
    setState(() {
      _isButtonDisabled = true;
    });
    // create user
    var user = AppAuth(
      id: _idController.text,
      password: _passwordController.text,
    );
    String? message = await user.signUp();
    // if error in user creation
    if (message != null) {
      // enable button
      setState(() {
        _isButtonDisabled = false;
      });
      // show error
      ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
        backgroundColor: MyAppTheme.colorBgError,
        content: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        actions: const <Widget>[Text('')],
      ));

      return;
    } else {
      // add user into users collection
      var result = await AppUser.add(_idController.text);
      if (!result) {
        // enable button
        setState(() {
          _isButtonDisabled = false;
        });
        // show error
        ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
          backgroundColor: MyAppTheme.colorBgError,
          content: Text(
            'Something was wrong at our end',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          actions: const <Widget>[Text('')],
        ));

        return;
      }
    }

    // if user created OK then go to dashboard
    //show email verification screen
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CategoryListPage(isFromSignUp: true),
      ),
    );
  }
}

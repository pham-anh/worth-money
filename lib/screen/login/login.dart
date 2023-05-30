import 'package:flutter/material.dart';
import '../../model/auth/app_auth.dart';
import '../../screen/login/sign_up.dart';
import '../../screen/expense/list.dart';
import '../../shared/widget.dart';
import '../../shared/form/authentication.dart';
import '../../shared/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>(debugLabel: 'LoginPageState');
  final idController = TextEditingController();
  final passwordController = TextEditingController();
  bool isButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Login'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 100.0, right: 45.0, left: 45.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppTextField(
                title: 'Login',
                controller: idController,
                validator: _validateId,
              ),
              AppObscureTextField(
                title: 'Password',
                controller: passwordController,
                validator: _validatePassword,
              ),
              AppSubmitButton(
                text: 'Login',
                isDisabled: isButtonDisabled,
                onPressed: _onSubmitButtonClicked,
              ),
              const LinkToSomePage(
                text: 'Sign up',
                page: SignUpPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validatePassword() {
    String val = passwordController.text;
    if (val.isEmpty) {
      passwordController.clear();
      return 'Please enter the password';
    }

    return null;
  }

  void _onSubmitButtonClicked() async {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    // first disable button
    setState(() {
      isButtonDisabled = true;
    });

    // check validation error
    if (formKey.currentState!.validate() == false) {
      setState(() {
        isButtonDisabled = false;
      });
      return;
    }

    // proceed login
    var user = AppAuth(
      id: idController.text,
      password: passwordController.text,
    );
    String? message = await user.login();
    // if login error
    if (message != null) {
      // enable button
      setState(() {
        isButtonDisabled = false;
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
    }

    // proceed to dashboard
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ExpenseListPage(),
      ),
    );
  }

  String? _validateId() {
    String val = idController.text;
    if (val.isEmpty) {
      idController.clear();
      return 'Please enter your ID';
    }

    return null;
  }
}

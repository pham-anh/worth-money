import 'package:flutter/material.dart';
import '../../screen/login/login.dart';
import '../../shared/widget.dart';

class SignUpDone extends StatelessWidget {
  const SignUpDone({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Sign up'),
        ),
        body: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WelcomeBanner(),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mail),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        'An email has been sent to your mail box.\nVerify it to start using app.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  LinkToSomePage(
                    text: 'Login',
                    page: LoginPage(),
                  ),
                ],
              ),
            ),
            TopPageImage()
          ],
        ));
  }
}

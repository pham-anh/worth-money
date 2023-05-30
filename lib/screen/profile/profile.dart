import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_financial/screen/login/login.dart';
import 'package:my_financial/shared/menu_bottom.dart';

import '../../shared/widget.dart';
import '_change_currency.dart';
import '_change_password.dart';
import '_delete_account.dart';
import '_register_email.dart';
import '../../model/user.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // check if we have user logged in
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Settings'),
        ),
        bottomNavigationBar: const MenuBottom(menuName: AppMenuItem.profile),
        body: FutureBuilder(
          future: AppUser.read(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            try {
              if (snapshot.hasError) {
                return const Center(child: Text("Something went wrong"));
              }

              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                Map<String, dynamic> data =
                    snapshot.data as Map<String, dynamic>;
                return Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(data['id']),
                    ),
                    const Divider(),
                    _currencyWidget(context, data['currency']),
                    //const Divider(),
                    //_registerEmailWidget(context),
                    //const Divider(),
                    //_changePasswordWidget(context),
                    const Divider(),
                    _logoutWidget(context),
                    //const Divider(),
                    //_deleteAccountWidget(context),
                    const Divider(),
                    const Expanded(child: Text('Worth Money v1.8.0')),
                    const Expanded(
                      child: InsideImage(),
                    ),
                  ],
                );
                // return Text("Full Name: ${data['full_name']} ${data['last_name']}");

              }
            } catch (e) {
              FirebaseAuth.instance.signOut();
              return const Center(
                  child: Text('Something went wrong at our end'));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ));
  }

  ListTile _currencyWidget(BuildContext context, String currency) {
    return ListTile(
      leading: Icon(
        Icons.money,
        color: Theme.of(context).primaryColor,
      ),
      title: InkWell(
        onTap: () {
          showCurrencyDialog(context, currency, "Change the currency");
        },
        child: Text(
          currency.toUpperCase(),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  ListTile _registerEmailWidget(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.email,
        color: Theme.of(context).primaryColor,
      ),
      title: InkWell(
        onTap: () {
          return;
          showEmailRegisterDialog(context);
        },
        child: Text(
          'Register email address',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      subtitle: const Text('An email can help reset password.\nComing soon...'),
    );
  }

  ListTile _logoutWidget(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.logout,
        color: Theme.of(context).primaryColor,
      ),
      title: InkWell(
        onTap: () async {
          FirebaseAuth.instance.signOut();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false);
        },
        child: Text(
          'Logout',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  ListTile _deleteAccountWidget(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.person_off_sharp,
        color: Theme.of(context).primaryColor,
      ),
      title: InkWell(
        onTap: () {
          showAccountDeleteDialog(context);
        },
        child: Text(
          'Delete your account',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      subtitle: const Text('Coming soon...'),
    );
  }

  ListTile _changePasswordWidget(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.password,
        color: Theme.of(context).primaryColor,
      ),
      title: InkWell(
        onTap: () {
          return;
          showPasswordChangeDialog(context);
        },
        child: Text(
          'Change password',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      subtitle: const Text('Coming soon...'),
    );
  }
}

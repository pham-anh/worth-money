import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeBanner extends StatelessWidget {
  const WelcomeBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        'Welcome!',
        style: GoogleFonts.oswald(
            fontSize: 25.0, color: Theme.of(context).primaryColor),
      ),
    );
  }
}

class LinkToSomePage extends StatelessWidget {
  final String text;
  final Widget page;
  const LinkToSomePage({
    required this.text,
    required this.page,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(text),
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => page,
        ));
      },
    );
  }
}

class TopPageImage extends StatelessWidget {
  const TopPageImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      //child: _loginForm(context),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/top-page.jpg'),
          fit: BoxFit.fitWidth,
          alignment: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class InsideImage extends StatelessWidget {
  const InsideImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      //child: _loginForm(context),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/coins.jpg'),
          fit: BoxFit.fitWidth,
          alignment: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

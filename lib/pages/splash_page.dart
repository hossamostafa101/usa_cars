import 'dart:async';

import 'package:talabatfresh/pages/RegisterPage.dart';
import 'package:flutter/material.dart';
import 'package:talabatfresh/widgets/RootShell.dart';
import '../data/local/cache_helper.dart';
import 'home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  var token = '';
  var hasToken = false;

  @override
  void initState() {
    super.initState();
    hasToken = CacheHelper.isHasKey(key: 'token');
    if (hasToken) {
      Timer(Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RootShell()),
        );
      });
    }else{
      Timer(Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RegisterPage()),
        );
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/otlobha_logo_a.png', // Your app logo
              width: 200,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Color(0xff10512d),), // Loading animation
          ],
        ),
      ),
    );
  }

  OutlineInputBorder textFieldBorder() {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(15.0)),
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.5),
        width: 1.0,
      ),
    );
  }
}

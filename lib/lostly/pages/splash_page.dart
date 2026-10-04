import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_profile_app/app_language.dart';

import 'home_page.dart';
import 'signup_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.appLanguage});

  final AppLanguage appLanguage;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _goNext();
  }

  Future<void> _goNext() async {
    User? user;

    // Keep the splash visible for the same 6 seconds as before, while
    // Firebase Auth restores a previously signed-in session.
    await Future.wait<void>([
      Future<void>.delayed(const Duration(seconds: 7)),
      FirebaseAuth.instance
          .authStateChanges()
          .first
          .then((value) => user = value)
          .catchError((_) => null),
    ]);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => user != null
            ? HomePage(appLanguage: widget.appLanguage)
            : SignUpPage(appLanguage: widget.appLanguage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset(
          'assets/avatar7.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

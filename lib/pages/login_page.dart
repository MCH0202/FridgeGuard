import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'fridge_guard_main_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providers: [EmailAuthProvider()],
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => FridgeGuardMainPage()),
          );
        }),
      ],
    );
  }
}

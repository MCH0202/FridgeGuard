import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'fridge_guard_main_page.dart';

// Login page that uses FirebaseUI to handle email/password sign-in
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providers: [EmailAuthProvider()], // Enable email/password authentication

      actions: [
        // After successful sign-in, navigate to the main application page
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

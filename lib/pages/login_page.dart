import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'fridge_guard_main_page.dart';
import 'login_page.dart'; // Import your own login page

// Login page that uses FirebaseUI to handle email/password sign-in and sign-up
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providers: [
        EmailAuthProvider(), // Enable email/password authentication
      ],
      actions: [
        // After successful account creation (sign-up), show a dialog and then return to login screen
        AuthStateChangeAction<UserCreated>((context, state) async {
          await showDialog(
            context: context,
            barrierDismissible: false, // User must tap button to dismiss
            builder: (context) => AlertDialog(
              title: const Text('Registration Successful'),
              content: const Text('Your account has been created. Please log in.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );

          // After closing the dialog, replace the current screen with LoginPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }),
        
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

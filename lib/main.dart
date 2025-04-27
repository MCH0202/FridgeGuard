import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/fridge_guard_main_page.dart';
import 'providers/temperature_provider.dart';
import 'providers/food_list_provider.dart';
import 'providers/theme_provider.dart';
import 'package:openfoodfacts/openfoodfacts.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // setting the account info for openfoodapi
  OpenFoodAPIConfiguration.userAgent = UserAgent(
    name: 'FridgeGuard',
    version: '1.0.0',
    system: 'Flutter',
  );
  OpenFoodAPIConfiguration.globalLanguages = [OpenFoodFactsLanguage.ENGLISH];
  OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.UNITED_KINGDOM;

  runApp(const FridgeGuardApp());
}

class FridgeGuardApp extends StatelessWidget {
  const FridgeGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TemperatureProvider()),
        ChangeNotifierProvider(create: (_) => FoodListProvider()),
      ],
      child: Builder(
        
        builder: (context) {
          final themeProvider = context.watch<ThemeProvider>();
          return MaterialApp(
            title: 'FridgeGuard',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeProvider.themeMode, 
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<auth.User?>(
      stream: auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const FridgeGuardMainPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
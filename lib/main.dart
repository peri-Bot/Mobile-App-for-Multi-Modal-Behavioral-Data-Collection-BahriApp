import 'package:bahri_app/screens/TeamPages/NoTeamPage.dart';
import 'package:bahri_app/screens/base_screen.dart';
import 'package:bahri_app/screens/home_screen.dart';
import 'package:bahri_app/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:bahri_app/screens/login_screen.dart';

import 'services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const BahriApp());
}

class BahriApp extends StatelessWidget {
  const BahriApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bahri App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(
        //     seedColor: Colors.blue,
        //     brightness: Brightness.light,
        //     dynamicSchemeVariant: DynamicSchemeVariant.rainbow),
        // useMaterial3: true,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WelcomeScreen(),
    );
  }
}

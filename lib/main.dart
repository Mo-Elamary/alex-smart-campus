import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('schedules');
  final prefs = await SharedPreferences.getInstance();
  try {
    await Firebase.initializeApp();
    runApp(CampusApp(prefs: prefs));
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Firebase is not configured. Follow the setup instructions in README.md.\n\n$e',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CampusApp extends StatefulWidget {
  const CampusApp({super.key, required this.prefs});
  final SharedPreferences prefs;
  @override
  State<CampusApp> createState() => _CampusAppState();
}

class _CampusAppState extends State<CampusApp> {
  late bool dark = widget.prefs.getBool('darkMode') ?? false;
  void setDark(bool value) {
    setState(() => dark = value);
    widget.prefs.setBool('darkMode', value);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Alex Smart Campus',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff006d77)),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xfff4f8f7),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    darkTheme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff76d5ce),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    ),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    home: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data == null
            ? const AuthScreen()
            : HomeScreen(
                user: snapshot.data!,
                dark: dark,
                onDarkChanged: setDark,
              );
      },
    ),
  );
}

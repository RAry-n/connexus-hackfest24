import 'package:connexus/pages/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      initialRoute: '/home_screen',
      routes: {
        // '/chat': (context) => const Chat(),
        '/home_screen': (context) => const HomeScreen(),
        // '/get_started': (context) => const GetStartedScreen(),
        // '/register': (context) => const RegisterScreen(),
        // '/conversation': (context) => const ConversationPage(),
      },
      debugShowCheckedModeBanner: false,
      // navigatorKey: navigatorKey,
    );
  }
}
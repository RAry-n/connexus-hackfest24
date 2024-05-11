import 'package:connexus/pages/chat.dart';
import 'package:connexus/pages/conversation.dart';
import 'package:connexus/pages/get_started_screen.dart';
import 'package:connexus/pages/home_screen.dart';
import 'package:connexus/pages/join_with_code_screen.dart';
import 'package:connexus/pages/new_meeting_screen.dart';
import 'package:connexus/pages/register_screen.dart';
import 'package:connexus/provider/my_auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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

    return ChangeNotifierProvider<MyAuthProvider>(
      create: (_) => MyAuthProvider(),
      child: const MaterialApp(
        home: MyAppHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyAppHomePage extends StatefulWidget {
  const MyAppHomePage({super.key});

  @override
  State<MyAppHomePage> createState() => _MyAppHomePageState();
}

class _MyAppHomePageState extends State<MyAppHomePage> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container();
    }

    final ap = Provider.of<MyAuthProvider>(context);
    final bool loggedIn = ap.isSignedIn;

    return MaterialApp(
      initialRoute: loggedIn ? '/home_screen' : '/get_started',
      routes: {
        '/chat': (context) => const Chat(),
        '/home_screen': (context) => const HomeScreen(),
        '/get_started': (context) => const GetStartedScreen(),
        '/register': (context) => const RegisterScreen(),
        '/conversation': (context) => const ConversationScreen(),
        '/join_with_code': (context) => const JoinWithCodeScreen(),
        '/new_meeting': (context) => const NewMeetingScreen(),
      },
      debugShowCheckedModeBanner: false,
      // navigatorKey: navigatorKey,
    );
  }

  Future<void> _initializeApp() async {
    final ap = Provider.of<MyAuthProvider>(context, listen: false);
    await ap.checkSignIn();
    setState(() {
      _isInitialized = true;
    });
  }
}

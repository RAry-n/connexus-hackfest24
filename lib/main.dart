

import 'package:agora_uikit/agora_uikit.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:camera/camera.dart';
import 'package:connexus/pages/chat.dart';
import 'package:connexus/pages/conversation.dart';
import 'package:connexus/pages/get_started_screen.dart';
import 'package:connexus/pages/home_screen.dart';
import 'package:connexus/pages/join_with_code_screen.dart';
import 'package:connexus/pages/new_meeting_screen.dart';
import 'package:connexus/pages/register_screen.dart';
import 'package:connexus/pages/sign_language_screen.dart';
import 'package:connexus/provider/my_auth_provider.dart';
import 'package:connexus/provider/notiification_service.dart';
import 'package:connexus/widgets/loading_widget.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'constants/utils.dart';
import 'firebase_options.dart';
List<CameraDescription>? cameras;

Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage remoteMessage) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationServices.showNotification(remoteMessage: remoteMessage);
  await callsCollection.doc(remoteMessage.data['id']).update(
    {
      'connected': true,
    },
  );
}

Future<void> _requestContactsPermission() async {
  final PermissionStatus status = await Permission.contacts.request();
  if (status == PermissionStatus.granted) {
    getAllContacts();
  }
}

getAllContacts() async {
  List<Contact> contactsList = await ContactsService.getContacts();
  // setState(() {
  contacts = contactsList;
  // });
}


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await _requestContactsPermission();
  await NotificationServices.initializeNotification();
  await AwesomeNotifications().isNotificationAllowed().then(
          (isAllowed) {
        if(!isAllowed) {
          AwesomeNotifications().requestPermissionToSendNotifications(
              channelKey: "high_importance_channel"
          );
        }
      }
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen(
          (RemoteMessage remoteMessage) async {
        await NotificationServices.showNotification(remoteMessage: remoteMessage);
        print(remoteMessage.data['id']);
        await callsCollection.doc(remoteMessage.data['id']).update(
            {
              'connected': true,
            }
        );
      }
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
      return const LoadingWidget();
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
        '/sign_language': (context) => const SignLanguageScreen(),
      },
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
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

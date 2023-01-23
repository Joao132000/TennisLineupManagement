import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:line_up/firebase_options.dart';
import 'package:line_up/handlers/signin_signout.dart';
import 'package:line_up/handlers/utils.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: Utils.messengerKey,
      title: 'Line_Up',
      theme: ThemeData.dark(),
      home: const SignInSignOut(),
    );
  }
}

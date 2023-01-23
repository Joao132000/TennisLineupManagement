import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_up/handlers/auth_page.dart';
import 'package:line_up/screens/main_coach.dart';
import 'package:line_up/screens/main_player.dart';

class SignInSignOut extends StatefulWidget {
  const SignInSignOut({Key? key}) : super(key: key);

  @override
  State<SignInSignOut> createState() => _SignInSignOutState();
}

class _SignInSignOutState extends State<SignInSignOut> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.data?.displayName.toString() == '2') {
              return MainPlayer();
            } else if (snapshot.data?.displayName.toString() == '1') {
              return const MainCoach();
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Something went Wrong'));
            } else {
              return const AuthPage();
            }
          }),
    );
  }
}

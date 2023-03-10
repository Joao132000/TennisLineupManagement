import 'package:flutter/material.dart';
import 'package:line_up/screens/sign_in.dart';
import 'package:line_up/screens/sign_up.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) => isLogin
      ? SignIn(onClickedSignUp: toggle)
      : SignUp(onClickedSignIn: toggle);

  void toggle()=>setState(() {
    isLogin = !isLogin;
  });
}

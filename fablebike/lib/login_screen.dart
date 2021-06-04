import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/authentication_service.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'signup.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  loginWithFB() async {
    final result = await FacebookAuth.instance.login();
    print(result.status);
    if (result.status == LoginStatus.success) {
      final AccessToken acessToken = result.accessToken;
      final userData = await FacebookAuth.instance.getUserData();

      print(userData.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            controller: userController,
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: 'Utilizator'),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            controller: passwordController,
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: 'Parola'),
          ),
        ),
        Padding(padding: EdgeInsets.all(16.0)),
        Text('Not signed'),
        ElevatedButton(
            onPressed: () {
              print('wtf');
              context.read<AuthenticationService>().signIn(
                  email: userController.text,
                  password: passwordController.text);
            },
            child: Text('Sign In')),
        ElevatedButton(
            onPressed: () {
              loginWithFB();
            },
            child: Text('Login with facebook')),
        ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, SignUpScreen.route);
            },
            child: Text('Sign Up'))
      ],
    ));
  }
}

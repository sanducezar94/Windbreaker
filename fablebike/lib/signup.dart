import 'package:flutter/material.dart';
import 'package:fablebike/pages/home.dart';
import 'package:provider/provider.dart';
import 'services/authentication_service.dart';
import './pages/map.dart';

class SignUpScreen extends StatefulWidget {
  static const route = '/signup';
  @override
  _SignUpScreen createState() => _SignUpScreen();
}

class _SignUpScreen extends State<SignUpScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            controller: emailController,
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: 'Email'),
          ),
        ),
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
        ElevatedButton(
            onPressed: () {
              context
                  .read<AuthenticationService>()
                  .signUp(
                      user: userController.text,
                      email: emailController.text,
                      password: passwordController.text)
                  .then((result) {
                if (result) {
                  Navigator.pop(context);
                }
              });
            },
            child: Text('Create')),
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Back')),
      ],
    ));
  }
}

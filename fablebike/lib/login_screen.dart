import 'package:fablebike/facebook_signup.dart';
import 'package:fablebike/models/user.dart';
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
  final formKey = GlobalKey<FormState>();

  loginWithFB(BuildContext context) async {
    final result = await FacebookAuth.instance.login(loginBehavior: LoginBehavior.nativeWithFallback);
    if (result.status == LoginStatus.success) {
      final userData = await FacebookAuth.instance.getUserData();
      final facebookUser = FacebookUser.fromJson(userData);

      var reponse = await context.read<AuthenticationService>().signIn(email: facebookUser.email, password: "");

      if (!reponse.success) {
        Navigator.pushNamed(context, FacebookSignUpScreen.route, arguments: facebookUser);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Campul 'Utilizator' nu poate fi gol.";
                      }
                      return null;
                    },
                    controller: userController,
                    decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Utilizator'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Campul 'Parola' nu poate fi gol.";
                      }
                      return null;
                    },
                    controller: passwordController,
                    decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Parola'),
                  ),
                ),
                Padding(padding: EdgeInsets.all(16.0)),
                Text('Not signed'),
                ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState.validate()) {
                        var result = context.read<AuthenticationService>().signIn(email: userController.text, password: passwordController.text);
                      }
                    },
                    child: Text('Sign In')),
                ElevatedButton(
                    onPressed: () {
                      loginWithFB(context);
                    },
                    child: Text('Login with facebook')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, SignUpScreen.route);
                    },
                    child: Text('Sign Up')),
                ElevatedButton(
                    onPressed: () async {
                      var result = await context.read<AuthenticationService>().signInGuest();
                    },
                    child: Text('Continua ca vizitator'))
              ],
            )));
  }
}

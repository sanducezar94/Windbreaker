import 'package:fablebike/facebook_signup.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/services/database_service.dart';
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
        body: Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0),
            child: ListView(children: [
              SizedBox(height: 35.0),
              Container(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      width: 180,
                      height: 180,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.0),
              Container(
                  child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 0, 0, 0),
                    child: Row(children: [
                      Text(
                        'Logare',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.start,
                      )
                    ]),
                  ),
                  SizedBox(height: 10.0),
                  Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Campul 'Utilizator' nu poate fi gol.";
                              }
                              return null;
                            },
                            controller: userController,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                                hintText: 'Introdu e-mail'),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Campul 'Parola' nu poate fi gol.";
                              }
                              return null;
                            },
                            controller: passwordController,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock_outlined),
                                border: OutlineInputBorder(borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                                hintText: 'Parola'),
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            child: Container(
                                height: 60,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(10, 54),
                                        ),
                                        onPressed: () async {
                                          if (formKey.currentState.validate()) {
                                            context.read<AuthenticationService>().signIn(email: userController.text, password: passwordController.text);
                                          }
                                        },
                                        child: Text('Logare'))
                                  ],
                                ))),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            child: Text(
                              'Sau logheaza-te cu',
                              style: TextStyle(color: Colors.black26, fontSize: 16),
                            )),
                        SizedBox(height: 15),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            loginWithFB(context);
                                          },
                                          child: Image.asset(
                                            'assets/images/facebook.png',
                                            fit: BoxFit.contain,
                                            height: 36,
                                          ),
                                        ),
                                        flex: 1),
                                    Expanded(
                                        child: InkWell(
                                            onTap: () {},
                                            child: Image.asset(
                                              'assets/images/search.png',
                                              fit: BoxFit.contain,
                                              height: 36,
                                            )),
                                        flex: 1),
                                    Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            await context.read<AuthenticationService>().signInGuest();
                                          },
                                          child: Image.asset(
                                            'assets/images/user (1).png',
                                            fit: BoxFit.contain,
                                            height: 36,
                                          ),
                                        ),
                                        flex: 1)
                                  ],
                                )
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 24),
                            child: Container(
                                child: Column(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    try {
                                      var db = await DatabaseService().database;
                                      await db.delete('usericon', where: 'name = ?', whereArgs: ['profile_pic_registration']);
                                    } on Exception {
                                      Navigator.pushNamed(context, SignUpScreen.route);
                                    }

                                    Navigator.pushNamed(context, SignUpScreen.route);
                                  },
                                  child: Text('Creeaza-ti Contul!', style: TextStyle(color: Colors.green)),
                                )
                              ],
                            ))),
                      ],
                    ),
                  )
                ],
              ))
            ])));
  }
}

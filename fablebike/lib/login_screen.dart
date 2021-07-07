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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;

    double smallPadding = height * 0.0125;
    double bigPadding = height * 0.05;
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: SafeArea(
              child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    height: height + 80,
                    child: Column(children: [
                      SizedBox(
                        height: bigPadding > 35 ? 10 : bigPadding,
                      ),
                      Expanded(
                        flex: 1,
                        child: Image.asset('assets/images/logo.png', width: 300, height: 300, fit: BoxFit.contain),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(10.0, 0, 0, 10.0),
                                  child: Row(children: [
                                    Text(
                                      'Logare',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).accentColor),
                                      textAlign: TextAlign.start,
                                    )
                                  ]),
                                ),
                                Form(
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  key: formKey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: smallPadding, vertical: smallPadding),
                                        child: Material(
                                          shadowColor: Theme.of(context).accentColor.withOpacity(0.2),
                                          elevation: 10.0,
                                          borderRadius: const BorderRadius.all(const Radius.circular(16.0)),
                                          child: TextFormField(
                                            controller: userController,
                                            decoration: InputDecoration(
                                                fillColor: Colors.white,
                                                filled: true,
                                                prefixIcon: Icon(Icons.email_outlined),
                                                border: OutlineInputBorder(
                                                    borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                                                hintText: 'Introdu e-mail'),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.symmetric(horizontal: smallPadding, vertical: smallPadding),
                                          child: Material(
                                            child: TextFormField(
                                              controller: passwordController,
                                              obscureText: true,
                                              decoration: InputDecoration(
                                                  prefixIcon: Icon(Icons.lock_outlined),
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  border: OutlineInputBorder(
                                                      borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                                                  hintText: 'Parola'),
                                            ),
                                            shadowColor: Theme.of(context).accentColor.withOpacity(0.2),
                                            borderRadius: const BorderRadius.all(const Radius.circular(16.0)),
                                            elevation: 10.0,
                                          )),
                                      SizedBox(height: smallPadding * 2),
                                      Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: smallPadding),
                                          child: Container(
                                              child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    minimumSize: Size(10, 54),
                                                    shadowColor: Theme.of(context).accentColor.withOpacity(0.2),
                                                    elevation: 10.0,
                                                  ),
                                                  onPressed: () async {
                                                    if (formKey.currentState.validate()) {
                                                      context
                                                          .read<AuthenticationService>()
                                                          .signIn(email: userController.text, password: passwordController.text);
                                                    }
                                                  },
                                                  child: Text('Logare'))
                                            ],
                                          ))),
                                      Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: smallPadding * 2),
                                          child: Text(
                                            'Sau logheaza-te cu',
                                            style: TextStyle(color: Colors.black26, fontSize: 16),
                                          )),
                                      SizedBox(height: 15),
                                      Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: smallPadding),
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
                                                          height: bigPadding * 1.2,
                                                        ),
                                                      ),
                                                      flex: 1),
                                                  Expanded(
                                                      child: InkWell(
                                                          onTap: () {},
                                                          child: Image.asset(
                                                            'assets/images/search.png',
                                                            fit: BoxFit.contain,
                                                            height: bigPadding * 1.2,
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
                                                          height: bigPadding * 1.2,
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
                                                child: Text('Creeaza-ti Contul!', style: TextStyle(color: Color.fromRGBO(99, 157, 78, 1))),
                                              )
                                            ],
                                          ))),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 25.0)),
                      )
                    ]),
                  )),
            )));
  }
}

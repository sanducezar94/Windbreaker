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
  final flexer = 5;

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
        resizeToAvoidBottomInset: false,
        body: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: SafeArea(
                child: Container(
              height: height + 80,
              child: Column(children: [
                Spacer(flex: 1),
                Expanded(
                  flex: 5,
                  child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                ),
                Spacer(
                  flex: 1,
                ),
                Expanded(
                  flex: 13,
                  child: Padding(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10.0, 0, 0, 10.0),
                                child: Row(children: [
                                  Text(
                                    'Logare',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).accentColor),
                                    textAlign: TextAlign.start,
                                  )
                                ]),
                              ),
                              flex: 1),
                          Expanded(
                            child: Form(
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              key: formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: smallPadding),
                                        child: Material(
                                          shadowColor: Theme.of(context).accentColor.withOpacity(0.2),
                                          elevation: 10.0,
                                          borderRadius: const BorderRadius.all(const Radius.circular(16.0)),
                                          child: TextFormField(
                                            controller: userController,
                                            decoration: InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(vertical: 1.0),
                                                fillColor: Colors.white,
                                                hintStyle: Theme.of(context).textTheme.headline2,
                                                filled: true,
                                                prefixIcon: Icon(Icons.email_outlined),
                                                border: OutlineInputBorder(
                                                    borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                                                hintText: 'Introdu e-mail'),
                                          ),
                                        ),
                                      ),
                                      flex: flexer),
                                  Spacer(
                                    flex: 2,
                                  ),
                                  Expanded(
                                      child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: smallPadding),
                                          child: Material(
                                            child: TextFormField(
                                              controller: passwordController,
                                              obscureText: true,
                                              decoration: InputDecoration(
                                                  contentPadding: EdgeInsets.symmetric(vertical: 1.0),
                                                  hintStyle: Theme.of(context).textTheme.headline2,
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
                                      flex: flexer),
                                  Spacer(
                                    flex: 3,
                                  ),
                                  Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                        child: Container(
                                            child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
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
                                                  child: Text(
                                                    'Logare',
                                                    style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                                                  )),
                                              flex: 1,
                                            )
                                          ],
                                        ))),
                                    flex: (flexer * 1.1).toInt(),
                                  ),
                                  Spacer(
                                    flex: 2,
                                  ),
                                  Expanded(
                                      child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8),
                                          child: Text(
                                            'Sau logheaza-te cu',
                                            style: Theme.of(context).textTheme.headline2,
                                          )),
                                      flex: flexer),
                                  Spacer(
                                    flex: 1,
                                  ),
                                  Expanded(
                                      child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8),
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
                                      flex: flexer),
                                  Spacer(flex: 2),
                                  Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                flex: 1,
                                                child: Wrap(
                                                  alignment: WrapAlignment.center,
                                                  children: [
                                                    Text('Nu am cont.', style: TextStyle(fontSize: 14, color: Theme.of(context).accentColor.withOpacity(0.56))),
                                                    InkWell(
                                                      child: Text(' Creeaza unul!', style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor)),
                                                      onTap: () async {
                                                        try {
                                                          var db = await DatabaseService().database;
                                                          await db.delete('usericon', where: 'name = ?', whereArgs: ['profile_pic_registration']);
                                                        } on Exception {
                                                          Navigator.pushNamed(context, SignUpScreen.route);
                                                        }

                                                        Navigator.pushNamed(context, SignUpScreen.route);
                                                      },
                                                    )
                                                  ],
                                                ))
                                          ],
                                        ),
                                      ),
                                      flex: 5),
                                  Spacer(
                                    flex: 1,
                                  )
                                ],
                              ),
                            ),
                            flex: 10,
                          )
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 5.0)),
                )
              ]),
            ))));
  }
}

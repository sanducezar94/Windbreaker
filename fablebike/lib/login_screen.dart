import 'package:fablebike/pages/sections/rounded_button.dart';
import 'package:fablebike/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import 'package:fablebike/constants/language.dart';
import 'package:fablebike/oauth_signup.dart';
import 'package:fablebike/models/user.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

import 'models/service_response.dart';
import 'services/authentication_service.dart';
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
  final flexer = 7;

  loginWithFB(BuildContext context) async {
    Loader.show(context, progressIndicator: CircularProgressIndicator(color: Theme.of(context).primaryColor));
    final result = await FacebookAuth.instance.login(loginBehavior: LoginBehavior.nativeWithFallback);
    if (result.status == LoginStatus.success) {
      print(result.accessToken.token);
      print(result.accessToken.applicationId);
      final userData = await FacebookAuth.instance.getUserData();
      final facebookUser = FacebookUser.fromJson(userData);

      var reponse =
          await context.read<AuthenticationService>().signInFacebook(email: facebookUser.email, password: "", facebookToken: result.accessToken.token);

      if (!reponse.success) {
        var oAuthUser = OAuthUser("", facebookUser.email, facebookUser.photo);
        oAuthUser.iconUrl = userData['picture']['data']['url'];
        oAuthUser.isFacebook = true;
        oAuthUser.token = result.accessToken.token;
        Loader.hide();
        Navigator.pushNamed(context, OAuthRegisterScreen.route, arguments: oAuthUser);
      }
    } else {
      Loader.hide();
    }
  }

  loginWithGoogle() async {
    var googleSignIn = GoogleSignIn(
      clientId: '978264265363-2frhghmprbss8p6fpdf90i4edqfpl3if.apps.googleusercontent.com',
    );
    Loader.show(context, progressIndicator: CircularProgressIndicator(color: Theme.of(context).primaryColor));

    try {
      var googleAccount = await googleSignIn.signIn().timeout(const Duration(seconds: 25));
      var test = await googleAccount.authentication;
      print(test.accessToken);
      if (googleAccount == null) {
        Loader.hide();
        return;
      }

      var response = await context.read<AuthenticationService>().signIn(email: googleAccount.email, password: "");
      if (!response.success) {
        var oAuthUser = OAuthUser("", googleAccount.email, googleAccount.photoUrl);
        oAuthUser.iconUrl = googleAccount.photoUrl;
        oAuthUser.isGoogle = true;
        Loader.hide();
        Navigator.pushNamed(context, OAuthRegisterScreen.route, arguments: oAuthUser);
      } else {
        Loader.hide();
      }
    } on Exception catch (e) {
      Loader.hide();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;
    var formFieldStyle = TextStyle(fontFamily: 'OpenSans', fontWeight: FontWeight.w700, color: Theme.of(context).accentColor.withOpacity(0.64), fontSize: 18);

    double smallPadding = height * 0.0125;
    double bigPadding = height * 0.05;

    var loginForm = SafeArea(
        child: Container(
      height: height + 80,
      child: Stack(children: [
        Positioned(
          top: height * 0.1,
          left: width * 0.3,
          child: Opacity(
            opacity: 0.075,
            child: Container(
              height: height * 0.9,
              child: Image.asset('assets/icons/bicicleta.png'),
            ),
          ),
        ),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(children: [
              Spacer(flex: 1),
              Expanded(
                flex: 6,
                child: Image.asset('assets/images/logo_cbd.png', fit: BoxFit.cover),
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
                                  context.read<LanguageManager>().login,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'OpenSans', fontSize: 18, color: Theme.of(context).accentColor),
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
                                        elevation: 12.0,
                                        borderRadius: const BorderRadius.all(const Radius.circular(16.0)),
                                        child: TextFormField(
                                          textAlignVertical: TextAlignVertical.bottom,
                                          style: formFieldStyle,
                                          controller: userController,
                                          decoration: InputDecoration(
                                              hintStyle: formFieldStyle,
                                              fillColor: Colors.white,
                                              filled: true,
                                              prefixIcon: Icon(Icons.email_outlined),
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                                              hintText: context.read<LanguageManager>().email),
                                        ),
                                      ),
                                    ),
                                    flex: flexer),
                                Spacer(
                                  flex: 3,
                                ),
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: smallPadding),
                                        child: Material(
                                          child: Stack(
                                            children: [
                                              TextFormField(
                                                controller: passwordController,
                                                style: formFieldStyle,
                                                obscureText: true,
                                                textAlignVertical: TextAlignVertical.bottom,
                                                decoration: InputDecoration(
                                                    hintStyle: formFieldStyle,
                                                    prefixIcon: Icon(Icons.lock_outlined),
                                                    fillColor: Colors.white,
                                                    filled: true,
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                                                    hintText: context.read<LanguageManager>().password),
                                              ),
                                              Align(
                                                child: Padding(
                                                  child: InkWell(
                                                    child: Text('Am uitat parola'),
                                                    onTap: () {
                                                      Navigator.pushNamed(context, OtpScreen.route);
                                                    },
                                                  ),
                                                  padding: EdgeInsets.only(right: 10, top: 10, bottom: 10),
                                                ),
                                                alignment: Alignment.centerRight,
                                              )
                                            ],
                                          ),
                                          shadowColor: Theme.of(context).accentColor.withOpacity(0.3),
                                          borderRadius: const BorderRadius.all(const Radius.circular(16.0)),
                                          elevation: 15.0,
                                        )),
                                    flex: flexer),
                                Spacer(
                                  flex: 4,
                                ),
                                Expanded(
                                  child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      child: RoundedButtonWidget(
                                        inactive: false,
                                        child: Text(
                                          "Logare",
                                          style: TextStyle(
                                            fontSize: 18,
                                            // fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        width: width,
                                        onpressed: () async {
                                          if (userController.text.isEmpty || passwordController.text.isEmpty) return;
                                          if (formKey.currentState.validate()) {
                                            Loader.show(context, progressIndicator: CircularProgressIndicator(color: Theme.of(context).primaryColor));
                                            var response = await context
                                                .read<AuthenticationService>()
                                                .signIn(email: userController.text, password: passwordController.text);
                                            Loader.hide();
                                            if (!response.success) {
                                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                  duration: const Duration(milliseconds: 1500),
                                                  backgroundColor: Theme.of(context).errorColor,
                                                  content: Container(
                                                    height: 32,
                                                    width: 999,
                                                    child: Align(
                                                      alignment: Alignment.center,
                                                      child: Text(response.message),
                                                    ),
                                                  )));
                                            }
                                          }
                                        },
                                      )),
                                  flex: (flexer * 1.1).toInt(),
                                ),
                                Spacer(
                                  flex: 3,
                                ),
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                        child: Text(
                                          context.read<LanguageManager>().loginWith,
                                          style: TextStyle(fontSize: 18, color: Theme.of(context).accentColor.withOpacity(0.5), fontFamily: 'OpenSans'),
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
                                                        onTap: () async {
                                                          try {
                                                            var result = await loginWithGoogle();
                                                          } on Exception catch (e) {
                                                            Loader.hide();
                                                            Navigator.pop(context);
                                                          }
                                                        },
                                                        child: Image.asset(
                                                          'assets/images/search.png',
                                                          fit: BoxFit.contain,
                                                          height: bigPadding * 1.2,
                                                        )),
                                                    flex: 1),
                                                Expanded(
                                                    child: InkWell(
                                                      onTap: () async {
                                                        Loader.show(context, progressIndicator: LinearProgressIndicator());
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
                                                  Text(context.read<LanguageManager>().noAccount,
                                                      style: TextStyle(
                                                          fontSize: 16, fontFamily: 'OpenSans', color: Theme.of(context).accentColor.withOpacity(0.56))),
                                                  InkWell(
                                                    child: Text(context.read<LanguageManager>().createOne,
                                                        style: TextStyle(fontSize: 16, fontFamily: 'OpenSans', color: Theme.of(context).primaryColorDark)),
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
            ]))
      ]),
    ));
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: FutureBuilder(
          builder: (BuildContext context, AsyncSnapshot<ServiceResponse> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return loginForm;
            } else {
              return loginForm;
            }
          },
          future: context.read<AuthenticationService>().isPersistentUserLogged(),
        ));
  }
}

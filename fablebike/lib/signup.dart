import 'package:fablebike/pages/image_picker.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/language.dart';
import 'services/authentication_service.dart';

class SignUpScreen extends StatefulWidget {
  static const route = '/signup';
  @override
  _SignUpScreen createState() => _SignUpScreen();
}

class _SignUpScreen extends State<SignUpScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordDuplicateController = TextEditingController();
  final Image profileImage = null;
  final formKey = GlobalKey<FormState>();
  bool _loading = false;
  int commonFlex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            context.read<LanguageManager>().createAccount,
            style: Theme.of(context).textTheme.headline3,
          ),
          iconTheme: IconThemeData(color: Colors.black),
          shadowColor: Colors.white54,
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SafeArea(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    child: Column(children: [
                      Spacer(
                        flex: 1,
                      ),
                      Expanded(
                        child: FutureBuilder(
                          builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return Center(
                                    child: Column(children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(96.0),
                                    child: InkWell(
                                      child: snapshot.data,
                                    ),
                                  ),
                                ]));
                              } else {
                                return Column(
                                  children: [
                                    InkWell(
                                      child: Image.asset('assets/icons/user.png', height: 128, width: 128, fit: BoxFit.contain),
                                    )
                                  ],
                                );
                              }
                            } else {
                              return Column(
                                children: [
                                  InkWell(
                                    child: Image.asset('assets/icons/user.png', height: 128, width: 128, fit: BoxFit.contain),
                                  )
                                ],
                              );
                            }
                          },
                          future: getRegistrationImage(),
                        ),
                        flex: 4,
                      ),
                      Expanded(
                        child: Center(
                          child: InkWell(
                            child: Text(
                              context.read<LanguageManager>().pickImage,
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ),
                        ),
                        flex: 1,
                      ),
                      Spacer(flex: 1),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Material(
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Campul 'E-mail' nu poate fi gol.";
                                    }
                                    return null;
                                  },
                                  controller: emailController,
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.email_outlined),
                                      fillColor: Colors.white,
                                      hintStyle: Theme.of(context).textTheme.headline2,
                                      filled: true,
                                      border:
                                          OutlineInputBorder(borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                                      hintText: context.read<LanguageManager>().email),
                                ),
                                shadowColor: Theme.of(context).accentColor.withOpacity(0.2),
                                borderRadius: const BorderRadius.all(const Radius.circular(16.0)),
                                elevation: 10.0,
                              ),
                              flex: commonFlex,
                            ),
                            Spacer(
                              flex: 1,
                            ),
                            Expanded(
                                child: Material(
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Campul 'E-mail' nu poate fi gol.";
                                      }
                                      return null;
                                    },
                                    controller: userController,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.contact_mail_outlined),
                                        fillColor: Colors.white,
                                        hintStyle: Theme.of(context).textTheme.headline2,
                                        filled: true,
                                        border:
                                            OutlineInputBorder(borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                                        hintText: context.read<LanguageManager>().name),
                                  ),
                                  shadowColor: Theme.of(context).accentColor.withOpacity(0.2),
                                  borderRadius: const BorderRadius.all(const Radius.circular(16.0)),
                                  elevation: 10.0,
                                ),
                                flex: commonFlex),
                            Spacer(
                              flex: 1,
                            ),
                            Expanded(
                              child: Material(
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
                                      fillColor: Colors.white,
                                      hintStyle: Theme.of(context).textTheme.headline2,
                                      filled: true,
                                      border:
                                          OutlineInputBorder(borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                                      hintText: context.read<LanguageManager>().password),
                                ),
                                shadowColor: Theme.of(context).accentColor.withOpacity(0.2),
                                borderRadius: const BorderRadius.all(const Radius.circular(16.0)),
                                elevation: 10.0,
                              ),
                              flex: commonFlex,
                            ),
                            Spacer(
                              flex: 1,
                            ),
                            Expanded(
                              child: Material(
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
                                      fillColor: Colors.white,
                                      filled: true,
                                      hintStyle: Theme.of(context).textTheme.headline2,
                                      border:
                                          OutlineInputBorder(borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                                      hintText: 'Confirma Parola'),
                                ),
                                shadowColor: Theme.of(context).accentColor.withOpacity(0.2),
                                borderRadius: const BorderRadius.all(const Radius.circular(16.0)),
                                elevation: 10.0,
                              ),
                              flex: commonFlex,
                            ),
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
                                              context
                                                  .read<AuthenticationService>()
                                                  .signUp(user: userController.text, email: userController.text, password: passwordController.text);
                                              if (!formKey.currentState.validate()) {
                                                context
                                                    .read<AuthenticationService>()
                                                    .signUp(user: userController.text, email: userController.text, password: passwordController.text);
                                              }
                                            },
                                            child: Text(
                                              context.read<LanguageManager>().createAccount,
                                              style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                                            )),
                                        flex: 1,
                                      )
                                    ],
                                  ))),
                              flex: (commonFlex * 1.1).toInt(),
                            ),
                            Spacer(
                              flex: 2,
                            ),
                          ],
                        ),
                        flex: 12,
                      ),
                      Spacer(flex: 2)
                    ]),
                    height: MediaQuery.of(context).size.height - 80,
                  )),
            )));
  }
}

Future<Image> getRegistrationImage() async {
  try {
    imageCache.clear();

    var db = await DatabaseService().database;

    var profilePic = await db.query('usericon', where: 'name = ? and is_profile = ?', whereArgs: ['profile_pic_registration', 1], columns: ['blob']);

    if (profilePic.length == 0) {
      return Image.asset('assets/icons/user.png', height: 128, width: 128, fit: BoxFit.contain);
    }

    return Image.memory(profilePic.first["blob"], height: 128, width: 128, fit: BoxFit.contain);
  } on Exception {
    return null;
  }
}

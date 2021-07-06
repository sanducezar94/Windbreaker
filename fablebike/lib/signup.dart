import 'package:fablebike/pages/image_picker.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Creaaza Cont",
            style: Theme.of(context).textTheme.headline3,
          ),
          iconTheme: IconThemeData(color: Colors.black),
          shadowColor: Colors.white54,
          backgroundColor: Colors.white,
        ),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                child: ListView(children: [
                  SizedBox(height: 45.0),
                  FutureBuilder(
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
                            )
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
                  SizedBox(height: 20),
                  Column(children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, ImagePickerScreen.route).then((value) {
                          setState(() {});
                        });
                      },
                      child: Text('Adauga fotografie!', style: TextStyle(color: Colors.black45)),
                    )
                  ]),
                  SizedBox(height: 20.0),
                  Container(
                      child: Column(
                    children: [
                      Form(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        key: formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                                        filled: true,
                                        border:
                                            OutlineInputBorder(borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                                        hintText: 'Introdu e-mail'),
                                  ),
                                  shadowColor: Theme.of(context).accentColor.withOpacity(0.2),
                                  borderRadius: const BorderRadius.all(const Radius.circular(16.0)),
                                  elevation: 10.0,
                                )),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                                        filled: true,
                                        border:
                                            OutlineInputBorder(borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                                        hintText: 'Introdu nume'),
                                  ),
                                  shadowColor: Theme.of(context).accentColor.withOpacity(0.2),
                                  borderRadius: const BorderRadius.all(const Radius.circular(16.0)),
                                  elevation: 10.0,
                                )),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                                        border:
                                            OutlineInputBorder(borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                                        hintText: 'Parola'),
                                  ),
                                  shadowColor: Theme.of(context).accentColor.withOpacity(0.2),
                                  borderRadius: const BorderRadius.all(const Radius.circular(16.0)),
                                  elevation: 10.0,
                                )),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                                        border:
                                            OutlineInputBorder(borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                                        hintText: 'Confirma Parola'),
                                  ),
                                  shadowColor: Theme.of(context).accentColor.withOpacity(0.2),
                                  borderRadius: const BorderRadius.all(const Radius.circular(16.0)),
                                  elevation: 10.0,
                                )),
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
                                              shadowColor: Theme.of(context).accentColor.withOpacity(0.2),
                                              elevation: 10.0,
                                              minimumSize: Size(10, 54),
                                            ),
                                            onPressed: () async {
                                              if (formKey.currentState.validate()) {
                                                context
                                                    .read<AuthenticationService>()
                                                    .signUp(user: userController.text, email: userController.text, password: passwordController.text);
                                              }
                                            },
                                            child: Text('Creeaza cont'))
                                      ],
                                    ))),
                          ],
                        ),
                      )
                    ],
                  ))
                ]))));
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

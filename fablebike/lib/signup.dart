import 'dart:math';

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
  TextStyle errorStyle;
  bool canValidate = false;
  bool isValid = true;
  String emailError = '';
  String nameError = '';
  String passwordError = '';
  String confirmPasswordError = '';

  bool _loading = false;
  int commonFlex = 5;

  @override
  Widget build(BuildContext context) {
    var height = max(656.0 - 80, MediaQuery.of(context).size.height - 160);
    bool _isValid() {
      return emailError.isEmpty && nameError.isEmpty && passwordError.isEmpty && confirmPasswordError.isEmpty;
    }

    var formFieldStyle = TextStyle(fontFamily: 'OpenSans', fontWeight: FontWeight.w700, color: Theme.of(context).accentColor.withOpacity(0.64), fontSize: 18);

    errorStyle = TextStyle(color: Theme.of(context).errorColor, fontSize: 14);

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
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Container(
                      child: Column(children: [
                        Spacer(flex: 2),
                        Expanded(
                          child: FutureBuilder(
                            builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
                              if (snapshot.connectionState == ConnectionState.done) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(96.0),
                                    child: InkWell(
                                      child: snapshot.data,
                                      onTap: () async {
                                        Navigator.pushNamed(context, ImagePickerScreen.route).then((value) {
                                          setState(() {});
                                        });
                                      },
                                    ),
                                  );
                                } else {
                                  return InkWell(
                                    onTap: () async {
                                      Navigator.pushNamed(context, ImagePickerScreen.route).then((value) {
                                        setState(() {});
                                      });
                                    },
                                    child: Image.asset('assets/icons/user.png', fit: BoxFit.contain),
                                  );
                                }
                              } else {
                                return InkWell(
                                  onTap: () async {
                                    Navigator.pushNamed(context, ImagePickerScreen.route).then((value) {
                                      setState(() {});
                                    });
                                  },
                                  child: Image.asset('assets/icons/user.png', fit: BoxFit.contain),
                                );
                              }
                            },
                            future: getRegistrationImage(),
                          ),
                          flex: 8,
                        ),
                        Spacer(flex: 1),
                        Center(
                          child: InkWell(
                              child: Text(
                                context.read<LanguageManager>().pickImage,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                              onTap: () async {
                                Navigator.pushNamed(context, ImagePickerScreen.route).then((value) {
                                  setState(() {});
                                });
                              }),
                        ),
                        SizedBox(
                          height: _isValid() ? 10 : 1,
                        ),
                        Spacer(flex: 1),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                child: Material(
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        emailError = "Va rugam introduceti un email valid.";
                                        return null;
                                      }
                                      emailError = '';
                                      return null;
                                    },
                                    style: formFieldStyle,
                                    controller: emailController,
                                    textAlignVertical: TextAlignVertical.bottom,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.email_outlined),
                                        fillColor: Colors.white,
                                        hintStyle: formFieldStyle,
                                        filled: true,
                                        border:
                                            OutlineInputBorder(borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                                        hintText: context.read<LanguageManager>().email),
                                  ),
                                  shadowColor: Theme.of(context).accentColor.withOpacity(0.2),
                                  borderRadius: const BorderRadius.all(const Radius.circular(16.0)),
                                  elevation: 10.0,
                                ),
                                height: 54,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              if (emailError.isNotEmpty && canValidate)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(emailError, style: errorStyle),
                                ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 54,
                                child: Material(
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        nameError = 'Va rugam introduceti un nume de utilizator.';
                                        return null;
                                      }
                                      nameError = '';
                                      return null;
                                    },
                                    controller: userController,
                                    textAlignVertical: TextAlignVertical.bottom,
                                    style: formFieldStyle,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.contact_mail_outlined),
                                        fillColor: Colors.white,
                                        hintStyle: formFieldStyle,
                                        filled: true,
                                        border:
                                            OutlineInputBorder(borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                                        hintText: context.read<LanguageManager>().name),
                                  ),
                                  shadowColor: Theme.of(context).accentColor.withOpacity(0.2),
                                  borderRadius: const BorderRadius.all(const Radius.circular(16.0)),
                                  elevation: 10.0,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              if (nameError.isNotEmpty && canValidate)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(nameError, style: errorStyle),
                                ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 54,
                                child: Material(
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        passwordError = 'Parola trebuie sa contina minim 6 caractere.';
                                        return null;
                                      }
                                      passwordError = '';
                                      return null;
                                    },
                                    style: formFieldStyle,
                                    textAlignVertical: TextAlignVertical.bottom,
                                    controller: passwordController,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.lock_outlined),
                                        fillColor: Colors.white,
                                        hintStyle: formFieldStyle,
                                        filled: true,
                                        border:
                                            OutlineInputBorder(borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                                        hintText: context.read<LanguageManager>().password),
                                  ),
                                  shadowColor: Theme.of(context).accentColor.withOpacity(0.2),
                                  borderRadius: const BorderRadius.all(const Radius.circular(16.0)),
                                  elevation: 10.0,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              if (passwordError.isNotEmpty && canValidate)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    passwordError,
                                    style: errorStyle,
                                  ),
                                ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 54,
                                child: Material(
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty || value != passwordController.text) {
                                        confirmPasswordError = 'Parolele nu coincid.';
                                        return null;
                                      }
                                      confirmPasswordError = '';
                                      return null;
                                    },
                                    style: formFieldStyle,
                                    textAlignVertical: TextAlignVertical.bottom,
                                    controller: passwordDuplicateController,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.lock_outlined),
                                        fillColor: Colors.white,
                                        filled: true,
                                        hintStyle: formFieldStyle,
                                        border:
                                            OutlineInputBorder(borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                                        hintText: 'Confirma Parola'),
                                  ),
                                  shadowColor: Theme.of(context).accentColor.withOpacity(0.2),
                                  borderRadius: const BorderRadius.all(const Radius.circular(16.0)),
                                  elevation: 10.0,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              if (confirmPasswordError.isNotEmpty && canValidate)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    confirmPasswordError,
                                    style: errorStyle,
                                  ),
                                ),
                              SizedBox(
                                height: _isValid() ? 30 : 10,
                              ),
                              SizedBox(
                                height: 60,
                                width: 999,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shadowColor: Theme.of(context).accentColor.withOpacity(0.2),
                                      elevation: 10.0,
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        canValidate = true;
                                      });
                                      if (formKey.currentState.validate()) {
                                        if (emailError.isNotEmpty && nameError.isNotEmpty && passwordError.isNotEmpty && confirmPasswordError.isNotEmpty) {
                                          isValid = false;
                                          return;
                                        }
                                        var response = await context
                                            .read<AuthenticationService>()
                                            .signUp(user: userController.text, email: emailController.text, password: passwordController.text);

                                        if (!response.success) {
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              duration: const Duration(milliseconds: 1500),
                                              backgroundColor: Theme.of(context).errorColor,
                                              content: Text(response.message)));
                                        }
                                      }
                                    },
                                    child: Text(
                                      context.read<LanguageManager>().createAccount,
                                      style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                                    )),
                              ),
                            ],
                          ),
                          flex: 30,
                        ),
                      ]),
                      height: height + 80,
                    ),
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
      return Image.asset('assets/icons/user.png', fit: BoxFit.contain);
    }

    return Image.memory(profilePic.first["blob"], fit: BoxFit.contain);
  } on Exception {
    return null;
  }
}

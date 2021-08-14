import 'dart:io';

import 'package:fablebike/models/user.dart';
import 'package:fablebike/pages/image_picker.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:fablebike/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'constants/language.dart';
import 'services/authentication_service.dart';

class OAuthRegisterScreen extends StatefulWidget {
  static const route = '/oauth_register';

  final OAuthUser user;
  const OAuthRegisterScreen({
    Key key,
    @required this.user,
  }) : super(key: key);

  @override
  _OAuthRegisterScreen createState() => _OAuthRegisterScreen();
}

class _OAuthRegisterScreen extends State<OAuthRegisterScreen> {
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
  File initialImage;
  Image readyImage;
  bool isCropped = false;
  File croppedImage;
  bool _initialized = false;

  @override
  void initState() {
    emailController.text = widget.user.email;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool _isValid() {
      return emailError.isEmpty && nameError.isEmpty && passwordError.isEmpty && confirmPasswordError.isEmpty;
    }

    Future<void> initProfilePicImage(String photoUrl) async {
      try {
        var db = await DatabaseService().database;
        if (!_initialized) {
          await db.delete('usericon', where: 'name = ?', whereArgs: ['profile_pic_registration']);
        }

        var profilePic = await db.query('usericon', where: 'name = ? and is_profile = ?', whereArgs: ['profile_pic_registration', 1], columns: ['blob']);
        _initialized = true;
        if (profilePic.length > 0) {
          readyImage = Image.memory(profilePic.first["blob"], fit: BoxFit.contain);
          return;
        }

        if (readyImage != null) return;
        var file = await UserService().getOAuthIcon(photoUrl);
        readyImage = Image.file(file, width: 116, height: 116, fit: BoxFit.cover);
        initialImage = file;
        return file;
      } on Exception {
        return null;
      }
    }

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
                          child: readyImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(96.0),
                                  child: InkWell(
                                    child: readyImage,
                                    onTap: () async {},
                                  ),
                                )
                              : FutureBuilder(
                                  builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(96.0),
                                        child: InkWell(
                                          child: readyImage,
                                          onTap: () async {},
                                        ),
                                      );
                                    } else {
                                      return InkWell(
                                        onTap: () async {},
                                        child: Image.asset('assets/icons/user.png', fit: BoxFit.contain),
                                      );
                                    }
                                  },
                                  future: initProfilePicImage(widget.user.iconUrl),
                                ),
                          flex: 8,
                        ),
                        Spacer(
                          flex: 1,
                        ),
                        Center(
                          child: InkWell(
                              child: Text(
                                context.read<LanguageManager>().pickImage,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                              onTap: () async {
                                var test = 2;
                                Navigator.pushNamed(context, ImagePickerScreen.route, arguments: initialImage).then((value) async {
                                  await initProfilePicImage(widget.user.iconUrl);
                                  setState(() {});
                                });
                              }),
                        ),
                        Spacer(flex: 1),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                child: Material(
                                  child: TextFormField(
                                    readOnly: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        emailError = "Va rugam introduceti un email valid.";
                                        return null;
                                      }
                                      emailError = '';
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
                                            .facebookSignUp(user: userController.text, email: emailController.text, userToken: widget.user.token);

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
                      height: MediaQuery.of(context).size.height - 160,
                    ),
                  )),
            )));
  }
}

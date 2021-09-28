import 'dart:math';

import 'package:fablebike/pages/image_picker.dart';
import 'package:fablebike/pages/sections/rounded_button.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:provider/provider.dart';
import 'constants/language.dart';
import 'services/authentication_service.dart';

class PasswordResetScreen extends StatefulWidget {
  static const route = '/passwordreset';
  @override
  _PasswordReset createState() => _PasswordReset();
}

class _PasswordReset extends State<PasswordResetScreen> {
  final TextEditingController codeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordDuplicateController = TextEditingController();
  final Image profileImage = null;
  final formKey = GlobalKey<FormState>();
  TextStyle errorStyle;
  String emailError = '';
  String nameError = '';

  bool _codeSent = false;
  bool _loading = false;
  int commonFlex = 5;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - 80;
    var formFieldStyle = TextStyle(fontFamily: 'Lato', fontWeight: FontWeight.w700, color: Theme.of(context).accentColor.withOpacity(0.64), fontSize: 18);

    errorStyle = TextStyle(color: Theme.of(context).errorColor, fontSize: 14);

    _buildCodeConfirmationSection() {
      return Column(
        children: [
          Align(
            child: Padding(
                child: Text(
                  'Codul unic de 6 cifre a fost trimis catre dumneavoastra.',
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 16, color: Theme.of(context).accentColor),
                  textAlign: TextAlign.start,
                ),
                padding: EdgeInsets.symmetric(horizontal: 5)),
            alignment: Alignment.centerLeft,
          ),
          SizedBox(height: 20),
          SizedBox(
            child: Material(
              child: TextFormField(
                validator: (value) {
                  return null;
                },
                onChanged: (text) {
                  setState(() {});
                },
                style: formFieldStyle,
                controller: codeController,
                textAlignVertical: TextAlignVertical.bottom,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined),
                    fillColor: Colors.white,
                    hintStyle: formFieldStyle,
                    filled: true,
                    border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
                    hintText: 'Introduceti codul unic'),
              ),
              shadowColor: Theme.of(context).accentColor.withOpacity(0.2),
              borderRadius: const BorderRadius.all(const Radius.circular(16.0)),
              elevation: 10.0,
            ),
            height: 54,
          ),
          SizedBox(
            height: 30,
          ),
          SizedBox(
            height: 54,
            child: RoundedButtonWidget(
              inactive: codeController.text.length < 6,
              child: Text(
                "Verifica",
                style: TextStyle(
                  fontSize: 18,
                  // fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              width: width,
              onpressed: () async {
                if (codeController.text.isEmpty) return;
                setState(() {
                  _codeSent = true;
                });
              },
            ),
          ),
          SizedBox(height: 100),
          Align(
            child: Padding(
                child: Text(
                  'Nu ai primit codul?',
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 16, color: Theme.of(context).accentColor),
                  textAlign: TextAlign.start,
                ),
                padding: EdgeInsets.symmetric(horizontal: 5)),
            alignment: Alignment.center,
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 54,
            child: RoundedButtonWidget(
              inactive: false,
              child: Text(
                "Trimite codul din nou",
                style: TextStyle(
                  fontSize: 18,
                  // fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              width: width,
              onpressed: () async {
                if (codeController.text.isEmpty) return;
                setState(() {
                  _codeSent = true;
                });
              },
            ),
          ),
        ],
      );
    }

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            //context.read<LanguageManager>().createAccount,
            "Reseteaza parola",
            style: Theme.of(context).textTheme.headline1,
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
                        SizedBox(height: 20),
                        Align(
                          child: Padding(
                            child: Text(
                              'Introduceti email-ul cu care v-ati inregistrat.',
                              style: TextStyle(fontFamily: 'Lato', fontSize: 16, color: Theme.of(context).accentColor),
                              textAlign: TextAlign.start,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 5),
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                        SizedBox(height: 20),
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
                                  border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: const BorderRadius.all(const Radius.circular(16.0))),
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
                        if (emailError.isNotEmpty)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(emailError, style: errorStyle),
                          ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 54,
                          child: RoundedButtonWidget(
                            inactive: _codeSent,
                            child: Text(
                              "Trimite cod",
                              style: TextStyle(
                                fontSize: 18,
                                // fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            width: width,
                            onpressed: () async {
                              if (emailController.text.isEmpty) return;
                              setState(() {
                                _codeSent = true;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        if (_codeSent) _buildCodeConfirmationSection()
                      ]),
                      height: height - 80,
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

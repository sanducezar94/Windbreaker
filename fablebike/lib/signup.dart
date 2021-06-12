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
  final formKey = GlobalKey<FormState>();
  bool _loading = false;

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
                      RegExp emailReg = new RegExp(r"^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$");
                      if (value == null || value.isEmpty) {
                        return "Campul 'Email' nu poate fi gol.";
                      } else if (emailReg.firstMatch(value) == null) {
                        return "Email-ul nu este valid.";
                      }
                      return null;
                    },
                    controller: emailController,
                    decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Email'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Numele de utilizator nu poate fi gol.';
                      }
                      if (value.length < 6) {
                        return 'Numele de utilizator nu poate fi mai mic de 6 caractere.';
                      }
                      RegExp userReg = new RegExp("[^A-Za-z0-9]");
                      if (userReg.firstMatch(value) != null) {
                        return 'Numele de utilizator nu poate contine caractere speciale.';
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
                      if (value == null || value.isEmpty || value.length < 6) {
                        return 'Parola nu poate fi mai scurta de 6 caractere.';
                      }
                    },
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Parola'),
                  ),
                ),
                Padding(padding: EdgeInsets.all(16.0)),
                ElevatedButton(
                    onPressed: !_loading
                        ? () async {
                            if (formKey.currentState.validate()) {
                              this.setState(() {
                                _loading = true;
                              });
                              var response = await context
                                  .read<AuthenticationService>()
                                  .signUp(user: userController.text, email: emailController.text, password: passwordController.text);
                              FocusScope.of(context).unfocus();
                              if (response.success) {
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.redAccent, content: Text(response.message)));
                              }
                              this.setState(() {
                                _loading = false;
                              });
                            }
                          }
                        : null,
                    child: Text('Create')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Back')),
              ],
            )));
  }
}

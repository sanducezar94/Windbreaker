import 'package:fablebike/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/authentication_service.dart';

class FacebookSignUpScreen extends StatefulWidget {
  static const route = '/facebook_signup';

  final FacebookUser fbUser;
  const FacebookSignUpScreen({
    Key key,
    @required this.fbUser,
  }) : super(key: key);

  @override
  _FacebookSignUpScreen createState() => _FacebookSignUpScreen();
}

class _FacebookSignUpScreen extends State<FacebookSignUpScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(border: OutlineInputBorder(), hintText: widget.fbUser.email),
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
                Padding(padding: EdgeInsets.all(16.0)),
                ElevatedButton(
                    onPressed: !_loading
                        ? () async {
                            if (formKey.currentState.validate()) {
                              this.setState(() {
                                _loading = true;
                              });
                              var response = await context.read<AuthenticationService>().facebookSignUp(user: userController.text, email: widget.fbUser.email);
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

import 'package:fablebike/models/facebook_user.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: widget.fbUser.email),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            controller: userController,
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: 'Utilizator'),
          ),
        ),
        Padding(padding: EdgeInsets.all(16.0)),
        ElevatedButton(
            onPressed: () {
              context
                  .read<AuthenticationService>()
                  .facebookSignUp(
                      user: userController.text, email: widget.fbUser.email)
                  .then((result) {
                if (result) {
                  Navigator.pop(context);
                }
              });
            },
            child: Text('Create')),
        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Back')),
      ],
    ));
  }
}

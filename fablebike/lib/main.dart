import 'package:flutter/material.dart';
import 'package:fablebike/models/route.dart';
import 'package:fablebike/services/authentication_service.dart';
import 'package:fablebike/services/comment_service.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import './pages/home.dart';
import './pages/map.dart';
import './pages/routes.dart';
import 'login_screen.dart';
import 'signup.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert' show json, base64, ascii;

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

const SERVER_IP = '192.168.100.24:8080';

Future<void> main() async {
  if (kIsWeb) {
    // initialiaze the facebook javascript SDK
    FacebookAuth.instance.webInitialize(
      appId: "214280373695735",
      cookie: true,
      xfbml: true,
      version: "v9.0",
    );
  }

  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(),
        ),
        StreamProvider(
            create: (context) => context.read<AuthenticationService>().authUser)
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AuthenticatioNWrapper(),
        routes: <String, WidgetBuilder>{
          HomeScreen.route: (context) => HomeScreen(),
          AuthenticatioNWrapper.route: (context) => AuthenticatioNWrapper(),
          SignUpScreen.route: (context) => SignUpScreen(),
          RoutesScreen.route: (context) => RoutesScreen()
        },
        onGenerateRoute: (settings) {
          if (settings.name == MapScreen.route) {
            final args = settings.arguments as BikeRoute;

            return MaterialPageRoute(
              builder: (context) {
                return MapScreen(bikeRoute: args);
              },
            );
          }
          assert(false, 'Need to implement ${settings.name}');
          return null;
        },
      ),
    );
  }
}

class AuthenticatioNWrapper extends StatelessWidget {
  static const String route = '/landing';

  const AuthenticatioNWrapper({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthenticatedUser>();

    if (authUser != null && authUser.username != 'none') {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      return HomeScreen();
    } else {
      return LoginScreen();
    }
  }
}

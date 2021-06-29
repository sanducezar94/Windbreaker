import 'package:fablebike/bloc/bookmarks_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fablebike/services/authentication_service.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fablebike/pages/image_picker.dart';
import 'package:fablebike/pages/bookmarks.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fablebike/pages/poi_info.dart';
import 'package:fablebike/pages/settings.dart';
import 'package:fablebike/models/route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './pages/home.dart';
import './pages/map.dart';
import './pages/routes.dart';
import 'facebook_signup.dart';
import 'login_screen.dart';
import 'models/user.dart';
import 'signup.dart';

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
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        StreamProvider(create: (context) => context.read<AuthenticationService>().authUser)
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            primaryColor: Color.fromRGBO(100, 157, 80, 1),
            textTheme: TextTheme(
                headline1: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black54),
                headline2: TextStyle(fontSize: 18.0, color: Colors.black38),
                bodyText1: TextStyle(fontSize: 14.0, color: Colors.black87, fontWeight: FontWeight.bold),
                bodyText2: TextStyle(fontSize: 12.0, color: Colors.black87))),
        home: AuthenticationWrapper(),
        routes: <String, WidgetBuilder>{
          HomeScreen.route: (context) => HomeScreen(),
          AuthenticationWrapper.route: (context) => AuthenticationWrapper(),
          SignUpScreen.route: (context) => SignUpScreen(),
          RoutesScreen.route: (context) => RoutesScreen(),
          SettingsScreen.route: (context) => SettingsScreen(),
          ImagePickerScreen.route: (context) => ImagePickerScreen(),
          BookmarksScreen.route: (context) => BookmarksScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == POIScreen.route) {
            final args = settings.arguments as PointOfInterest;

            return MaterialPageRoute(builder: (context) {
              return POIScreen(poi: args);
            });
          }
          if (settings.name == MapScreen.route) {
            final args = settings.arguments as BikeRoute;

            return MaterialPageRoute(
              builder: (context) {
                return MapScreen(bikeRoute: args);
              },
            );
          }
          if (settings.name == FacebookSignUpScreen.route) {
            final args = settings.arguments as FacebookUser;

            return MaterialPageRoute(
              builder: (context) {
                return FacebookSignUpScreen(fbUser: args);
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

class AuthenticationWrapper extends StatelessWidget {
  static const String route = '/landing';

  const AuthenticationWrapper({
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

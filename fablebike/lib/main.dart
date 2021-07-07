import 'package:fablebike/bloc/main_bloc.dart';
import 'package:fablebike/pages/explore.dart';
import 'package:fablebike/pages/home_wrapper.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fablebike/services/authentication_service.dart';
import 'package:fablebike/services/database_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fablebike/pages/image_picker.dart';
import 'package:fablebike/pages/bookmarks.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fablebike/pages/objective.dart';
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
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(),
        ),
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        Provider<MainBloc>(create: (_) => MainBloc()),
        StreamProvider(create: (context) => context.read<AuthenticationService>().authUser, initialData: null),
        StreamProvider(
          create: (context) => context.read<MainBloc>().output,
          initialData: null,
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            scaffoldBackgroundColor: const Color.fromRGBO(249, 249, 249, 1),
            primaryColor: Color.fromRGBO(99, 157, 78, 1),
            accentColor: Color.fromRGBO(37, 14, 19, 1),
            errorColor: Color.fromRGBO(157, 78, 78, 1),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 16),
                  primary: Color.fromRGBO(99, 157, 78, 1),
                  //primary: Color.fromRGBO(49, 112, 181, 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0))),
            ),
            textTheme: TextTheme(
              headline1: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black54),
              headline2: TextStyle(fontSize: 18.0, color: Color.fromRGBO(37, 14, 19, 1).withOpacity(0.36)),
              bodyText1: TextStyle(fontSize: 14.0, color: Color.fromRGBO(37, 14, 19, 1).withOpacity(0.87), fontWeight: FontWeight.bold),
              bodyText2: TextStyle(fontSize: 12.0, color: Color.fromRGBO(37, 14, 19, 1).withOpacity(0.65)),
              headline5: TextStyle(fontSize: 16.0, color: Color.fromRGBO(37, 14, 19, 1).withOpacity(0.87), fontWeight: FontWeight.bold),
              headline4: TextStyle(fontSize: 14.0, color: Color.fromRGBO(37, 14, 19, 1).withOpacity(0.54)),
              headline3: TextStyle(fontSize: 20.0, color: Color.fromRGBO(37, 14, 19, 1).withOpacity(0.87)),
              headline6: TextStyle(fontSize: 22.0, color: Color.fromRGBO(37, 14, 19, 1).withOpacity(0.87), fontWeight: FontWeight.bold),
            )),
        home: AuthenticationWrapper(),
        routes: <String, WidgetBuilder>{
          HomeScreen.route: (context) => HomeScreen(),
          AuthenticationWrapper.route: (context) => AuthenticationWrapper(),
          SignUpScreen.route: (context) => SignUpScreen(),
          ExploreScreen.route: (context) => ExploreScreen(),
          SettingsScreen.route: (context) => SettingsScreen(),
          ImagePickerScreen.route: (context) => ImagePickerScreen(),
          BookmarksScreen.route: (context) => BookmarksScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == ObjectiveScreen.route) {
            final args = settings.arguments as ObjectiveInfo;

            return MaterialPageRoute(builder: (context) {
              return ObjectiveScreen(objective: args.objective, fromRoute: args.fromRoute);
            });
          }
          if (settings.name == RoutesScreen.route) {
            final args = settings.arguments as Objective;

            return MaterialPageRoute(builder: (context) {
              return RoutesScreen(objective: args);
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
      return HomeWrapper();
    } else {
      return LoginScreen();
    }
  }
}

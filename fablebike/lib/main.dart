import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fablebike/bloc/main_bloc.dart';
import 'package:fablebike/constants/language.dart';
import 'package:fablebike/pages/explore.dart';
import 'package:fablebike/pages/fullscreen_map.dart';
import 'package:fablebike/pages/home_wrapper.dart';
import 'package:fablebike/pages/objectives.dart';
import 'package:fablebike/pages/route_map.dart';
import 'package:fablebike/otp_screen.dart';
import 'package:fablebike/services/connectivity_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fablebike/services/authentication_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fablebike/pages/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fablebike/pages/objective.dart';
import 'package:fablebike/pages/settings.dart';
import 'package:fablebike/models/route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/utils/utils.dart';

import './pages/home.dart';
import './pages/routes.dart';
import 'oauth_signup.dart';
import 'login_screen.dart';
import 'models/user.dart';
import 'signup.dart';

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

  ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var textColor = Color.fromRGBO(24, 55, 45, 1);
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(),
        ),
        Provider<MainBloc>(create: (_) => MainBloc()),
        Provider<LanguageManager>(create: (_) => LanguageManager()),
        StreamProvider(create: (context) => context.read<AuthenticationService>().authUser, initialData: null),
        StreamProvider(
          create: (context) => context.read<MainBloc>().output,
          initialData: null,
        )
      ],
      child: MaterialApp(
        title: 'Cu bicicleta pe drumuri de poveste',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            fontFamily: 'Lato',
            scaffoldBackgroundColor: Color.fromRGBO(251, 254, 255, 1),
            primaryColor: Color.fromRGBO(20, 148, 166, 1),
            // splashColor: Color.fromRGBO(157, 207, 78, 1),
            cardColor: Color.fromRGBO(252, 254, 255, 1),
            hintColor: Color.fromRGBO(64, 86, 84, 0.5),
            accentColor: Color.fromRGBO(64, 86, 84, 1),
            primaryColorDark: Color.fromRGBO(24, 145, 129, 1),
            shadowColor: Color.fromRGBO(2, 41, 63, 1),
            //primaryColorDark: Color.fromRGBO(78, 177, 177, 1),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 16),
                  primary: Color.fromRGBO(24, 145, 129, 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0))),
            ),
            textTheme: TextTheme(
              subtitle1: TextStyle(fontSize: 18.0, color: textColor.withOpacity(0.5), fontFamily: 'Nunito'),
              headline1: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: textColor.withOpacity(0.9), fontFamily: 'Lato'),
              headline2: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: textColor.withOpacity(0.75), fontFamily: 'Lato'),
              headline3: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Lato'),
              headline4: TextStyle(fontSize: 16.0, color: Colors.white70, fontFamily: 'Lato'),
              subtitle2: TextStyle(fontSize: 14.0, color: textColor.withOpacity(1), fontFamily: 'Nunito'),
              bodyText2: TextStyle(fontSize: 14.0, color: textColor.withOpacity(0.8), fontFamily: 'Nunito'),
              bodyText1: TextStyle(fontSize: 17.0, color: textColor, fontWeight: FontWeight.bold, fontFamily: 'Lato'),
            )),
        home: AuthenticationWrapper(),
        routes: <String, WidgetBuilder>{
          HomeScreen.route: (context) => HomeScreen(),
          AuthenticationWrapper.route: (context) => AuthenticationWrapper(),
          SignUpScreen.route: (context) => SignUpScreen(),
          ExploreScreen.route: (context) => ExploreScreen(),
          SettingsScreen.route: (context) => SettingsScreen(),
          OtpScreen.route: (context) => OtpScreen(),
          ObjectivesScreen.route: (context) => ObjectivesScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == ObjectiveScreen.route) {
            final args = settings.arguments as ObjectiveInfo;

            return MaterialPageRoute(builder: (context) {
              return ObjectiveScreen(objective: args.objective, fromRoute: args.fromRoute);
            });
          }
          if (settings.name == FullScreenMap.route) {
            final args = settings.arguments as BikeRoute;
            return MaterialPageRoute(builder: (context) {
              return FullScreenMap(bikeRoute: args);
            });
          }
          if (settings.name == ImagePickerScreen.route) {
            final args = settings.arguments as File;

            return MaterialPageRoute(builder: (context) {
              return ImagePickerScreen(file: args);
            });
          }
          if (settings.name == RoutesScreen.route) {
            final args = settings.arguments as Objective;

            return MaterialPageRoute(builder: (context) {
              return RoutesScreen(objective: args);
            });
          }
          if (settings.name == RouteMapScreen.route) {
            final args = settings.arguments as BikeRoute;

            return MaterialPageRoute(
              settings: settings,
              builder: (context) {
                return RouteMapScreen(bikeRoute: args);
              },
            );
          }
          if (settings.name == OAuthRegisterScreen.route) {
            final args = settings.arguments as OAuthUser;

            return MaterialPageRoute(
              builder: (context) {
                return OAuthRegisterScreen(user: args);
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

import 'package:arborizacao/pages/home.dart';
import 'package:arborizacao/splash_screen/splash_screen.dart';
import 'package:flutter/cupertino.dart'; 

class Routes {
  static Map<String, Widget Function(BuildContext context)> routes =
      <String, WidgetBuilder>{ 
    '/splash': (context) => const SplashScreen(),
    '/home': (context) => const Home(),

  };

  static String initialRoute = '/splash';
}

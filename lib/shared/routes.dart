import 'package:event_manager/screens/admin.dart';
import 'package:event_manager/screens/login_screen.dart';
import 'package:event_manager/screens/mainscreen.dart';
import 'package:event_manager/screens/signup_screen.dart';
import 'package:flutter/material.dart';

class RouteHelper {
  static const String initRoute = "/";
  static const String login = "/login";
  static const String signup = "/signup";
  static const String mainscreen = "/mainscreen";
  static const String admin = "/admin";
  static bool isLoggedIn = false;

  static String getInitialRoute() {
    return isLoggedIn ? mainscreen : login;
  }

  static Map<String, WidgetBuilder> routes(BuildContext context) {
    return {
      initRoute: (context) => isLoggedIn
          ? HomeScreen(
              email: '',
            )
          : const LoginScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignUpScreen(),
      admin: (context) => const AdminPage(),
      mainscreen: (context) => HomeScreen(
            email: '',
          ),
    };
  }
}

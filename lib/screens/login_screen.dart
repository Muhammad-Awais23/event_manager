// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_manager/components/components.dart';
import 'package:event_manager/components/constants.dart';
import 'package:event_manager/screens/mainscreen.dart';
import 'package:event_manager/shared/functions.dart';

import 'package:event_manager/shared/routes.dart';

import 'package:flutter/material.dart';

import 'package:loading_overlay/loading_overlay.dart';

import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static String id = 'login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<bool> checkAdmin(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .get();

      if (snapshot.docs.isNotEmpty) {
        final isAdmin = snapshot.docs.first.data()['isAdmin'] ?? false;
        return isAdmin;
      }
    } catch (e) {
      print('Error checking admin status: $e');
    }
    return false;
  }

  void _navigateToMainScreen() {
    RouteHelper.isLoggedIn = true;
    Navigator.pushReplacementNamed(context, RouteHelper.mainscreen);
  }

  void _navigateToAdminScreen() {
    RouteHelper.isLoggedIn = true;
    Navigator.pushReplacementNamed(context, RouteHelper.admin);
  }

  void _showErrorDialog() {
    _setSavingState(false);
    signUpAlert(
      context: context,
      onPressed: () => _setSavingState(false),
      title: 'WRONG PASSWORD OR EMAIL',
      desc: 'Confirm your email and password and try again',
      btnText: 'Try Again',
    ).show();
  }

  void _setSavingState(bool value) {
    if (context.mounted) {
      setState(() {
        _saving = value;
      });
    }
  }

  final _auth = FirebaseAuth.instance;
  late String _email = '';
  late String _password = '';
  bool _saving = false;
  bool isAdminCheckButton = false;
  final userCredential = ValueNotifier<UserCredential?>(null);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: LoadingOverlay(
        isLoading: _saving,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const TopScreenImage(screenImageName: 'logo.png'),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const ScreenTitle(title: 'Login'),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: CustomTextField(
                          textField: TextField(
                              onChanged: (value) {
                                _email = value;
                              },
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                              decoration: kTextInputDecoration.copyWith(
                                  hintText: 'Email')),
                        ),
                      ),
                      CustomTextField(
                        textField: TextField(
                          obscureText: true,
                          onChanged: (value) {
                            _password = value;
                          },
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                          decoration: kTextInputDecoration.copyWith(
                              hintText: 'Password'),
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: isAdminCheckButton,
                            onChanged: (bool? value) {
                              setState(() {
                                isAdminCheckButton = value ?? false;
                              });
                            },
                          ),
                          const Text('Log in as Admin')
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: CustomBottomScreen(
                          textButton: 'Login',
                          heroTag: 'login_btn',
                          question: 'Forgot password?',
                          buttonPressed: () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            setState(() {
                              _saving = true;
                            });

                            if (_email.isEmpty || _password.isEmpty) {
                              _showSnackBar(
                                  'Email and password cannot be empty.');
                              return;
                            }
                            if (isAdminCheckButton) {
                              final bool isAdmin = await checkAdmin(_email);
                              if (isAdmin) {
                                _navigateToAdminScreen();
                              } else {
                                _setSavingState(false);
                                _showSnackBar(
                                    'You are not authorized to log in as admin.');
                              }
                            } else {
                              try {
                                final UserCredential userCredential =
                                    await _auth.signInWithEmailAndPassword(
                                  email: _email,
                                  password: _password,
                                );

                                final User? user = userCredential.user;

                                if (user != null) {
                                  setState(() {
                                    RouteHelper.isLoggedIn = true;
                                  });

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          HomeScreen(email: _email),
                                    ),
                                  );
                                }
                              } catch (e) {
                                _showErrorDialog();
                              } finally {
                                _setSavingState(false);
                              }
                            }
                          },
                          questionPressed: () async {
                            try {
                              await FirebaseAuth.instance
                                  .sendPasswordResetEmail(email: _email);
                              _showSnackBar('Password reset email sent.');
                            } catch (e) {
                              _showErrorDialog();
                            }
                          },
                        ),
                      ),
                      const Text(
                        'Sign in using',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ValueListenableBuilder(
                              valueListenable: userCredential,
                              builder:
                                  (BuildContext context, value, Widget? child) {
                                return IconButton(
                                  onPressed: () async {
                                    userCredential.value =
                                        await SignIn().signInWithGoogle();

                                    if (userCredential.value != null) {
                                      print(userCredential.value!.user!.email);
                                      _navigateToMainScreen();
                                    }
                                  },
                                  icon: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.transparent,
                                    child: Image.asset(
                                        'assets/images/icons/google.png'),
                                  ),
                                );
                              }),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Dont have account?",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: GestureDetector(
                              onTap: () {
                                RouteHelper.isLoggedIn = true;
                                Navigator.pushNamed(
                                    context, RouteHelper.signup);
                              },
                              child: const Text(
                                "Sign up",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

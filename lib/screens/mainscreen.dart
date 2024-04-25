import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _username = '';

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _username = userData['username'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome $_username'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Welcome $_username',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
              onTap: () {
                // Handle profile option
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Account Management'),
              onTap: () {
                // Handle account management option
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_mail),
              title: Text('Contact us'),
              onTap: () {
                // Handle contact us option
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                // Handle logout option
                await FirebaseAuth.instance.signOut();
                // Redirect to login page or wherever you need
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Your content here'),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyHomePage(),
  ));
}

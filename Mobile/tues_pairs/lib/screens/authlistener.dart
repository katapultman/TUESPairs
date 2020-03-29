import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tues_pairs/screens/register/register.dart';
import 'package:tues_pairs/screens/login/login.dart';
import 'package:tues_pairs/screens/main/match.dart';
import 'package:tues_pairs/screens/main/home.dart';
import 'package:provider/provider.dart';
import 'package:tues_pairs/screens/authenticate/authenticate.dart';
import 'package:tues_pairs/services/database.dart';
import 'package:tues_pairs/modules/user.dart';
import 'package:tues_pairs/screens/loading/loading.dart';

class AuthListener extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    // this widget is instantiated in main.dart
    // and since we're using StreamProvider and its instantiation is derived inside of the StreamProvider.value() widget
    // that means we can use the value set in the StreamProvider widget here as well!

    // using the Provider.of() generic method
    // return either register or login widget if User is auth'ed
    // user is not auth'd if Provider returns null
    // user is auth'd if Provder returns instance of FirebaseUser (or whichever class we passed as a generic parameter)

    User authUser = Provider.of<User>(context);

    if(authUser != null) {
      return FutureBuilder<User>( // Get current user here for use down the entire widget tree
        future: Database(uid: authUser.uid).getUserById(), // the Provider.of() generic method takes context,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done) {
            return Provider<User>.value(
              value: snapshot.data,
              child: Home(),
            );
          } else return Loading();
        }
      );
    } else return Authenticate();
  }
}
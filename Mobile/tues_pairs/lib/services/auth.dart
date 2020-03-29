import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tues_pairs/modules/user.dart';
import 'package:tues_pairs/services/database.dart';
import 'package:tues_pairs/modules/tag.dart';
import 'package:tues_pairs/screens/authlistener.dart';

class Auth {

  final FirebaseAuth _auth = FirebaseAuth.instance; // property to receive a default FirebaseAuth instance

  // auth changes are listened by streams which are a generic class returning an instance of the stream of what we want
  // streams send their data one by one, allowing for listening in changes
  // Need to use instance.collection('users') and set custom fields through there (?)

  User FireBaseUsertoUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid, email: user.email, photoURL: user.photoUrl) : null;
  }

  FirebaseAuth get auth {
    return _auth;
  }

  Stream<User> get user {
    return _auth.onAuthStateChanged.map((FirebaseUser user) => FireBaseUsertoUser(user));
    // getter method which returns whether Auth State has changed (returns null if it hasn't)
    // map the current stream to the conversion method for FirebaseUser to our custom User
  }

  Future registerUserByEmailAndPassword(User authUser) async { // async function returns Future (placeholder variable until callback from other thread is received)
    try {
      AuthResult authResult = await _auth.createUserWithEmailAndPassword(email: authUser.email, password: authUser.password);
      FirebaseUser user = authResult.user;
      // -----------------------------------
      // User has successfully auth'd at this point
      // -----------------------------------



      await Database(uid: user.uid).updateUserData(authUser); // create the document when the user registers
      await user.sendEmailVerification();

      return FireBaseUsertoUser(authResult.user); // return the user property garnered by the authResult
    } catch(exception) {
      print(exception.toString());
      return null;
    }
  }

  Future loginUserByEmailAndPassword(String email, String password) async {
    try {
      AuthResult authResult = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return FireBaseUsertoUser(authResult.user);
    } catch(exception) {
      print(exception.toString());
      return null;
    }
  }

  Future deleteFirebaseUser() async{
    try{
      FirebaseUser firebaseUser = await _auth.currentUser();
      await firebaseUser.delete();
    } catch(exception){
      print(exception.toString());
      return null;
    }
  }

  Future logout() async {
    try {
      await _auth.signOut();
    } catch(exception) {
      print(exception.toString());
      return null;
    }
  }

}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tues_pairs/modules/user.dart';
import 'package:tues_pairs/services/auth.dart';
import 'package:tues_pairs/screens/main/settings.dart';
import 'package:tues_pairs/screens/main/chat.dart';
import 'package:tues_pairs/screens/main/match.dart';
import 'package:tues_pairs/services/database.dart';
import 'package:tues_pairs/shared/constants.dart';
import 'package:tues_pairs/shared/keys.dart';
import 'package:tues_pairs/widgets/notifications/notification_list.dart';
import 'dart:io' show Platform, exit;

import '../../main.dart';

class Home extends StatefulWidget {
  static int selectedIndex = 1; 
  // selected index for page (first is the middle one); change throughout route navigation
  // static due to change in Settings routes

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  // ---------------
  // NavigationBar properties:
  // ---------------

  final Auth _auth = new Auth();

  PageController _controller = PageController(
    initialPage: Home.selectedIndex,
  );

  List<Widget> _widgets = [
    Chat(),
    Match(),
    Settings(),
  ]; // list of children widgets to navigate between

  void onItemSwipe(int index) {
    setState(() {
      Home.selectedIndex = index;
      _controller.animateToPage(
          index, duration: Duration(milliseconds: 500), curve: Curves.ease);
    }); // set the selected index to the index given
  }

  void onItemTap(int index) {
    setState(() {
      Home.selectedIndex = index;
      _controller.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User>(context);

    return Scaffold(
      key: Key(Keys.homeScaffold),
      appBar: buildAppBar(
        pageTitle: _widgets[Home.selectedIndex].toString(),
        actions: <Widget>[
          FlatButton.icon(
            key: Key(Keys.logOutButton),
            onPressed: () async {
              Home.selectedIndex = 1; // restores back to match page on logout

              currentUser.deviceTokens.remove(App.currentUserDeviceToken); // TODO: Check/optimize
              await Database(uid: currentUser.uid).updateUserData(currentUser, isBeingLoggedOut: true); // set the flag to true in order to not re-add the token

              await _auth.logout();
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.orange,
              size: 25.0,
            ),
            label: Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 35.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ]
      ),

      drawer: Drawer(
        child: NotificationList(), // ListView to display all notifications
      ),

      body: PageView(
        scrollDirection: Axis.horizontal,
        controller: _controller,
        children: _widgets,
        onPageChanged: onItemSwipe,
        pageSnapping: true,
      ),

      bottomNavigationBar: BottomNavigationBar(
        key: Key(Keys.bottomNavigationBar),
        fixedColor: Colors.orange,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            title: Text(
              'Chat',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.0,
                letterSpacing: 1.0,
              ),
            ),
            backgroundColor: Colors.deepOrangeAccent,
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text(
                'Match',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.0,
                  letterSpacing: 1.0,
                ),
              ),
              backgroundColor: Colors.deepOrangeAccent
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.0,
                letterSpacing: 1.0,
              ),
            ),
            backgroundColor: Colors.deepOrangeAccent
          ),
        ],
        currentIndex: Home.selectedIndex,
        onTap: onItemTap,
        backgroundColor: darkGreyColor,
      ),
    );
  }
}

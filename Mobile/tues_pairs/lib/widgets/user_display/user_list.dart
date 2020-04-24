import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tues_pairs/modules/tag.dart';
import 'package:tues_pairs/screens/loading/loading.dart';
import 'package:tues_pairs/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:tues_pairs/services/database.dart';
import 'package:tues_pairs/modules/user.dart';
import 'package:tues_pairs/modules/student.dart';
import 'package:tues_pairs/services/image.dart';
import 'package:tues_pairs/shared/constants.dart';
import 'package:tues_pairs/shared/keys.dart';
import 'package:tues_pairs/widgets/tag_display/tag_card.dart';
import 'package:tues_pairs/widgets/user_display/user_card.dart';
import 'package:tues_pairs/widgets/general/error.dart';

class UserList extends StatefulWidget {

  final Function reinitializeMatch;

  UserList({this.reinitializeMatch});

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {

  final ImageService imageService = new ImageService();
  final Database database = new Database();

  NetworkImage currentUserImage;

  List<User> users = <User>[];
  List<NetworkImage> images;
  List<List<TagCard>> tagCards;
  List<UserCard> userCards;

  final _animatedListKey = GlobalKey<AnimatedListState>(); // key used to follow our animated list through its states

  List<NetworkImage> getUserImages() {
    List<NetworkImage> images = new List<NetworkImage>(users.length);
    for(int useridx = 0; useridx < images.length; useridx++) {
      if(users[useridx].photoURL != null) {
        images[useridx] = imageService.getImageByURL(users[useridx].photoURL);
      }
    }
    return images;
  }

  Future<List<List<TagCard>>> getUserTags() async {
    List<List<Tag>> userTags = new List<List<Tag>>(users.length);

    for(int useridx = 0; useridx < users.length; useridx++) {
      userTags[useridx] = <Tag>[];
      for(var tag in users[useridx].tagIDs) {
        userTags[useridx].add(await database.getTagByID(tag));
      }
      // get the Tag instance for each tag ID
    }

    print('ALL TAGS: ${userTags}');

    print('ALL TAGCARDS: ${userTags.map((tags) =>
        mapTagsToTagCards(tags, cardType: TagCardType.VIEW))
        .toList()}');

    return userTags.map((tags) =>
    mapTagsToTagCards(tags, cardType: TagCardType.VIEW))
        .toList(); // map the tags to TagCards
  }

  void loadListItems(User currentUser, List<User> users) {
    // method that utilises a Future delay to simulate a smooth loading effect.
    // Credit to user NearHuscarl from the thread https://stackoverflow.com/questions/57100219/how-to-animate-the-items-rendered-initially-using-animated-list-in-flutter
    // for the solution
    // users = fetchedUsers

    // TODO: Optimise filtration of users with removeWhere()
    var future = Future(() {});
    for(int idx = 0; idx < users.length; idx++) {
      final user = users[idx];
      if(currentUser.isTeacher != user.isTeacher
          && !currentUser.skippedUserIDs.contains(user.uid) &&
          (user.matchedUserID == null || user.matchedUserID == currentUser.uid) && !user.skippedUserIDs.contains(currentUser)) {
        // reinitializing future with lvalue helps futures wait for one-another (+then)
        future = future.then((_) {
          return Future.delayed(Duration(milliseconds: 100), () {
            userCards.add(buildUserCard(
                currentUser,
                idx,
                users[idx],
                initialListIndex: userCards.length,
              )
            ); // add card item here
            try {
              _animatedListKey.currentState.insertItem(
                  userCards.length - 1
              ); // insert the latest item here
            } catch (e) {
              logger.w('User w/ id "' + currentUser.uid + '" has navigated through match too fast!');
              // TODO: log that user has navigated through the screens too fast -> done
            }
          });
        });
      }
    }
  }

  int getListIndex(User user, {User currentUser}) {
    // TODO: Optimise this retarded ass fix
    logger.w('UserCard: onSkip user w/ id "' + currentUser.uid + '" has skipped incorrect users and has triggered skip exception handler.'); // user removes bad

    for(int idx = 0; idx < userCards.length; idx++) {
      if(userCards[idx].user.uid == user.uid) {
        return idx;
      }
    }

    logger.e('UserCard: onSkip user w/ id "' + currentUser.uid + '" has killed the program through skipping invalid users.');
    throw new Exception('Invalid user skip!');
  }

  UserCard buildUserCard(User currentUser, int userIndex, User user, {int initialListIndex}) {
    final Database database = new Database(uid: currentUser.uid);

    return UserCard(
      key: Key(Keys.matchUserCard + userIndex.toString()),
      user: user,
      userImage: images[userIndex],
      tagCards: tagCards[userIndex] ?? [],
      onMatch: () async {
        if(currentUser.matchedUserID == null) {
          logger.i('UserList: Current user w/ id "' + currentUser.uid + '" is matched with user w/ id + "' + user.uid + '"');
          currentUser.matchedUserID = user.uid;
          await database.updateUserData(currentUser); // optimise later maybe
        }
        widget.reinitializeMatch();
      },
      onSkip: () async {
        currentUser.skippedUserIDs.add(user.uid);
        await database.updateUserData(currentUser); // optimise later maybe

        int listIndex = getListIndex(user, currentUser: currentUser);

        userCards.removeAt(listIndex);
        users.remove(user);
        logger.i('UserList: Current user w/ id "' + currentUser.uid + '" skipped user w/ id + "' + user.uid + '"');
        setState(() {
          // remove from both lists
          _animatedListKey.currentState.removeItem(listIndex,
                (context, animation) => SlideTransition(
                  position: CurvedAnimation(
                  curve: Curves.easeOut,
                  parent: animation,
                ).drive(Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: const Offset(0, 0),
                )
              )
            )
          );
        });
      },
      listIndex: initialListIndex, // idx of element in the filtered list
    );
  }

  // TODO: add method that checks skipped ID array with a user ID

  Widget userList;

  @override
  Widget build(BuildContext context) {
    // access StreamProvider of QuerySnapshots info here
    final currentUser = Provider.of<User>(context);
    bool isFirstBuild = users.isEmpty;

    if(isFirstBuild) { // if list is just initialized (first build run)
      users = Provider.of<List<User>>(context) ?? [];
      userCards = <UserCard>[];

      userList = AnimatedList( // list of users widget
        key: _animatedListKey,
        initialItemCount: userCards.length,
        // ignore: missing_return
        itemBuilder: (context, index, animation) {
          // TODO: get array of skipped users from database (user instance probably won't hold it) through FutureBuilder again maybe -> done
          // TODO: then use contains method to check rendering in if statement -> done
          // TODO: User NEVER enters this state if they have matchedUserID != null; do that check in match.dart -> done

          return SlideTransition(
            position: animation.drive(Tween<Offset>(
              begin: const Offset(1, 0),
              // represent a point in Cartesian (x-y coordinate) space; dx and dy are args for points
              end: const Offset(0, 0), // points are between 1 and 0 (use that!)
            ).chain(CurveTween(curve: Curves.decelerate))),
            child: userCards[index], // get the generated user card from here
          );
        },
      );

      return FutureBuilder<List<List<TagCard>>>(
        future: getUserTags(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            tagCards = snapshot.data;
            // -------------------
            // users
            loadListItems(currentUser, users);
            // -------------------

            // --------------------
            // user images
            images = getUserImages();
            // --------------------

            return userList;
          } else return Loading();
        }
      );// context & index of whichever item we're iterating through
    } // get the info from the stream

    return userList;
  }
}
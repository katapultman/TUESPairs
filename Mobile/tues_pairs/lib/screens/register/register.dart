import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tues_pairs/screens/loading/loading.dart';
import 'package:tues_pairs/shared/keys.dart';
import 'package:tues_pairs/shared/constants.dart';
import 'package:tues_pairs/templates/baseauth.dart';
import 'package:tues_pairs/modules/user.dart';
import 'package:tues_pairs/services/image.dart';
import 'package:tues_pairs/widgets/avatar/avatar_wrapper.dart';
import 'package:tues_pairs/widgets/form/GPA_input_field.dart';
import 'package:tues_pairs/widgets/form/input_button.dart';
import 'package:tues_pairs/widgets/form/username_input_field.dart';
import 'package:tues_pairs/widgets/form/email_input_field.dart';
import 'package:tues_pairs/widgets/form/password_input_field.dart';
import 'package:tues_pairs/widgets/form/confim_password_input_field.dart';

class Register extends StatefulWidget {
  final Function toggleView;

  Register({this.toggleView}); // create a constructor which inits this property toggleView

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final BaseAuth baseAuth = new BaseAuth();
  final ImageService imageService = new ImageService();

  @override
  Widget build(BuildContext context) {

    final users = Provider.of<List<User>>(context) ?? [];

    bool usernameExists() {
      for(User data in users ?? []) {
        if(baseAuth.user.username == data.username) {
          logger.i('Register: username already exists');
          return true;
        }
      }
      logger.i('Register: username doesn\'t exist');
      return false;
    }

    bool formIsValid() {
      final FormState formState = baseAuth.key.currentState;
      bool isValid = true;

      baseAuth.errorMessages = [''];
      if(!formState.validate()) {
        isValid = false;
        logger.w('Register: User is invalid (incorrect data entered)');
        baseAuth.errorMessages.add('Please enter correct data');
      }
      if(usernameExists()) {
        isValid = false;
        logger.w('Register: User is invalid (username already exists)');
        baseAuth.errorMessages.add('Username exists');
      }
      if(baseAuth.user.password != baseAuth.confirmPassword) {
        isValid = false;
        logger.w('Register: User is invalid (passwords do not match)');
        baseAuth.errorMessages.add('Passwords do not match');

      }

      logger.i('Register: User is valid');
      return isValid;
    }

    Future registerUser() async {
      final User registeredUser = baseAuth.user;

      if(formIsValid()) {
        final FormState formState = baseAuth.key.currentState;
        formState.save();

        setState(() => baseAuth.toggleLoading());

        // TODO: narrow these final settings of values down in function
        if(registeredUser.isTeacher) registeredUser.GPA = null;

        if(imageService != null && imageService.profileImage != null) {
          registeredUser.photoURL = await imageService.uploadImage();
        }

        User user = await baseAuth.authInstance.registerUserByEmailAndPassword(registeredUser);

        if(user == null) {
          logger.w('Register: User hasn\'t been registered (failed)');
          setState(() {
            baseAuth.errorMessages = [''];
            baseAuth.errorMessages.add('There was an error. Please try again.');
            baseAuth.toggleLoading();
          });
        }
      } else {
        setState(() {});
      }
    }
    
    return baseAuth.isLoading ? Loading() : Scaffold( // Scaffold grants the material design palette and general layout of the app (properties like appBar)
      key: Key(Keys.registerScaffold),
      backgroundColor: Color.fromRGBO(59, 64, 78, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(33, 36, 44, 1),
        title: Text(
          'Register',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          )
        ),
        // actions take a list of Widgets and are used to display available actions on the AppBar
        actions: <Widget>[
          FlatButton.icon(
            key: Key(Keys.toggleToLoginButton),
            onPressed: () {widget.toggleView();}, // since the toggleView() function is known in the context of the widget, we need to address the widget and then access it
            icon: Icon(
              Icons.lock,
              color: Colors.orange,
              size: 30.0,
            ),
            label: Text(
              'Log in',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                fontSize: 25.0,
              )
            ),
          )
        ],
      ),

      body: ListView(
        children: <Widget>[
          Container( // Container grants access to basic layout principles and properties
            color: Color.fromRGBO(59, 64, 78, 1),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Form(
                key: baseAuth.key, // set the form's key to the key defined above (keeps track of the state of the form)
                child: Column( // Column orders widgets in a Column and its children property takes a list of Widgets
                  children: <Widget>[
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Provider<ImageService>.value(
                            value: imageService,
                            child: AvatarWrapper(),
                          ),
                          Column(
                            children: baseAuth.errorMessages?.map((message) => Text(
                              "$message",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 10.0,
                              ),
                            ))?.toList() ?? [],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.0),
                    UsernameInputField(
                      key: Key(Keys.registerUsernameInputField),
                      onChanged: (value) => setState(() {baseAuth.user.username = value;}),
                    ),
                    SizedBox(height: 15.0),
                    EmailInputField(
                      key: Key(Keys.registerEmailInputField),
                      onChanged: (value) => setState(() {baseAuth.user.email = value;}),
                    ),
                    SizedBox(height: 15.0),
                    PasswordInputField(
                      key: Key(Keys.registerPasswordInputField),
                      onChanged: (value) => setState(() {baseAuth.user.password = value;}),
                    ),
                    SizedBox(height: 15.0),
                    ConfirmPasswordInputField(
                      key: Key(Keys.registerConfirmPasswordInputField),
                      onChanged: (value) => setState(() {baseAuth.confirmPassword = value;}),
                    ),
                    SizedBox(height: 15.0),
                    baseAuth.user.isTeacher ? SizedBox() : GPAInputField(
                      key: Key(Keys.registerGPAInputField),
                      onChanged: (value) => setState(() => baseAuth.user.GPA = double.tryParse(value)),
                    ),
                    SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Are you a teacher?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            fontSize: 10.0,
                          )
                        ),
                        Switch(
                          key: Key(Keys.isTeacherSwitch),
                          value: baseAuth.user.isTeacher, // has the current user selected the isTeacher property
                          onChanged: (value) => setState(() {baseAuth.user.isTeacher = value;}),  // Rerun the build method in order for the switch to actually change
                          activeColor: Colors.orange,
                        ),
                      ],
                    ),
                    SizedBox(height: 15.0),
                    InputButton(
                      key: Key(Keys.registerButton),
                      minWidth: 250.0,
                      height: 60.0,
                      text: 'Create account',
                      onPressed: registerUser,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]
      )
    );
  }
}

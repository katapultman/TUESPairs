import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tues_pairs/screens/loading/loading.dart';
import 'package:tues_pairs/shared/constants.dart';
import 'package:tues_pairs/templates/baseauth.dart';
import 'package:tues_pairs/services/auth.dart';
import 'package:tues_pairs/modules/user.dart';
import 'package:tues_pairs/services/image.dart';
import 'package:tues_pairs/widgets/avatar_wrapper.dart';
import 'package:tues_pairs/modules/student.dart';
import 'package:tues_pairs/modules/teacher.dart';
import 'package:path/path.dart';

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
      for(User data in users ?? []){
        if(baseAuth.user.username == data.username){
          return true;
        }
      }
      return false;
    }

    bool formIsValid(){
      final FormState formState = baseAuth.key.currentState;
      bool isValid = true;

      baseAuth.errorMessages = [''];
      if(!formState.validate()){
        isValid = false;
        baseAuth.errorMessages.add('Please enter correct data');
      }
      if(usernameExists()){
        isValid = false;
        baseAuth.errorMessages.add('Username exists');
      }
      if(baseAuth.user.password != baseAuth.confirmPassword){
        isValid = false;
        baseAuth.errorMessages.add('Passwords do not match');
      
      }
      return isValid;
    }

    Future registerUser() async {
      if(formIsValid()) {
        final FormState formState = baseAuth.key.currentState;
        formState.save();
        baseAuth.toggleLoading();
        baseAuth.user.photoURL = imageService.profilePicture == null ? null : basename(imageService.profilePicture.path);
        User userResult = await baseAuth.authInstance.registerUserByEmailAndPassword(baseAuth.user);
        if(userResult == null) {
          setState(() {       
            baseAuth.errorMessages = [''];
            baseAuth.errorMessages.add('There was an error please try again');
            baseAuth.toggleLoading();
          });
        } else {
          await imageService.uploadPicture();
        }
      } else {
        setState(() {});
      }
    }

    return baseAuth.isLoading ? Loading() : Scaffold(
      backgroundColor: Color.fromRGBO(59, 64, 78, 1),
      // Scaffold grants the material design palette and general layout of the app (properties like appBar)
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

      body: Container( // Container grants access to basic layout principles and properties
        color: Color.fromRGBO(59, 64, 78, 1),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Form(
            key: baseAuth.key, // set the form's key to the key defined above (keeps track of the state of the form)
            child: Column( // Column orders widgets in a Column and its children property takes a list of Widgets
              children: <Widget>[
                Center(
                  child: Row(
                    children: <Widget>[
                      AvatarWrapper(imageService: imageService),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50, left: 12.5),
                        child: Column(
                          children: baseAuth.errorMessages?.map((message) => Text(
                            "$message",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 15.0,
                            ),
                          ))?.toList() ?? [],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15.0),
                TextFormField(
                  onChanged: (value) => setState(() {baseAuth.user.username = value;}), // onChanged property takes a function with val and can be used to update our form properties with the passed values
                  // validator property is used for the validation of separate TextFormFields (takes a function with a value and you can
                  style: textInputColor,
                  validator: (value) => value.isEmpty ? 'Enter a username' : null, // validator returns string (tag to put on the field if input is invalid)
                  keyboardType: TextInputType.text, // optimize type set to e-mail
                  decoration: textInputDecoration.copyWith(
                    icon: Icon(
                      Icons.person,
                      color: Colors.orange,
                    ),
                    hintText: 'Enter a username',
                  ),
                ),
                SizedBox(height: 15.0),
                TextFormField(
                  onChanged: (value) => setState(() {baseAuth.user.email = value;}), // onChanged property takes a function with val and can be used to update our form properties with the passed values
                  style: textInputColor,
                  // validator property is used for the validation of separate TextFormFields (takes a function with a value and you can
                  validator: (value) => value.isEmpty ? 'Enter an e-mail' : null, // validator returns string (tag to put on the field if input is invalid)
                  keyboardType: TextInputType.emailAddress, // optimize type set to e-mail
                  decoration: textInputDecoration.copyWith(
                    icon: Icon(
                      Icons.mail,
                      color: Colors.orange,
                    ),
                    hintText: 'Enter an e-mail',
                  ),
                ),
                SizedBox(height: 15.0),
                TextFormField(
                  obscureText: true, // obscures text (like for a password)
                  style: textInputColor,
                  onChanged: (value) => setState(() {baseAuth.user.password = value;}),
                  validator: (value) => value.isEmpty ? 'Enter a password' : null,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: textInputDecoration.copyWith(
                    icon: Icon(
                      Icons.lock,
                      color: Colors.orange,
                    ),
                    hintText: 'Enter a password',
                  ),
                ),
                SizedBox(height: 15.0),
                TextFormField(
                  obscureText: true, // obscures text (like for a password)
                  style: textInputColor,
                  onChanged: (value) => setState(() {baseAuth.confirmPassword = value;}),
                  validator: (value) => value.isEmpty ? 'Confirm password' : null,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: textInputDecoration.copyWith(
                    icon: Icon(
                      Icons.repeat,
                      color: Colors.orange,
                    ),
                    hintText: 'Confirm password',
                  ),
                ),
                SizedBox(height: 15.0),
                baseAuth.user.isTeacher ? SizedBox() : TextFormField( // if the current user wants to be a teacher, he doesn't need GPA field
                   // parse the given string to a double
                  style: textInputColor,
                  onChanged: (value) => baseAuth.user.GPA = double.tryParse(value),
                  validator: (value) {
                    double GPA = double.tryParse(value);
                    if(GPA == null || value.isEmpty || GPA < 2 || GPA > 6){
                      return "Incorrect GPA (Range: 2 to 6)";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.number,
                  decoration: textInputDecoration.copyWith(
                    icon: Icon(
                      Icons.border_color,
                      color: Colors.orange,
                    ),
                    hintText: 'Enter GPA throughout 8-12th grade',
                  ),
                ),
                SizedBox(height: 25.0),
                Switch(
                  value: baseAuth.user.isTeacher, // has the current user selected the isTeacher property
                  onChanged: (value) => setState(() => baseAuth.user.isTeacher = value),  // Rerun the build method in order for the switch to actually change
                  activeColor: Colors.orange,
                ),
                SizedBox(height: 15.0),
                ButtonTheme(
                  minWidth: 250.0,
                  height: 60.0,
                  child: RaisedButton(
                    child: Text(
                      'Create account',
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                    ),
                    textColor: Colors.white,
                    color: Color.fromRGBO(33, 36, 44, 1),
                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    onPressed: () {
                      registerUser(); 
                    }
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

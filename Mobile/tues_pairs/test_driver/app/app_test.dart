import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:tues_pairs/shared/keys.dart';
import 'package:tues_pairs/modules/user.dart';

void main() {


  // TODO: FIX FROM AFTER REGISTRATION PAGE OVERHAUL

  final String userCardIndex = '0';

  const int waitDuration = 2000;

  // example user for auth
  final User registerUser = new User(
    email: 'example123456@gmail.com',
    username: 'example',
    GPA: 5.45, isTeacher: false,
    photoURL: null,
  );

  String registeredUserPassword = 'examplepass';

  group('App', () {

    final appFinder = find.byValueKey(Keys.app);

    final toggleToRegisterButtonFinder = find.byValueKey(Keys.toggleToRegisterButton);
    final toggleToLoginButtonFinder = find.byValueKey(Keys.toggleToLoginButton);

    final loginEmailInputFieldFinder = find.byValueKey(Keys.loginEmailInputField);
    final loginPasswordInputFieldFinder = find.byValueKey(Keys.loginPasswordInputField);
    final logInButtonFinder = find.byValueKey(Keys.logInButton);

    final registerUsernameInputFieldFinder = find.byValueKey(Keys.registerUsernameInputField);
    final registerEmailInputFieldFinder = find.byValueKey(Keys.registerEmailInputField);
    final registerPasswordInputFieldFinder = find.byValueKey(Keys.registerPasswordInputField);
    final registerConfirmPasswordInputFieldFinder = find.byValueKey(Keys.registerConfirmPasswordInputField);
    final registerGPAInputFieldFinder = find.byValueKey(Keys.registerGPAInputField);
    final isTeacherSwitchFinder = find.byValueKey(Keys.isTeacherSwitch);
    final registerButtonFinder = find.byValueKey(Keys.registerButton);

    final logOutButtonFinder = find.byValueKey(Keys.logOutButton);
    final bottomNavigationBarFinder = find.byValueKey(Keys.bottomNavigationBar);

    final matchMatchButtonFinder = find.byValueKey(Keys.matchMatchButton + userCardIndex);
    final matchSkipButtonFinder = find.byValueKey(Keys.matchSkipButton + userCardIndex);
    final matchUserCard = find.byValueKey(Keys.matchUserCard + userCardIndex);
    final matchAnimatedList = find.byType('AnimatedList');

    final settingsDeleteAccountButtonFinder = find.byValueKey(Keys.settingsDeleteAccountButton);
    final settingsClearMatchedUserButtonFinder = find.byValueKey(Keys.settingsClearMatchedUserButton);
    final settingsClearSkippedUsersButtonFinder = find.byValueKey(Keys.settingsClearSkippedUsersButton);
    final settingsSubmitButtonFinder = find.byValueKey(Keys.settingsSubmitButton);

    FlutterDriver driver; // driver that simulates I/O (pointer/tap) operations and general device interation

    // Run BEFORE all tests
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Run AFTER all tests
    tearDownAll(() async {
      if(driver != null) {
        await driver.close();
      }
    });

    // ------------------------
    // helper functions

    Future<void> delay([int milliseconds = 250]) async { // function to simulate a delay in time
      await Future<void>.delayed(Duration(milliseconds: milliseconds));
    }

    Future<void> enterTextInFieldWithDelay(SerializableFinder field, String text, {int duration = waitDuration}) async {
      await driver.tap(field);

      delay(duration);

      await driver.enterText(text);

      delay(duration);
    }

    Future<void> waitLogin() async {
      // wait to ensure we're in the sign-in page and not already auth'd
      await driver.waitFor(logInButtonFinder);
      await driver.waitFor(loginEmailInputFieldFinder);
      await driver.waitFor(loginPasswordInputFieldFinder);
    }

    Future<void> logInWithLoginTestUser() async {
      await waitLogin();

      delay(waitDuration);

      await enterTextInFieldWithDelay(loginEmailInputFieldFinder, registerUser.email);

      await enterTextInFieldWithDelay(loginPasswordInputFieldFinder, registeredUserPassword);

      await driver.tap(logInButtonFinder);
    }

    Future<void> logOut() async {
      delay(waitDuration);

      await driver.waitFor(logOutButtonFinder);

      delay(waitDuration*2);

      await driver.tap(logOutButtonFinder);
    }

    Future<void> registerTestUser() async {
      await waitLogin();

      await driver.waitFor(toggleToRegisterButtonFinder);

      delay(waitDuration);

      // switch to sign-up page
      await driver.tap(toggleToRegisterButtonFinder);

      delay(waitDuration);

      // wait for the rendering of all the necessary widgets
      await driver.waitFor(registerUsernameInputFieldFinder);
      await driver.waitFor(registerEmailInputFieldFinder);
      await driver.waitFor(registerPasswordInputFieldFinder);
      await driver.waitFor(registerConfirmPasswordInputFieldFinder);
      await driver.waitFor(registerGPAInputFieldFinder);
      await driver.waitFor(isTeacherSwitchFinder);
      await driver.waitFor(registerButtonFinder);

      delay(waitDuration);

      await enterTextInFieldWithDelay(registerUsernameInputFieldFinder, registerUser.username);

      delay(waitDuration);

      await enterTextInFieldWithDelay(registerEmailInputFieldFinder, registerUser.email);

      delay(waitDuration);

      await enterTextInFieldWithDelay(registerPasswordInputFieldFinder, registeredUserPassword);

      delay(waitDuration);

      await enterTextInFieldWithDelay(registerConfirmPasswordInputFieldFinder, registeredUserPassword);

      delay(waitDuration);

      await enterTextInFieldWithDelay(registerGPAInputFieldFinder, registerUser.GPA.toString());

      delay(waitDuration);

      await driver.tap(registerButtonFinder);
    }

    Future<void> navigateToPage(String page) async {
      delay(waitDuration);

      // wait for the rendering of navbar
      await driver.waitFor(bottomNavigationBarFinder);

      delay(waitDuration);

      await driver.tap(find.text(page)); // botoomnavbar items don't have key properties, sadly

      delay(waitDuration);
    }

    Future<void> findAndTapButton(SerializableFinder button) async {
      await driver.waitFor(button);

      delay(waitDuration);

      await driver.tap(button);
    }

    Future<void> navigateToPageAndTapButton(SerializableFinder button, String page) async {
      delay(waitDuration);

      await navigateToPage(page);

      delay(waitDuration);

      await findAndTapButton(button);
    }
    // ------------------------

    // tests

    test('Initial app boot test', () async {
      await driver.waitFor(appFinder);
    });

    test('register, sign out', () async {
      await registerTestUser();

      await logOut();

    });

    test('sign in, sign out', () async {
      await logInWithLoginTestUser();

      await logOut();

    });

    test('match with first user and clear match in settings', () async {
      await logInWithLoginTestUser();

      await navigateToPageAndTapButton(settingsClearMatchedUserButtonFinder, 'Settings');

      await navigateToPage('Match');

      delay(waitDuration);

      await driver.waitFor(matchAnimatedList, timeout: Duration(milliseconds: waitDuration*5));

      delay(waitDuration);

      await findAndTapButton(matchMatchButtonFinder);

      await navigateToPageAndTapButton(settingsClearMatchedUserButtonFinder, 'Settings');

      await logOut();

    });

    test('skip first user and clear skipped users', () async {
      await logInWithLoginTestUser();

      await navigateToPageAndTapButton(settingsClearSkippedUsersButtonFinder, 'Settings');

      await navigateToPage('Match');

      await driver.waitFor(matchAnimatedList, timeout: Duration(milliseconds: waitDuration*5));

      delay(waitDuration);

      await findAndTapButton(matchSkipButtonFinder);

      await navigateToPageAndTapButton(settingsClearSkippedUsersButtonFinder, 'Settings');

      await logOut();

    });

    test('sign in, delete', () async {
      await logInWithLoginTestUser();

      await navigateToPageAndTapButton(settingsDeleteAccountButtonFinder, 'Settings');

    });

    test('Check flutter driver health', () async {
      final health = await driver.checkHealth();
      expect(health.status, HealthStatus.ok);
    });

  });
}
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mister/controllers/stores/account.dart';
import 'package:mister/controllers/stores/autonomous.dart';
import 'package:mister/controllers/stores/theme.dart';

import 'package:mister/models/utils/constants.dart';
import 'package:mister/models/routes/app_routes.dart';

import 'package:mister/views/screens/initial.dart';
import 'package:mister/views/screens/sign_in.dart';
import 'package:mister/views/screens/sign_up.dart';
import 'package:mister/views/screens/main.dart';
import 'package:mister/views/screens/autonomous_details.dart';
import 'package:mister/views/screens/edit_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final GetIt getIt = GetIt.I;

  getIt.registerLazySingleton<AccountStore>(() => AccountStore());
  getIt.registerLazySingleton<AutonomousStore>(() => AutonomousStore());
  getIt.registerLazySingleton<ThemeStore>(() => ThemeStore());

  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final String? isLogged = preferences.getString(StoragedValues.userUID);

  runApp(App(isLogged: isLogged));
}

class App extends StatelessWidget {
  App({Key? key, required this.isLogged}) : super(key: key);

  final String? isLogged;
  final ThemeStore _themeStore = GetIt.I.get<ThemeStore>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return Observer(
      builder: (_) => MaterialApp(
        title: 'Mister',
        themeMode: _themeStore.isDark ? ThemeMode.dark : ThemeMode.light,
        home: isLogged != null ? const MainScreen() : InitialScreen(),
        routes: {
          AppRoutes.initialScreen: (_) => InitialScreen(),
          AppRoutes.signInScreen: (_) => const SignInScreen(),
          AppRoutes.signUpScreen: (_) => const SignUpScreen(),
          AppRoutes.mainScreen: (_) => const MainScreen(),
          AppRoutes.autonomousDetailsScreen: (_) => AutonomousDetailsScreen(),
          AppRoutes.editProfileScreen: (_) => const EditProfileScreen(),
        },
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_app_project/home/home_screen.dart';
import 'package:to_do_app_project/login/login_screen.dart';
import 'package:to_do_app_project/providers/app_config_provider.dart';
import 'package:to_do_app_project/providers/auth_provider.dart';
import 'package:to_do_app_project/providers/list_provider.dart';
import 'package:to_do_app_project/register/register_screen.dart';

import 'home/task_list/task_details_screen.dart';
import 'my_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // The default value is 40 MB. The threshold must be set to at least 1 MB,
// and can be set to Settings.CACHE_SIZE_UNLIMITED to disable garbage collection.

  //FirebaseFirestore.instance.settings =
  //   Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  //await FirebaseFirestore.instance.disableNetwork();

  final prefs = await SharedPreferences.getInstance();
  final prefsTheme = await SharedPreferences.getInstance();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => AppConfigProvider(prefs, prefsTheme),
      ),
      ChangeNotifierProvider(create: (context) => AuthhProvider()),
      ChangeNotifierProvider(create: (context) => ListProvider())
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppConfigProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: LoginScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => HomeScreen(),
        EditTaskScreen.routeName: (context) => EditTaskScreen(),
        LoginScreen.routeName: (context) => LoginScreen(),
        RegisterScreen.routeName: (context) => RegisterScreen()
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: MyTheme.LightTheme,
      locale: Locale(provider.appLanguage),
      darkTheme: MyTheme.darkTheme,
      themeMode: provider.appTheme,
    );
  }
}

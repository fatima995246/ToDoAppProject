import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app_project/components/custom_text_form_field.dart';
import 'package:to_do_app_project/firebase_utils.dart';
import 'package:to_do_app_project/my_theme.dart';
import 'package:to_do_app_project/register/register_screen.dart';

import '../dialog_utlis.dart';
import '../home/home_screen.dart';
import '../providers/app_config_provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = 'login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var emailController = TextEditingController(text: 'smsm@gmail.com');
  var passwordController = TextEditingController(text: '123456');
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppConfigProvider>(context);
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/main_background.png',
            width: double.infinity,
            fit: BoxFit.fill,
          ),
          Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                    ),
                    CustomTextFormField(
                      lable: AppLocalizations.of(context)!.emailaddress,
                      controller: emailController,
                      myValidator: (text) {
                        if (text == null || text.trim().isEmpty) {
                          return AppLocalizations.of(context)!
                              .pleaseenteremailaddress;
                        }
                        bool emailValid = RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(text);
                        if (!emailValid) {
                          return AppLocalizations.of(context)!
                              .pleaseentervalidemailaddress;
                        }
                        return null;
                      },
                    ),
                    CustomTextFormField(
                      lable: AppLocalizations.of(context)!.password,
                      controller: passwordController,
                      isPassword: true,
                      keyboardTybe: TextInputType.number,
                      myValidator: (text) {
                        if (text == null || text.trim().isEmpty) {
                          return AppLocalizations.of(context)!
                              .pleaseenterpassword;
                        }
                        if (text.length < 6) {
                          return AppLocalizations.of(context)!
                              .passwordshouldbeatleastchars;
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () {
                            login();
                          },
                          child: Text(
                            AppLocalizations.of(context)!.login,
                            style: Theme.of(context).textTheme.titleLarge,
                          )),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.donthaveanaccount,
                            style: Theme.of(context).textTheme.titleMedium),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(RegisterScreen.routeName);
                            },
                            child: Text(AppLocalizations.of(context)!.signup,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(color: MyTheme.primaryLight)))
                      ],
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Future<void> login() async {
    if (formKey.currentState?.validate() == true) {
      DialogUtils.showLoading(context, AppLocalizations.of(context)!.loading);
      try {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);
        var user = await FirebaseUtils.readUserFromFireStore(
            credential.user?.uid ?? '');
        if (user == null) {
          //user authenticated but not found in db.
          return DialogUtils.showMessage(
              context, AppLocalizations.of(context)!.nulluser);
        }
        var authprovider = Provider.of<AuthhProvider>(context, listen: false);
        authprovider.updateUser(user);
        //hide loading
        DialogUtils.hideLoading(context);
        //show message
        DialogUtils.showMessage(
            context, AppLocalizations.of(context)!.loginsuccesses,
            title: 'success',
            posActionName: AppLocalizations.of(context)!.ok, posAction: () {
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        });
        print('login successes');
      } on FirebaseAuthException catch (e) {
        //hide loading
        DialogUtils.hideLoading(context);

        if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
          DialogUtils.showMessage(context,
              '${AppLocalizations.of(context)!.nouserfoundforthatemail} or ${AppLocalizations.of(context)!.wrongpasswordprovidedforthatuser}',
              negActionName: AppLocalizations.of(context)!.tryagain,
              negAction: () {
            Navigator.of(context).pushNamed(RegisterScreen.routeName);
          });
          print('No user found for that email.');
        }
      } catch (e) {
        DialogUtils.showMessage(context, e.toString(),
            negActionName: AppLocalizations.of(context)!.tryagain,
            negAction: () {
          Navigator.of(context).pushNamed(RegisterScreen.routeName);
        });
        print(e.toString());
      }
    }
  }
}

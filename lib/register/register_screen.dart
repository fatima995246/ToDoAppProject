import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app_project/components/custom_text_form_field.dart';
import 'package:to_do_app_project/dialog_utlis.dart';
import 'package:to_do_app_project/firebase_utils.dart';
import 'package:to_do_app_project/login/login_screen.dart';
import 'package:to_do_app_project/model/my_users.dart';
import 'package:to_do_app_project/providers/auth_provider.dart';

import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = 'register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  var nameController = TextEditingController();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  var confermationPasswordController = TextEditingController();

  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
                      lable: AppLocalizations.of(context)!.username,
                      controller: nameController,
                      myValidator: (text) {
                        if (text == null || text.trim().isEmpty) {
                          return AppLocalizations.of(context)!
                              .pleaseenterusername;
                        }
                        return null;
                      },
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
                    CustomTextFormField(
                      lable: AppLocalizations.of(context)!.confermationpassword,
                      controller: confermationPasswordController,
                      isPassword: true,
                      keyboardTybe: TextInputType.number,
                      myValidator: (text) {
                        if (text == null || text.trim().isEmpty) {
                          return AppLocalizations.of(context)!
                              .pleaseenterconfermationpassword;
                        }
                        if (text != passwordController.text) {
                          return AppLocalizations.of(context)!
                              .passworddoesntmatch;
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () {
                            register();
                          },
                          child: Text(
                            AppLocalizations.of(context)!.register,
                            style: Theme.of(context).textTheme.titleLarge,
                          )),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(LoginScreen.routeName);
                        },
                        child: Text(
                            AppLocalizations.of(context)!.allreadyhaveanaccount,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                    color: Theme.of(context).primaryColor)))
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Future<void> register() async {
    if (formKey.currentState?.validate() == true) {
      //register
      //loading
      DialogUtils.showLoading(context, AppLocalizations.of(context)!.loading);
      try {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);
        MyUser myUser = MyUser(
            id: credential.user?.uid ?? '',
            name: nameController.text,
            email: emailController.text);
        //provider declaration outside the build fun
        var authprovider = Provider.of<AuthhProvider>(context, listen: false);
        authprovider.updateUser(myUser);
        await FirebaseUtils.addUserToFireStore(myUser);

        //hide loading
        DialogUtils.hideLoading(context);

        //show message
        DialogUtils.showMessage(
            context, AppLocalizations.of(context)!.registeredsuccessfully,
            title: 'success',
            posActionName: AppLocalizations.of(context)!.ok, posAction: () {
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        });

        print(credential.user?.uid ?? '');
      } on FirebaseAuthException catch (e) {
        //hide loading
        DialogUtils.hideLoading(context);
        //show error message
        String errorMessage = 'something went wrong';
        if (e.code == 'weak-password') {
          errorMessage = AppLocalizations.of(context)!.passwordistooweak;
          DialogUtils.showMessage(context, errorMessage,
              negActionName: AppLocalizations.of(context)!.tryagain,
              negAction: () {
            Navigator.of(context).pushNamed(RegisterScreen.routeName);
          });
          print(errorMessage);
        } else if (e.code == 'email-already-in-use') {
          errorMessage =
              AppLocalizations.of(context)!.theaccountallreadyexistforthisemail;
          DialogUtils.showMessage(context, errorMessage,
              negActionName: AppLocalizations.of(context)!.tryagain,
              negAction: () {
            Navigator.of(context).pushNamed(RegisterScreen.routeName);
          });
          print(errorMessage);
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

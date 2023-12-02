import 'package:flutter/cupertino.dart';
import 'package:to_do_app_project/model/my_users.dart';

class AuthProvider extends ChangeNotifier {
  MyUser? currentUser;

  void updateUser(MyUser newUser) {
    currentUser = newUser;
    notifyListeners();
  }
}

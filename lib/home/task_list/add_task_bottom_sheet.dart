import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app_project/dialog_utlis.dart';
import 'package:to_do_app_project/firebase_utils.dart';
import 'package:to_do_app_project/model/task.dart';
import 'package:to_do_app_project/my_theme.dart';
import 'package:to_do_app_project/providers/list_provider.dart';

import '../../providers/app_config_provider.dart';
import '../../providers/auth_provider.dart';
import '../home_screen.dart';

class AddTaskBottomSheet extends StatefulWidget {
  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  DateTime selectedDate = DateTime.now();

  var formKey = GlobalKey<FormState>();

  // String formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate);
  String title = '';

  String description = '';

  late AppConfigProvider provider;
  late ListProvider Listprovider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AppConfigProvider>(context);

    return Container(
      color: provider.isDarkMode()
          ? Theme.of(context).primaryColor
          : MyTheme.whiteColor,
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          Text(AppLocalizations.of(context)!.addnewtask,
              style: Theme.of(context).textTheme.titleMedium),
          Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      onChanged: (text) {
                        title = text;
                      },
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return AppLocalizations.of(context)!
                              .pleaseentertasktitle;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          hintText:
                              (AppLocalizations.of(context)!.entertasktitle),
                          hintStyle: Theme.of(context).textTheme.titleMedium),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      onChanged: (text) {
                        description = text;
                      },
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return AppLocalizations.of(context)!
                              .pleaseentertaskdescription;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          hintText: (AppLocalizations.of(context)!
                              .entertaskdescription),
                          hintStyle: Theme.of(context).textTheme.titleMedium),
                      maxLines: 4,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(AppLocalizations.of(context)!.selectdate,
                        style: Theme.of(context).textTheme.titleSmall),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        //show calender
                        showCalender();
                      },
                      child: Text(
                        '${selectedDate.day}/${selectedDate.month}'
                        '/${selectedDate.year}',
                        style: Theme.of(context).textTheme.titleSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              MyTheme.primaryLight)),
                      onPressed: () {
                        //  add task to firebase
                        addTask();
                      },
                      child: Text(
                        AppLocalizations.of(context)!.add,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontSize: 22),
                      ))
                ],
              )),
        ],
      ),
    );
  }

  void showCalender() async {
    var chosenDate = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 365)));
    if (chosenDate != null) {
      selectedDate = chosenDate;
      setState(() {});
    }
  }

  void addTask() async {
    if (formKey.currentState?.validate() == true) {
      //add task
      Task task =
          Task(dateTime: selectedDate, title: title, description: description);
      var authprovider = Provider.of<AuthhProvider>(context, listen: false);
      DialogUtils.showLoading(context, 'Loading...');
      await FirebaseUtils.addTaskToFirebase(task, authprovider.currentUser!.id!)
          .then((value) {
        DialogUtils.hideLoading(context);
        Navigator.pop(context);
        DialogUtils.showMessage(
            context, AppLocalizations.of(context)!.todoaddedsuccessfully,
            title: 'success',
            isDismissible: true,
            posActionName: AppLocalizations.of(context)!.ok, posAction: () {
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        });
      }).timeout(Duration(milliseconds: 500), onTimeout: () {
        print("todo added successfully");
        Listprovider.getAllTasksFromFireStore(authprovider.currentUser!.id!);
        Navigator.pop(context);
      });
    }
  }
}

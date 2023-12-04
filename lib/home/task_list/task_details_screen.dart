import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app_project/dialog_utlis.dart';
import 'package:to_do_app_project/firebase_utils.dart';
import 'package:to_do_app_project/my_theme.dart';

import '../../model/task.dart';
import '../../providers/app_config_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/list_provider.dart';
import '../home_screen.dart';

class EditTaskScreen extends StatefulWidget {
  static const String routeName = 'Task_details';

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  DateTime selectedDate = DateTime.now();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  late ListProvider Listprovider;
  late Task task;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      task = ModalRoute.of(context)!.settings.arguments as Task;
      titleController.text = task.title!;
      descriptionController.text = task.description!;
      selectedDate = task.dateTime!;
    });
  }

  Widget build(BuildContext context) {
    var provider = Provider.of<AppConfigProvider>(context);
    return Stack(children: [
      Scaffold(
          backgroundColor: provider.isDarkMode()
              ? MyTheme.backgroundDark
              : MyTheme.backgroundLight,
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.app_title,
                style: Theme.of(context).textTheme.titleLarge),
          ),
          body: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: provider.isDarkMode()
                      ? MyTheme.blackColor
                      : MyTheme.whiteColor,
                  borderRadius: BorderRadius.circular(25)),
              margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.09,
                  horizontal: MediaQuery.of(context).size.width * 0.06),
              child: Column(children: [
                Text(AppLocalizations.of(context)!.edittask,
                    style: Theme.of(context).textTheme.titleMedium),
                Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: titleController,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return AppLocalizations.of(context)!
                                    .pleaseentertasktitle;
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                hintText: (AppLocalizations.of(context)!
                                    .entertasktitle),
                                hintStyle:
                                    Theme.of(context).textTheme.titleMedium),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: descriptionController,
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
                                hintStyle:
                                    Theme.of(context).textTheme.titleMedium),
                            maxLines: 4,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            AppLocalizations.of(context)!.selectdate,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
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
                        SizedBox(height: 60),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          MyTheme.primaryLight),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                          side: BorderSide(
                                              color: MyTheme.primaryLight)))),
                              onPressed: () {
                                //var args = ModalRoute.of(context)?.settings.arguments as Task;
                                //  edit task to firebase
                                editTask();
                              },
                              child: Text(
                                AppLocalizations.of(context)!.savechanges,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(color: MyTheme.whiteColor),
                              )),
                        )
                      ],
                    )),
              ])))
    ]);
  }

  void showCalender() async {
    var chosenDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 365)));
    if (chosenDate != null) {
      selectedDate = chosenDate;
      setState(() {});
    }
  }

  void editTask() {
    if (formKey.currentState?.validate() == true) {
      task.title = titleController.text;
      task.description = descriptionController.text;
      task.dateTime = selectedDate;
      DialogUtils.showLoading(context, AppLocalizations.of(context)!.loading);
      var authprovider = Provider.of<AuthhProvider>(context, listen: false);
      FirebaseUtils.editTask(task, authprovider.currentUser!.id!).then((value) {
        DialogUtils.hideLoading(context);
        Navigator.pop(context);
        DialogUtils.showMessage(
            context, AppLocalizations.of(context)!.todoeditedsuccessfully,
            title: 'success',
            isDismissible: true,
            posActionName: AppLocalizations.of(context)!.ok, posAction: () {
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        });
      }).timeout(Duration(milliseconds: 500), onTimeout: () {
        print("todo edited successfully");
        Listprovider.getAllTasksFromFireStore(authprovider.currentUser!.id!);
        Navigator.pop(context);
      });
    }
  }
}

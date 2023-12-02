import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app_project/firebase_utils.dart';
import 'package:to_do_app_project/home/task_list/task_details_screen.dart';
import 'package:to_do_app_project/my_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:to_do_app_project/providers/list_provider.dart';
import '../../model/task.dart';
import '../../providers/app_config_provider.dart';
import '../../providers/auth_provider.dart';

class TaskWidget extends StatefulWidget {
  Task task;

  TaskWidget({required this.task});

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppConfigProvider>(context);
    var Listprovider = Provider.of<ListProvider>(context);
    var authprovider = Provider.of<AuthProvider>(context);

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, TaskDetailsScreen.routeName,
            arguments: widget.task);
      },
      child: Container(
        margin: EdgeInsets.all(12),
        child: Slidable(
          startActionPane: ActionPane(
            extentRatio: 0.25,
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                borderRadius: BorderRadius.circular(15),
                onPressed: (context) {
                  var authprovider =
                      Provider.of<AuthProvider>(context, listen: false);
                  FirebaseUtils.deleteTaskFromFireStore(
                          widget.task, authprovider.currentUser!.id!)
                      .timeout(Duration(milliseconds: 500), onTimeout: () {
                    print("todo deleted successfully");
                    Listprovider.getAllTasksFromFireStore(
                        authprovider.currentUser!.id!);
                  });
                },
                backgroundColor: MyTheme.redColor,
                foregroundColor: MyTheme.whiteColor,
                icon: Icons.delete,
                label: AppLocalizations.of(context)!.delete,
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: provider.isDarkMode()
                    ? Theme.of(context).primaryColor
                    : MyTheme.whiteColor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  color: widget.task.isDone!
                      ? MyTheme.greenLight
                      : MyTheme.primaryLight,
                  height: 80,
                  width: 5,
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.task.title ?? '',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: widget.task.isDone!
                                ? MyTheme.greenLight
                                : MyTheme.primaryLight),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(widget.task.description ?? '',
                          style: Theme.of(context).textTheme.titleSmall),
                    ),
                  ],
                )),
                InkWell(
                  onTap: () {
                    widget.task.isDone = !widget.task.isDone!;
                    FirebaseUtils.editIsDone(
                        widget.task, authprovider.currentUser!.id!);
                    setState(() {});
                  },
                  child: widget.task.isDone!
                      ? Text(
                          "Done!",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: MyTheme.greenLight),
                        )
                      : Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 21, vertical: 7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: MyTheme.primaryLight,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 35,
                            color: MyTheme.whiteColor,
                          )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

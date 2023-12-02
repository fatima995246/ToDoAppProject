import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app_project/home/task_list/task_widget.dart';
import 'package:to_do_app_project/my_theme.dart';
import 'package:to_do_app_project/providers/list_provider.dart';

import '../../providers/app_config_provider.dart';
import '../../providers/auth_provider.dart';

class TaskListTab extends StatefulWidget {
  @override
  State<TaskListTab> createState() => _TaskListTabState();
}

class _TaskListTabState extends State<TaskListTab> {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppConfigProvider>(context);
    var Listprovider = Provider.of<ListProvider>(context);
    var authprovider = Provider.of<AuthProvider>(context);

    if (Listprovider.taskList.isEmpty) {
      Listprovider.getAllTasksFromFireStore(authprovider.currentUser!.id!);
    }
    return Column(
      children: [
        CalendarTimeline(
          initialDate: Listprovider.selectedDate,
          firstDate: DateTime.now().subtract(Duration(days: 365)),
          lastDate: DateTime.now().add(Duration(days: 365)),
          onDateSelected: (date) {
            Listprovider.setNewSelectedDate(
                date, authprovider.currentUser!.id!);
          },
          leftMargin: 20,
          monthColor: MyTheme.blackColor,
          dayColor: MyTheme.blackColor,
          activeDayColor: MyTheme.whiteColor,
          activeBackgroundDayColor: Theme.of(context).primaryColor,
          dotsColor: MyTheme.whiteColor,
          selectableDayPredicate: (date) => true,
          locale: 'en_ISO',
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              return TaskWidget(
                task: Listprovider.taskList[index],
              );
            },
            itemCount: Listprovider.taskList.length,
          ),
        ),
      ],
    );
  }
}

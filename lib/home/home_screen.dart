import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app_project/home/settings/settings_tab.dart';
import 'package:to_do_app_project/home/task_list/add_task_bottom_sheet.dart';
import 'package:to_do_app_project/home/task_list/task_list.dart';
import 'package:to_do_app_project/login/login_screen.dart';
import 'package:to_do_app_project/my_theme.dart';
import 'package:to_do_app_project/providers/auth_provider.dart';
import 'package:to_do_app_project/providers/list_provider.dart';

import '../providers/app_config_provider.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = 'home_screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppConfigProvider>(context);
    var authprovider = Provider.of<AuthhProvider>(context);
    var listprovider = Provider.of<ListProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${AppLocalizations.of(context)!.app_title}${' '}${authprovider.currentUser!.name}',
            style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
              onPressed: () {
                listprovider.taskList = [];
                authprovider.currentUser = null;
                Navigator.pushNamed(context, LoginScreen.routeName);
              },
              icon: Icon(Icons.logout))
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: provider.isDarkMode()
            ? Theme.of(context).primaryColor
            : MyTheme.whiteColor,
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            selectedIndex = index;
            setState(() {});
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: AppLocalizations.of(context)!.tasklist),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: AppLocalizations.of(context)!.settings)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: StadiumBorder(
            side: BorderSide(
                color: provider.isDarkMode()
                    ? Theme.of(context).primaryColor
                    : MyTheme.whiteColor,
                width: 6)),
        onPressed: () {
          showAppTaskBottomSheet();
        },
        child: Icon(
          Icons.add,
          size: 30,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: tabs[selectedIndex],
    );
  }

  List<Widget> tabs = [TaskListTab(), SettingsTab()];

  void showAppTaskBottomSheet() {
    showModalBottomSheet(
        context: context, builder: (context) => AddTaskBottomSheet());
  }
}

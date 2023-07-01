import 'package:flutter/material.dart';
import 'package:my_financial/screen/category/list.dart';
import 'package:my_financial/screen/profile/profile.dart';
import 'package:my_financial/screen/dashboard/dashboard.dart';
import 'package:my_financial/screen/expense/list.dart';
import 'package:my_financial/screen/expense/list2.dart';
import 'package:my_financial/screen/income/list.dart';

enum AppMenuItem {
  dashboard,
  expense,
  expense2,
  budget,
  income,
  profile,
}

class _AppMenuBottom {
  // bottom menu display info
  static Map<AppMenuItem, BottomNavigationBarItem> menu =
      <AppMenuItem, BottomNavigationBarItem>{
    AppMenuItem.dashboard: const BottomNavigationBarItem(
      icon: Icon(Icons.bar_chart),
      label: 'Dashboard',
    ),
    AppMenuItem.expense: const BottomNavigationBarItem(
      icon: Icon(Icons.shopping_bag_outlined),
      label: 'Expense',
    ),
    AppMenuItem.expense2: const BottomNavigationBarItem(
      icon: Icon(Icons.list),
      label: 'Expense',
    ),
    AppMenuItem.budget: const BottomNavigationBarItem(
      icon: Icon(Icons.category_outlined),
      label: 'Category',
    ),
    AppMenuItem.income: const BottomNavigationBarItem(
      icon: Icon(Icons.save_alt_outlined),
      label: 'Income',
    ),
    AppMenuItem.profile: const BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      label: 'Settings',
    ),
  };
  static List<AppMenuItem> menuKeys = menu.keys.toList();
  static List<BottomNavigationBarItem> menuValues = menu.values.toList();

  // navigation info
  static Map<AppMenuItem, Widget> navigationWidgets = <AppMenuItem, Widget>{
    AppMenuItem.dashboard: const DashboardPage(),
    AppMenuItem.budget: const CategoryListPage(),
    AppMenuItem.profile: const ProfilePage(), 
    AppMenuItem.income: const IncomeListPage(), 
    AppMenuItem.expense: const ExpenseListPage(),
    AppMenuItem.expense2: const Expense2ListPage(),
  };
}

class MenuBottom extends StatelessWidget {
  final AppMenuItem menuName;
  const MenuBottom({required this.menuName, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        currentIndex: _AppMenuBottom.menuKeys.indexOf(menuName),
        // this is needed when there are more than 3 item in the list
        type: BottomNavigationBarType.fixed,
        items: _AppMenuBottom.menuValues,
        onTap: (index) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              // in case of non-existing index
              if (index >= _AppMenuBottom.menuKeys.length) index = 0;
              // get the menu name from index
              AppMenuItem selectedName = _AppMenuBottom.menuKeys[index];
              return _AppMenuBottom.navigationWidgets[selectedName]!;
            }),
          );
        });
  }
}

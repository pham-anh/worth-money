import 'dart:core';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_financial/model/currency.dart';
import '../../model/ex.dart';
import '../../screen/income/update.dart';

import '../../model/income.dart';
import '../../model/user.dart';
import '../../shared/app_theme.dart';
import '../../shared/menu_bottom.dart';
import '../dashboard/dashboard.dart';
import 'add.dart';

class IncomeListPage extends StatelessWidget {
  const IncomeListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.show_chart),
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const DashboardPage(
                initialPage: 0,
              ),
            ));
          },
        ),
        title: const Text('Income'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const IncomeAddPage(),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const MenuBottom(menuName: AppMenuItem.income),
      body: FutureBuilder(
          future: Future.wait([
            AppUser.getCurrency(),
            Income.listAllMonths(),
          ]),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Could not load incomes'));
            }
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              String? currency;
              List<MonthlyIncomeDetail> list = [];
              if (snapshot.data[0].isNotEmpty) {
                currency = snapshot.data[0];
              }
              if (snapshot.data[1].isNotEmpty) {
                list = snapshot.data[1] as List<MonthlyIncomeDetail>;
              }
              if (list.isEmpty) {
                return const Center(
                    child: Text('No incomes. Let\'s add some.'));
              }
              return ListView.builder(
                itemCount: list.length,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemBuilder: (context, i) {
                  return _buildOneMonth(context, list[i], currency);
                },
              );
            }

            return const Center(child: CircularProgressIndicator());
          }),
    );
  }

  FutureBuilder _buildOneMonth(
      BuildContext context, MonthlyIncomeDetail monthIncome, String? currency) {
    return FutureBuilder(
        future: Expense.sumOneMonth(monthIncome.children[0].ts.toDate()),
        builder: (BuildContext builder, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load incomes'));
          }

          var month = monthIncome.children[0].ts.toDate();
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            num totalExpense = snapshot.data;
            if (totalExpense != 0) {
              num balance = monthIncome.total - totalExpense;
              return ExpansionTile(
                subtitle: Text(
                  "Balance: ${Currency.getIntlMoney(balance, currency)}",
                  style: TextStyle(
                      color: balance > 0
                          ? MyAppTheme.myPrimarySwatch.shade500
                          : Theme.of(context).colorScheme.error),
                ),
                leading: const Icon(Icons.calendar_month),
                childrenPadding: const EdgeInsets.all(0),
                initiallyExpanded: true,
                title:
                    Text(DateFormat.yMMMM().format(month)),
                trailing:
                    Text(Currency.getIntlMoney(monthIncome.total, currency)),
                children: _buildChildrenIncome(
                    context, monthIncome.children, currency),
              );
            }
          }

          return ExpansionTile(
            leading: const Icon(Icons.calendar_month),
            childrenPadding: const EdgeInsets.all(0),
            initiallyExpanded: false,
            title: Text(DateFormat.yMMMM().format(month)),
            trailing: Text(Currency.getIntlMoney(monthIncome.total, currency)),
            children:
                _buildChildrenIncome(context, monthIncome.children, currency),
          );
        });
  }

  List<ListTile> _buildChildrenIncome(
      BuildContext context, List<Income> children, String? currency) {
    List<ListTile> list = [];
    for (var child in children) {
      var tile = ListTile(
        title: Text(child.description),
        subtitle: Text(DateFormat.MMMEd().format(child.ts.toDate())),
        trailing: Text(Currency.getIntlMoney(child.amount, currency)),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => IncomeUpdatePage(
              amount: child.amount,
              ts: child.ts,
              description: child.description,
              id: child.id!,
            ),
          ));
        },
      );

      list.add(tile);
    }

    return list;
  }
}

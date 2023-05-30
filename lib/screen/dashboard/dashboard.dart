import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_financial/screen/dashboard/chart_io.dart';
import '../../model/_shared.dart';
import '../../model/ex.dart';
import '../../model/user.dart';
import '../../shared/menu_bottom.dart';
import 'chart_category.dart';
import 'chart_importance.dart';

class DashboardPage extends StatefulWidget {
  final int initialPage;
  const DashboardPage({this.initialPage = 0, Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashboardPage> {
  late final DateTime now, oneMonthAgo, twoMonthAgo;
  late final PageController controller;
  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    oneMonthAgo = Shared.getOneMonthAgo(now);
    twoMonthAgo = Shared.getOneMonthAgo(oneMonthAgo);
    controller = PageController(initialPage: widget.initialPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dashboard'),
      ),
      body: FutureBuilder(
        future: Future.wait([
          Expense.listOneMonth(now),
          Expense.listOneMonth(oneMonthAgo),
          Expense.listOneMonth(twoMonthAgo),
          AppUser.getCurrency(),
        ]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            List<Expense> thisMonthData = [];
            List<Expense> lastMonthData = [];
            String? currency;
            if (snapshot.data[0].isNotEmpty) {
              thisMonthData = snapshot.data[0] as List<Expense>;
            }
            if (snapshot.data[1].isNotEmpty) {
              lastMonthData = snapshot.data[1] as List<Expense>;
            }
            if (snapshot.data[2].isNotEmpty) {
            }
            if (snapshot.data[3].isNotEmpty) {
              currency = snapshot.data[3] as String;
            }

            // if this month has data then show it and last month then return
            if (thisMonthData.isNotEmpty) {
              var month =
                  DateFormat.MMMM().format(thisMonthData[0].ts.toDate());
              return PageView(
                controller: controller,
                scrollDirection: Axis.horizontal,
                children: [
                  const ChartMonthlyIO(),
                  ChartByImportance(
                    data: thisMonthData,
                    title: 'Importance $month',
                    currency: currency,
                  ),
                  // BarChartByImportance(
                  //   data: thisMonthData,
                  //   dataToCompare: lastMonthData,
                  //   title: 'Importance ' + month,
                  //   currency: currency,
                  // ),
                  ChartByCategory(
                    data: thisMonthData,
                    title: 'Category $month',
                    currency: currency,
                  ),
                  ChartByCategory(
                    data: lastMonthData,
                    title: 'Category ${DateFormat.MMMM().format(lastMonthData[0].ts.toDate())}',
                    currency: currency,
                  ),
                ],
              );
            }
            // else if last month has data then show it and the previous month, then return
            if (lastMonthData.isNotEmpty) {
              var month =
                  DateFormat.MMMM().format(lastMonthData[0].ts.toDate());
              return PageView(
                controller: controller,
                scrollDirection: Axis.horizontal,
                children: [
                  const ChartMonthlyIO(),
                  ChartByImportance(
                    data: lastMonthData,
                    title: 'Importance $month',
                    currency: currency,
                  ),
                  // BarChartByImportance(
                  //   data: lastMonthData,
                  //   dataToCompare: lastTwoMonthData,
                  //   title: 'Importance ' + month,
                  //   currency: currency,
                  // ),
                  ChartByCategory(
                    data: lastMonthData,
                    title: 'Category $month',
                    currency: currency,
                  ),
                ],
              );
            }

            // if both this month and last month has no data then show nothing
            return const Center(
                child: Text(
              'Not enough data for analytics.\nLet\'s add some budgets and expenses.',
              textAlign: TextAlign.center,
            ));
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: const MenuBottom(menuName: AppMenuItem.dashboard),
    );
  }
}

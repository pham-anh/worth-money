import 'package:flutter/material.dart';
import 'package:my_financial/screen/expense/list.dart';
import 'package:my_financial/model/ex.dart' as ex;
import 'package:my_financial/screen/profile/_change_currency.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../model/analytics.dart';
import '../../model/currency.dart';
import '../../model/user.dart';
import '../../shared/menu_bottom.dart';
import '../../shared/app_theme.dart';
import '../dashboard/dashboard.dart';
import '_stat.dart';
import 'add.dart';
import 'detail.dart';

class CategoryListPage extends StatefulWidget {
  final bool? isFromSignUp;
  const CategoryListPage({this.isFromSignUp, Key? key}) : super(key: key);

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  late String _currency;
  late List<CategoryStatus> _statusList;
  late Map<String, List<MonthTotal>> _stats;

  late bool _showStat;
  @override
  void initState() {
    super.initState();
    if (widget.isFromSignUp != null && widget.isFromSignUp == true) {
      Future.delayed(Duration.zero,
          () => showCurrencyDialog(context, Currency.jpy, "Set your currency"));
    }
    _stats = {};
    _showStat = false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([
          AppUser.getCurrency(),
          ChartData.categorySpendingStatus(),
          _showStat
              ? ex.Expense.monthlyTotalByCategory()
              : Future.value(<String, List<MonthTotal>>{}),
        ]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return const _ScaffoldEmptyCategory(
                body: Center(child: Text('Something went wrong')));
          }
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data[0].isNotEmpty) {
              _currency = snapshot.data[0];
            }
            _statusList = snapshot.data[1] as List<CategoryStatus>;
            if (_statusList.isEmpty) {
              return const _ScaffoldEmptyCategory(
                  body: Center(child: Text('No categories. Let\'s add some.')));
            }

            // data for show stat
            if (snapshot.data[2] != null) {
              _stats = snapshot.data[2];
            }

            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.bar_chart_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const DashboardPage(
                        initialPage: 2,
                      ),
                    ));
                  },
                ),
                automaticallyImplyLeading: false,
                title: const Center(child: Text('Category')),
                actions: [
                  _statusList.length >= 20
                      ? const Text('')
                      : IconButton(
                          icon: const Icon(Icons.add_rounded),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CategoryAddPage(),
                              ),
                            );
                          },
                        ),
                ],
              ),
              body: Column(
                children: [
                  _viewSwitcher(),
                  Expanded(child: _buildCategoryList(_showStat)),
                ],
              ),
              bottomNavigationBar:
                  const MenuBottom(menuName: AppMenuItem.budget),
            );
          }
          return const _ScaffoldEmptyCategory(
              body: Center(child: CircularProgressIndicator()));
        });
  }

  Widget _buildCategoryList(bool showStat) {
    return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _statusList.length,
        itemBuilder: (context, index) {
          // check if this category has chart data or not
          String catId = _statusList[index].category.id;
          List<MonthTotal> statData = [];
          if (_stats.containsKey(catId)) {
            statData = _stats[catId]!;
          }
          if (_statusList[index].category.budget != 0) {
            return CategoryWidgetWithBudget(
              item: _statusList[index],
              currency: _currency,
              stat: statData,
              showStat: showStat, // this can be an empty list
            );
          }
          return CategoryWidget(
            item: _statusList[index],
            currency: _currency,
            stat: statData, // this can be an empty list
            showStat: showStat,
          );
        });
  }

  Widget _viewSwitcher() {
    return ToggleButtons(
      constraints: BoxConstraints(
          minHeight: 30, minWidth: MediaQuery.of(context).size.width / 2.2),
      borderRadius: const BorderRadius.all(Radius.circular(6.0)),
      isSelected: [!_showStat, _showStat],
      onPressed: (index) {
        if (index == 0) {
          setState(() {
            _showStat = false;
          });
        } else {
          setState(() {
            _showStat = true;
          });
        }
      },
      children: const [Text('Simple'), Text('Show stat')],
    );
  }
}

class _ScaffoldEmptyCategory extends StatelessWidget {
  final Widget body;
  const _ScaffoldEmptyCategory({
    required this.body,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Category'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const CategoryAddPage()));
            },
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: const MenuBottom(menuName: AppMenuItem.budget),
    );
  }
}

class CategoryWidgetWithBudget extends StatefulWidget {
  final CategoryStatus item;
  final String? currency;
  final List<MonthTotal> stat;
  final bool showStat;
  const CategoryWidgetWithBudget({
    required this.item,
    required this.currency,
    required this.stat,
    required this.showStat,
    Key? key,
  }) : super(key: key);

  @override
  State<CategoryWidgetWithBudget> createState() =>
      _CategoryWidgetWithBudgetState();
}

class _CategoryWidgetWithBudgetState extends State<CategoryWidgetWithBudget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 5.0,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CategoryDetailPage(
                            id: widget.item.category.id,
                            budget: widget.item.category.budget,
                            name: widget.item.category.name,
                            colorCode: widget.item.category.colorCode,
                          )));
                },
                child: Column(
                  children: [
                    Text(
                      widget.item.category.name,
                      style: GoogleFonts.oswald(
                        fontSize: 18,
                        textStyle: TextStyle(
                            color: Color(widget.item.category.colorCode)),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    widget.item.category.budget == 0
                        ? const Text('')
                        : Text('Budget: ${Currency.getIntlMoney(
                                widget.item.category.budget, widget.currency)}'),
                  ],
                ),
              ),
              //const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: LinearPercentIndicator(
                  barRadius: const Radius.circular(3),
                  lineHeight: 8.0,
                  percent: _calPercent(),
                  backgroundColor: _calBgColor(),
                  progressColor: _calProgressColor(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    widget.item.spending > 0
                        ? InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ExpenseListPage(
                                    filterCategory: widget.item.category.id,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              "Spent\n${Currency.getIntlMoney(
                                      widget.item.spending, widget.currency)}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : Text(
                            "Spent\n${Currency.getIntlMoney(
                                    widget.item.spending, widget.currency)}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                    Expanded(child: _spendingStatusText(context)),
                  ],
                ),
              ),
              Visibility(
                  visible: widget.showStat,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      widget.stat.isEmpty
                          ? const Text(
                              'No stat to show',
                              style: TextStyle(color: Colors.grey),
                            )
                          : Stat(widget.stat, currency: widget.currency!),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _spendingStatusText(BuildContext context) {
    if (widget.item.spending > widget.item.category.budget) {
      return Text(
        "Spent over\n${Currency.getIntlMoney(
                widget.item.spending - widget.item.category.budget,
                widget.currency)}",
        style: TextStyle(color: Color(widget.item.category.colorCode)),
        textAlign: TextAlign.right,
      );
    }
    return Text(
      "Remaining\n${Currency.getIntlMoney(
              widget.item.category.budget - widget.item.spending,
              widget.currency)}",
      //style: TextStyle(color: MyAppTheme.myPrimarySwatch.shade200),
      textAlign: TextAlign.right,
    );
  }

  double _calPercent() {
    double factor = widget.item.spending / widget.item.category.budget;
    if (factor < 1.0) return factor;
    if (factor < 2.0) return factor - 1.0;
    return 1.0;
  }

  Color _calBgColor() {
    if (widget.item.category.budget > widget.item.spending) {
      return Color(widget.item.category.colorCode);
    }
    return MyAppTheme.myPrimarySwatch.shade50;
  }

  Color? _calProgressColor(BuildContext context) {
    if (widget.item.category.budget > widget.item.spending) {
      return MyAppTheme.myPrimarySwatch.shade50;
    }
    return Colors.grey.shade600;
  }
}

class CategoryWidget extends StatelessWidget {
  final CategoryStatus item;
  final String? currency;
  final List<MonthTotal> stat;
  final bool showStat;
  const CategoryWidget({
    required this.item,
    required this.currency,
    required this.stat,
    required this.showStat,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 5.0,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CategoryDetailPage(
                        id: item.category.id,
                        name: item.category.name,
                        budget: item.category.budget,
                        colorCode: item.category.colorCode,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    item.category.name,
                    style: GoogleFonts.oswald(
                      textStyle: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              item.spending > 0
                  ? InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ExpenseListPage(
                              filterCategory: item.category.id,
                            ),
                          ),
                        );
                      },
                      child: Text("Spent: ${Currency.getIntlMoney(item.spending, currency)}"))
                  : Text(
                      "Spent: ${Currency.getIntlMoney(item.spending, currency)}",
                    ),
              Visibility(
                  visible: showStat,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      stat.isEmpty
                          ? const Text(
                              'No stat to show',
                              style: TextStyle(color: Colors.grey),
                            )
                          : Stat(stat, currency: currency!),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:core';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_financial/model/cate.dart';
import 'package:my_financial/model/currency.dart';
import 'package:my_financial/screen/dashboard/dashboard.dart';

import '../../model/_shared.dart';
import '../../model/ex.dart';
import '../../model/user.dart';
import '../../model/importance.dart';
import '../../shared/app_theme.dart';
import '../../shared/menu_bottom.dart';
import '_set_max.dart';
import 'add.dart';
import 'detail.dart';

/// @param filterImportance importance name to show in the list (nice, basic...)
/// @param filterCategory category ID to show in the list (e.g. c794dab0-ac82-11ec-8db1-e74f15c63c37)
class ExpenseListPage extends StatefulWidget {
  // any date in the start month
  final DateTime? start;
  // any date in the end month
  final DateTime? end;
  final String filterImportance;
  final String filterCategory;

  const ExpenseListPage({
    this.start,
    this.end,
    this.filterImportance = Importance.filterAll,
    this.filterCategory = Category.filterAll,
    Key? key,
  }) : super(key: key);

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  late String _currency;
  late num _max;
  late List<List<Expense>> _list;

  final now = DateTime.now();
  late final DateTime _thisMonth;
  late DateTime _startMonth;
  late DateTime _endMonth;
  // is there any expense being hidden?
  bool _isShowingFuture = false;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _thisMonth = DateTime(now.year, now.month, 1, 0);
    // this must be at the end of today because expense time in today
    // is at noon (JST), or some time in the day (0~23h?)
    _today = DateTime(now.year, now.month, now.day, 23, 59, 59);

    _list = [];
    _startMonth = widget.start != null
        ? DateTime(widget.start!.year, widget.start!.month, 1, 0)
        : _thisMonth;
    _endMonth = widget.end != null
        ? DateTime(widget.end!.year, widget.end!.month, 1, 0)
        : _thisMonth;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.filterCategory == Importance.filterAll &&
                widget.filterCategory == Category.filterAll
            ? IconButton(
                icon: const Icon(Icons.bar_chart_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const DashboardPage(
                      initialPage: 1,
                    ),
                  ));
                },
              )
            : const BackButton(),
        title: const Text('Expense'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ExpenseAddPage(
                          start: _startMonth,
                          end: _endMonth,
                        )));
              },
              icon: const Icon(Icons.add))
        ],
      ),
      // all of this will be run on rebuild
      body: FutureBuilder(
          future: Future.wait([
            AppUser.getCurrency(),
            _getExpenseList(),
            Expense.max(),
          ]),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Text(snapshot.error.toString())),
              );
            }
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data[0].isNotEmpty) {
                _currency = snapshot.data[0];
              }
              if (snapshot.data[1].isNotEmpty) {
                _list = snapshot.data[1];
              }
              if (snapshot.data[2] != null) {
                _max = snapshot.data[2];
              }
              if (_list.isEmpty) {
                return const Center(
                    child: Text('No expenses. Let\'s add some.'));
              }
              return ListView.builder(
                itemCount: _list.length + 1,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemBuilder: (context, i) {
                  // if the last element in the list then show load more button
                  if (i == _list.length) {
                    return TextButton(
                        onPressed: () async {
                          setState(() {
                            _endMonth = Shared.getOneMonthAgo(_endMonth);
                          });
                        },
                        child: Text("Load ${DateFormat.yMMM()
                                .format(Shared.getOneMonthAgo(_endMonth))}"));
                  }
                  DateTime d = _list[i][0].ts.toDate();
                  DateTime month = DateTime(d.year, d.month, 1, 0);
                  return _buildRow(_list[i], month, i == _list.length - 1);
                },
              );
            }

            return const Center(child: CircularProgressIndicator());
          }),
      bottomNavigationBar: const MenuBottom(menuName: AppMenuItem.expense),
    );
  }

  Widget _buildRow(List<Expense> le, DateTime month, bool isExpanded) {
    num total = 0;
    for (var element in le) {
      total += element.amount;
    }
    String maxText;
    switch (_max) {
      case -1:
        maxText = "Set max";
        break;
      case 0:
        maxText = "Max: Not set";
        break;
      default:
        maxText = "Max: ${Currency.getIntlMoney(_max, _currency)}";
        break;
    }

    return ExpansionTile(
      maintainState: true,
      key: Key(DateFormat.yMMM().format(month)),
      trailing: Text(Currency.getIntlMoney(total, _currency),
          style: GoogleFonts.oswald()),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(DateFormat.yMMM().format(month), style: GoogleFonts.oswald()),
          !_isShowingFuture && month == _thisMonth
              ? ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isShowingFuture = true;
                    });
                  },
                  child: const Text("All"),
                )
              : const Text(''),
          month == _thisMonth
              ? TextButton(
                  onPressed: () {
                    showMaxLineDialog(context, _max);
                  },
                  child: Text(
                    maxText,
                    style: GoogleFonts.oswald(
                      textStyle: TextStyle(color: MyAppTheme.colorError),
                    ),
                  ),
                )
              : const Text(""),
        ],
      ),
      initiallyExpanded: isExpanded,
      children: le.map((e) {
        bool visible = true;
        // check if this specific expense is in the future
        var eDate = e.ts.toDate();
        if (eDate.compareTo(_today) > 0) {
          visible = _isShowingFuture;
        }

        return _buildExpenseRow(e, visible: visible);
      }).toList(),
    );
  }

  Widget _buildExpenseRow(Expense e, {bool visible = true}) {
    return Visibility(
      visible: visible,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ExpenseDetailPage(
                    id: e.id!,
                    ts: e.ts,
                    amount: e.amount,
                    categoryId: e.categoryId,
                    description: e.description,
                    importance: e.importance,
                  )));
        },
        onDoubleTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ExpenseAddPage(
                    start: _startMonth,
                    end: _endMonth,
                    amount: e.amount,
                    categoryId: e.categoryId,
                    description: e.description,
                    importance: e.importance,
                  )));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 20, bottom: 20, right: 10),
              child: _buildLeading(e.importance),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildTitle(e), _buildSubtitle(e)],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 20, bottom: 20, right: 10),
              child: Text(
                Currency.getIntlMoney(e.amount, _currency),
                style: TextStyle(
                  color: e.amount == 0
                      ? MyAppTheme.colorError
                      : const Color(0xFF343434),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading(String importance) {
    var text = Importance.getI18nText('en', importance);
    return Icon(
      Importance.getIcon(importance),
      color: Importance.getColor(importance),
      semanticLabel: text,
    );
  }

  Widget _buildTitle(Expense e) {
    const textMaxLength = 25;
    return RichText(
      text: TextSpan(
        text: e.description.characters.length <= textMaxLength
            ? e.description
            : '${e.description.substring(0, textMaxLength)}...',
        style: const TextStyle(
            color: Color(0xFF343434), overflow: TextOverflow.clip),
        children: [
          e.categoryName == Category.notSetText
              ? const TextSpan(text: '')
              : TextSpan(
                  text: '  ${e.categoryName!}',
                  style: GoogleFonts.oswald(
                    textStyle: TextStyle(color: Color(e.categoryColor!)),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(Expense e) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        DateFormat.MMMEd().format(e.ts.toDate()),
        style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            overflow: TextOverflow.clip),
      ),
    );
  }

  Future<List<List<Expense>>> _getExpenseList() async {
    List<List<Expense>> result = [];
    // if start and end not the same
    for (var month = _startMonth;
        month.compareTo(_endMonth) >= 0;
        month = Shared.getOneMonthAgo(month)) {
      var data = await Expense.listOneMonth(
        month,
        filterCategory: widget.filterCategory,
        filterImportance: widget.filterImportance,
      ).then((value) {
        if (value == null) {
          return [];
        }
        if (value is List && value.isNotEmpty) {
          return value as List<Expense>;
        }
        return [];
      }).onError((error, stackTrace) {
        log(error.toString());
        return [];
      });

      // add data into return data
      if (data.isNotEmpty) {
        result.add(data as List<Expense>);
      }
    }
    return result;
  }
}

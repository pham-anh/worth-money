import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_financial/model/importance.dart';
import '_shared.dart';
import 'cate.dart';
import 'ex.dart';
import 'income.dart';

class SpendingByCategory {
  String category;
  int colorCode;
  double spending;

  SpendingByCategory({
    required this.category,
    required this.spending,
    required this.colorCode,
  });
}

class ImportanceSpending {
  String importance;
  double spending;
  Color color;
  double percent;

  ImportanceSpending({
    required this.importance,
    required this.spending,
    required this.color,
    required this.percent,
  });
}

class CategoryStatus {
  Category category;
  num spending;

  CategoryStatus({
    required this.category,
    required this.spending,
  });
}

class MonthlyTotalSpending {
  String month;
  num spending;

  MonthlyTotalSpending({
    required this.month,
    required this.spending,
  });
}

class MonthlyFigure {
  final DateTime month;
  final num amount;

  MonthlyFigure({required this.month, required this.amount});
}

class MonthlyIO {
  List<MonthlyFigure> income;
  List<MonthlyFigure> spending;
  List<MonthlyFigure> balance;

  MonthlyIO({
    required this.income,
    required this.spending,
    required this.balance,
  });

  static Future<MonthlyIO> data() async {
    Map<DateTime, num> incomeList =
        await Income.sumEachMonth(count: 12).then((value) => value);
    Map<DateTime, num> spendingList =
        await Expense.sumEachMonth(count: 12).then((value) => value);

    List<MonthlyFigure> income = [];
    List<MonthlyFigure> spending = [];
    List<MonthlyFigure> balance = [];

    incomeList.forEach((date, iTotal) {
      num sTotal = 0;
      if (spendingList.containsKey(date)) {
        sTotal = spendingList[date]!;
      }

      if (iTotal == 0 && sTotal == 0) {
        return;
      }

      income.insert(
          0,
          MonthlyFigure(
            month: date,
            amount: iTotal,
          ));
      if (spendingList.containsKey(date)) {
        spending.insert(
            0,
            MonthlyFigure(
              month: date,
              amount: sTotal,
            ));
        balance.insert(
            0,
            MonthlyFigure(
              month: date,
              amount: iTotal - sTotal,
            ));
      }
    });

    return MonthlyIO(income: income, spending: spending, balance: balance);
  }
}

class ChartData {
  static Future<List<SpendingByCategory>> sumCategorySpending(
      List<Expense> list) async {
    var spending = <SpendingByCategory>[];
    List<Category> categories =
        await Category.list(includeNotSet: true).then((list) {
      return list.map((e) => e).toList();
    });

    // init empty sum data
    for (var c in categories) {
      var s = SpendingByCategory(
          category: c.name, spending: 0, colorCode: c.colorCode);
      spending.add(s);
    }

    for (var e in list) {
      var index = categories.indexWhere((c) => c.name == e.categoryName);
      if (index == -1) {
        continue;
      }
      spending[index].spending += e.amount;
    }

    // remove category with 0 spending
    spending.removeWhere((s) => s.spending == 0);

    return spending;
  }

  static List<SpendingByCategory> diffCategorySpending(
      List<SpendingByCategory> last, List<SpendingByCategory> now) {
    var diff = <SpendingByCategory>[];
    for (var i = 0; i < now.length; i++) {
      diff.add(SpendingByCategory(
          category: now[i].category,
          colorCode: now[i].colorCode,
          spending: now[i].spending - last[i].spending));
    }

    return diff;
  }

  static List<ImportanceSpending> sumImportanceSpending(List<Expense> list) {
    var spending = <ImportanceSpending>[];
    var categories = Importance.list();

    // init empty sum data
    for (var im in categories) {
      var s = ImportanceSpending(
        importance: im,
        color: Importance.getColor(im),
        spending: 0,
        percent: 0,
      );
      spending.add(s);
    }

    for (var e in list) {
      var index = categories.indexOf(e.importance);
      spending[index].spending += e.amount;
    }

    double sumAll = 0;
    spending.asMap().forEach((key, value) {
      sumAll += value.spending;
    });

    spending.asMap().forEach((key, value) {
      spending[key].percent = spending[key].spending / sumAll;
    });

    return spending;
  }

  static List<MonthlyTotalSpending> sumMonthlySpending(
      Map<DateTime, num> list) {
    List<MonthlyTotalSpending> total = [];
    list.forEach((key, value) {
      if (value != 0) {
        // reorder data to make last element the newest month
        total.insert(
          0,
          MonthlyTotalSpending(
            month: DateFormat.MMM().format(key),
            spending: value,
          ),
        );
      }
    });

    return total;
  }

  static Future<List<CategoryStatus>> categorySpendingStatus() async {
    List<Category> catList = await Category.list().then((value) => value);
    if (catList.isEmpty) {
      return [];
    }
    // init empty sum data
    Map<String, CategoryStatus> statusMap = {};
    for (var category in catList) {
      var s = CategoryStatus(category: category, spending: 0);
      statusMap[category.id] = s;
    }

    List<dynamic> data = await Expense.listOneMonth(DateTime.now())
        .then((value) => value as List<dynamic>);
    // if current month has no data then get data of the previous month
    if (data.isEmpty) {
      data = await Expense.listOneMonth(Shared.getOneMonthAgo(DateTime.now()))
          .then((value) => value as List<dynamic>);
    }

    if (data.isNotEmpty) {
      List<Expense> thisMonthData = data as List<Expense>;
      for (var ex in thisMonthData) {
        if (!statusMap.containsKey(ex.categoryId)) {
          continue;
        }
        statusMap[ex.categoryId]!.spending += ex.amount;
      }
    }

    // convert to a list then sort
    List<CategoryStatus> statusList = [];
    statusMap.forEach((key, value) {
      statusList.add(value);
    });
    statusList.sort((a, b) {
      if (a.category.budget != b.category.budget) {
        return b.category.budget.compareTo(a.category.budget);
      }

      if (a.spending == b.spending) {
        return a.category.name.compareTo(b.category.name);
      }

      return b.spending.compareTo(a.spending);
    });

    return statusList;
  }
}

class MonthTotal {
  final DateTime month;
  late num total;

  MonthTotal({required this.month, required this.total});

  void accumulate(num amount) {
    total += amount;
  }
}

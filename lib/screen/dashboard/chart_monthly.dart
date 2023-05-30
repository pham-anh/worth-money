import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../../model/analytics.dart';
import '../../model/currency.dart';
import '../../shared/app_theme.dart';
import '_chart_drawer.dart';

class ChartMonthlySpending extends StatelessWidget {
  ChartMonthlySpending({
    required this.data,
    required this.title,
    required this.currency,
    Key? key,
  }) : super(key: key);
  final Map<DateTime, num> data;
  final String title;
  final String? currency;
  late final List<MonthlyTotalSpending> total =
      ChartData.sumMonthlySpending(data);

  @override
  Widget build(BuildContext context) {
    var seriesList = [
      charts.Series<MonthlyTotalSpending, String>(
        id: 'total',
        data: total,
        domainFn: (MonthlyTotalSpending el, _) => el.month,
        measureFn: (MonthlyTotalSpending el, _) => el.spending,
        colorFn: (MonthlyTotalSpending el, _) => charts.Color(
          r: MyAppTheme.myPrimarySwatch.shade200.red,
          g: MyAppTheme.myPrimarySwatch.shade200.green,
          b: MyAppTheme.myPrimarySwatch.shade200.blue,
        ),
        labelAccessorFn: formatMoney,
      ),
    ];

    var bar = BarChartDrawer(
      vertical: true,
      context: context,
      seriesList: seriesList,
      title: title,
      currency: currency,
      hiddenList: [],
      showLegend: false,
    );
    return bar.draw();
  }

  String formatMoney(MonthlyTotalSpending el, _) {
    switch (currency) {
      case Currency.krw:
      case Currency.vnd:
        return Currency.getIntlMoneyCompact(el.spending, currency);

      default:
        return Currency.getIntlMoney(el.spending, currency);
    }
  }
}

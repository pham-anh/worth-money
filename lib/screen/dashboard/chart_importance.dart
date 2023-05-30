import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:my_financial/model/importance.dart';
import '../../model/currency.dart';
import '../../model/ex.dart';
import '../../model/analytics.dart';
import '_chart_drawer.dart';

class ChartByImportance extends StatefulWidget {
  const ChartByImportance({
    required this.data,
    required this.title,
    required this.currency,
    Key? key,
  }) : super(key: key);
  final List<Expense> data;
  final String title;
  final String? currency;

  @override
  State<ChartByImportance> createState() => _ChartByImportanceState();
}

class _ChartByImportanceState extends State<ChartByImportance> {
  late final List<ImportanceSpending> _pieData =
      ChartData.sumImportanceSpending(widget.data);

  @override
  Widget build(BuildContext context) {
    var seriesList = [
      charts.Series<ImportanceSpending, String>(
        id: 'Importance in percentage',
        data: _pieData,
        domainFn: (ImportanceSpending el, _) =>
            Importance.getI18nText('en', el.importance),
        measureFn: (ImportanceSpending el, _) => el.spending,
        colorFn: (ImportanceSpending el, _) => charts.Color(
          r: el.color.red,
          g: el.color.green,
          b: el.color.blue,
        ),
        labelAccessorFn: (ImportanceSpending el, _) {
          var text = "${Importance.getI18nText('en', el.importance)}\n";
          text += Currency.getIntlMoneyCompact(el.spending, widget.currency);
          return text;
        },
      ),
    ];

    var pie = PieChartDrawer(
      context: context,
      seriesList: seriesList,
      title: widget.title,
    );
    return pie.draw();
  }
}

class BarChartByImportance extends StatelessWidget {
  final List<Expense> data;
  final List<Expense> dataToCompare;
  final String title;
  final String? currency;
  late final List<ImportanceSpending> _thisMonthData;
  late final List<ImportanceSpending> _lastMonthData;

  BarChartByImportance({
    required this.data,
    required this.dataToCompare,
    required this.title,
    required this.currency,
    Key? key,
  }) : super(key: key) {
    _thisMonthData = ChartData.sumImportanceSpending(data);
    _lastMonthData = ChartData.sumImportanceSpending(dataToCompare);
  }

  @override
  Widget build(BuildContext context) {
    var seriesList = [
      charts.Series<ImportanceSpending, String>(
        id: 'data',
        data: _thisMonthData,
        displayName: 'This month',
        overlaySeries: true,
        domainFn: (ImportanceSpending el, _) =>
            Importance.getI18nText('en', el.importance),
        measureFn: (ImportanceSpending el, _) => el.spending,
        colorFn: (ImportanceSpending el, _) => charts.Color(
          r: el.color.red,
          g: el.color.green,
          b: el.color.blue,
        ),
        labelAccessorFn: (ImportanceSpending el, _) =>
            Currency.getIntlMoney(el.spending, currency),
      ),
      charts.Series<ImportanceSpending, String>(
          id: 'dataToCompare',
          data: _lastMonthData,
          displayName: 'Compare with the previous month?',
          domainFn: (ImportanceSpending el, _) =>
              Importance.getI18nText('en', el.importance),
          measureFn: (ImportanceSpending el, _) => el.spending,
          colorFn: (ImportanceSpending el, _) =>
              charts.Color(b: el.color.blue, r: el.color.red, g: el.color.green)
                  .lighter
                  .lighter
                  .lighter
                  .lighter,
          labelAccessorFn: (ImportanceSpending el, _) =>
              Currency.getIntlMoney(el.spending, currency),
          fillColorFn: (_, __) => charts.MaterialPalette.transparent,
          insideLabelStyleAccessorFn: (_, __) =>
              charts.TextStyleSpec(color: charts.MaterialPalette.gray.shade700),
          outsideLabelStyleAccessorFn: (_, __) => charts.TextStyleSpec(
              color: charts.MaterialPalette.gray.shade700)),
    ];

    var bar = BarChartDrawer(
      context: context,
      title: title,
      seriesList: seriesList,
      hiddenList: ['dataToCompare'],
      vertical: false,
      currency: currency,
      showLegend: true,
    );

    return SafeArea(child: bar.draw());
  }
}

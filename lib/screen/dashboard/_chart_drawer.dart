import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:my_financial/model/analytics.dart';
import 'package:my_financial/model/currency.dart';
import 'package:my_financial/screen/expense/list.dart';

class BarChartDrawer {
  final BuildContext context;
  final String title;
  final List<charts.Series<dynamic, String>> seriesList;
  final List<String> hiddenList;
  final bool vertical;
  final String? currency;
  final bool showLegend;

  BarChartDrawer({
    required this.context,
    required this.title,
    required this.seriesList,
    required this.hiddenList,
    required this.vertical,
    required this.currency,
    required this.showLegend,
  });

  charts.BarChart draw() {
    return charts.BarChart(
      seriesList,
      animate: true,
      vertical: vertical,
      barGroupingType: charts.BarGroupingType.grouped,
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickFormatterSpec:
            charts.BasicNumericTickFormatterSpec.fromNumberFormat(
                Currency.currencyFormatterForChart(currency)),
        tickProviderSpec:
            const charts.BasicNumericTickProviderSpec(desiredMinTickCount: 5),
      ),
      behaviors: _getBehavior(),
      layoutConfig: charts.LayoutConfig(
        leftMarginSpec: charts.MarginSpec.fromPercent(minPercent: 12),
        topMarginSpec: charts.MarginSpec.fixedPixel(30),
        rightMarginSpec: charts.MarginSpec.fixedPixel(20),
        bottomMarginSpec: showLegend
            ? charts.MarginSpec.fixedPixel(30)
            : charts.MarginSpec.fixedPixel(40),
      ),
      defaultRenderer: charts.BarRendererConfig(
        barRendererDecorator: charts.BarLabelDecorator<String>(),
        strokeWidthPx: 2.0,
      ),
    );
  }

  List<charts.ChartBehavior<String>> _getBehavior() {
    List<charts.ChartBehavior<String>> list = [
      charts.ChartTitle(
        title,
        // behaviorPosition: charts.BehaviorPosition.top,
        // titleOutsideJustification: charts.OutsideJustification.middle,
        // innerPadding: vertical ? 40 : 18,
        // titleStyleSpec: charts.TextStyleSpec(
        //     fontSize:
        //         Theme.of(context).textTheme.titleMedium!.fontSize!.toInt()),
      ),
    ];
    if (showLegend) {
      charts.SeriesLegend<String> legend = charts.SeriesLegend(
        cellPadding: const EdgeInsets.only(top: 8, bottom: 8),
        outsideJustification: charts.OutsideJustification.middleDrawArea,
        entryTextStyle: charts.TextStyleSpec(
            fontSize: Theme.of(context).textTheme.titleSmall!.fontSize!.toInt()),
        showMeasures: true,
        position: charts.BehaviorPosition.bottom,
        legendDefaultMeasure: charts.LegendDefaultMeasure.none,
        defaultHiddenSeries: hiddenList,
      );

      list.add(legend);
    }
    return list;
  }
}

class PieChartDrawer {
  final BuildContext context;
  final List<charts.Series<dynamic, String>> seriesList;
  final String title;

  PieChartDrawer({
    required this.context,
    required this.seriesList,
    required this.title,
  });

  charts.PieChart draw() {
    return charts.PieChart<String>(
      seriesList,
      animate: true,
      defaultRenderer: charts.ArcRendererConfig(
        arcWidth: 100,
        arcRendererDecorators: [
          charts.ArcLabelDecorator(labelPosition: charts.ArcLabelPosition.auto),
        ],
      ),
      behaviors: [
        charts.ChartTitle(
          title,
          // behaviorPosition: charts.BehaviorPosition.top,
          // titleOutsideJustification: charts.OutsideJustification.middle,
          // titleStyleSpec: charts.TextStyleSpec(
          //     fontSize:
          //         Theme.of(context).textTheme.titleMedium!.fontSize!.toInt()),
        ),
      ],
      selectionModels: [
        charts.SelectionModelConfig(
            type: charts.SelectionModelType.info,
            updatedListener: (charts.SelectionModel model) {
              if (!model.hasDatumSelection) {
                return;
              }
              ImportanceSpending spending =
                  model.selectedDatum[0].datum as ImportanceSpending;
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ExpenseListPage(
                        filterImportance: spending.importance,
                      )));
            })
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../../model/analytics.dart';
import '../../model/currency.dart';
import '../../model/user.dart';

class ChartMonthlyIO extends StatefulWidget {
  const ChartMonthlyIO({
    Key? key,
  }) : super(key: key);

  @override
  State<ChartMonthlyIO> createState() => _ChartMonthlyIOState();
}

class _ChartMonthlyIOState extends State<ChartMonthlyIO> {
  String? _currency;

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Future.wait([
          AppUser.getCurrency(),
          MonthlyIO.data(),
        ]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            MonthlyIO? io;

            if (snapshot.data[0].isNotEmpty) {
              _currency = snapshot.data[0] as String;
            }
            if (snapshot.data[1] != null) {
              io = snapshot.data[1] as MonthlyIO;
            }

            var seriesList = [
              charts.Series<MonthlyFigure, String>(
                  id: 'income',
                  displayName: "Income",
                  data: io!.income,
                  domainFn: (MonthlyFigure el, _) => el.month.month.toString(),
                  measureFn: (MonthlyFigure el, _) => el.amount,
                  colorFn: (datum, index) =>
                      charts.Color.fromHex(code: '#F57F17'),
                  labelAccessorFn: (MonthlyFigure el, _) =>
                      _formatCurrency(el.amount))
                ..setAttribute(charts.rendererIdKey, 'customLine'),
              charts.Series<MonthlyFigure, String>(
                id: 'spending',
                displayName: "Spending",
                data: io.spending,
                domainFn: (MonthlyFigure el, _) => el.month.month.toString(),
                measureFn: (MonthlyFigure el, _) => el.amount,
                colorFn: (datum, index) =>
                    charts.Color.fromHex(code: '#E91E63'),
                labelAccessorFn: (MonthlyFigure el, _) =>
                    _formatCurrency(el.amount),
              )..setAttribute(charts.rendererIdKey, 'customLine'),
              charts.Series<MonthlyFigure, String>(
                  id: 'balance',
                  displayName: "Balance",
                  data: io.balance,
                  domainFn: (MonthlyFigure el, _) => el.month.month.toString(),
                  measureFn: (MonthlyFigure el, _) => el.amount,
                  labelAccessorFn: (MonthlyFigure el, _) =>
                    _formatCurrency(el.amount),
                colorFn: (datum, index) =>
                    charts.Color.fromHex(code: '#4FC3F7'),
              ),
            ];

            final children = <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: charts.OrdinalComboChart(
                  seriesList,
                  animate: true,
                  defaultRenderer: charts.BarRendererConfig(
                      groupingType: charts.BarGroupingType.grouped,
                      fillPattern: charts.FillPatternType.solid),
                  customSeriesRenderers: [
                    charts.LineRendererConfig(customRendererId: 'customLine'),
                  ],
                  primaryMeasureAxis: charts.NumericAxisSpec(
                    tickFormatterSpec:
                        charts.BasicNumericTickFormatterSpec.fromNumberFormat(
                            Currency.currencyFormatterForChart(_currency)),
                    tickProviderSpec: const charts.BasicNumericTickProviderSpec(
                        desiredMinTickCount: 5),
                  ),
                  layoutConfig: charts.LayoutConfig(
                    leftMarginSpec:
                        charts.MarginSpec.fromPercent(minPercent: 12),
                    topMarginSpec: charts.MarginSpec.fixedPixel(30),
                    rightMarginSpec: charts.MarginSpec.fixedPixel(20),
                    bottomMarginSpec: charts.MarginSpec.fixedPixel(30),
                  ),
                  selectionModels: [
                    charts.SelectionModelConfig(
                      type: charts.SelectionModelType.info,
                    )
                  ],
                  behaviors: [
                    charts.ChartTitle("Monthly In/Out"),
                    // charts.InitialSelection(selectedDataConfig: [
                    //   charts.SeriesDatumConfig<String>("balance", "3"),
                    //   charts.SeriesDatumConfig<String>("spending", "3"),
                    //   charts.SeriesDatumConfig<String>("income", "3"),
                    // ]),
                    charts.DomainHighlighter(),
                    charts.LinePointHighlighter(
                      showHorizontalFollowLine:
                          charts.LinePointHighlighterFollowLineType.nearest,
                      showVerticalFollowLine:
                          charts.LinePointHighlighterFollowLineType.nearest,
                    ),
                    charts.SelectNearest(
                        eventTrigger: charts.SelectionTrigger.tapAndDrag),
                    charts.SeriesLegend(
                      cellPadding: const EdgeInsets.all(3.0),
                      legendDefaultMeasure: charts.LegendDefaultMeasure.average,
                      horizontalFirst: false,
                      position: charts.BehaviorPosition.bottom,
                      showMeasures: true,
                      measureFormatter: (num? amount) {
                        return amount == null ? '-' : _formatCurrency(amount);
                      },
                    ),
                  ],
                ),
              )
            ];

            return Column(children: children);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  String _formatCurrency(num amount) {
    switch (_currency) {
      case Currency.krw:
      case Currency.vnd:
        return Currency.getIntlMoneyCompact(amount, _currency);

      default:
        return Currency.getIntlMoney(amount, _currency);
    }
  }
}

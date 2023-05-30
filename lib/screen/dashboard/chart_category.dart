import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../../model/currency.dart';
import '../../model/ex.dart';
import '../../model/analytics.dart';
import '../expense/list.dart';

class ChartByCategory extends StatelessWidget {
  const ChartByCategory({
    required this.data,
    required this.title,
    required this.currency,
    Key? key,
  }) : super(key: key);
  final List<Expense> data;
  final String title;
  final String? currency;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([
          ChartData.sumCategorySpending(data),
        ]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            List<SpendingByCategory> thisMonthData =
                snapshot.data[0] as List<SpendingByCategory>;
            var seriesList = [
              charts.Series<SpendingByCategory, String>(
                id: 'data',
                data: thisMonthData,
                domainFn: (SpendingByCategory el, _) {
                  return el.category.length <= 10
                      ? el.category
                      : '${el.category.substring(0, 9)}...';
                },
                measureFn: (SpendingByCategory el, _) => el.spending,
                colorFn: (SpendingByCategory el, _) => charts.Color(
                  r: Color(el.colorCode).red,
                  g: Color(el.colorCode).green,
                  b: Color(el.colorCode).blue,
                ),
                overlaySeries: true,
                labelAccessorFn: (SpendingByCategory el, _) =>
                    "${el.category}\n${Currency.getIntlMoney(el.spending, currency)}",
              ),
            ];
            return charts.PieChart<String>(
              seriesList,
              animate: true,
              defaultRenderer: charts.ArcRendererConfig(
                arcWidth: 100,
                arcRendererDecorators: [
                  charts.ArcLabelDecorator(
                      labelPosition: charts.ArcLabelPosition.auto),
                ],
              ),
              behaviors: [
                charts.ChartTitle(
                  title,
                ),
              ],
              selectionModels: [
                charts.SelectionModelConfig(
                    type: charts.SelectionModelType.info,
                    updatedListener: (charts.SelectionModel model) {
                      if (!model.hasDatumSelection) {
                        return;
                      }

                      SpendingByCategory spending =
                          model.selectedDatum[0].datum as SpendingByCategory;
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ExpenseListPage(
                                filterCategory: spending.category,
                              )));
                    })
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        });
  }
}

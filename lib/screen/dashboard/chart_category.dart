import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
            return PieChart(
              PieChartData(
                sections: _getSections(thisMonthData),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      return;
                    }
                    final touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                    if (event is FlTapUpEvent) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ExpenseListPage(
                                filterCategory: thisMonthData[touchedIndex].category,
                              )));
                    }
                  },
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        });
  }

  List<PieChartSectionData> _getSections(List<SpendingByCategory> data) {
    return data
        .asMap()
        .map<int, PieChartSectionData>((index, data) {
          final double fontSize = 16;
          final double radius = 50;
          final value = PieChartSectionData(
            color: Color(data.colorCode),
            value: data.spending.toDouble(),
            title: data.category,
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );

          return MapEntry(index, value);
        })
        .values
        .toList();
  }
}

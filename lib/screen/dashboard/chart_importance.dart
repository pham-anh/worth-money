import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_financial/model/importance.dart';
import '../../model/currency.dart';
import '../../model/ex.dart';
import '../../model/analytics.dart';

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
    return Column(
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
        Expanded(
          child: PieChart(
            PieChartData(
              sections: _getSections(),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _getSections() {
    return _pieData
        .asMap()
        .map<int, PieChartSectionData>((index, data) {
          final double fontSize = 16;
          final double radius = 50;
          final value = PieChartSectionData(
            color: data.color,
            value: data.spending.toDouble(),
            title: Importance.getI18nText('en', data.importance),
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
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        Expanded(
          child: BarChart(
            BarChartData(
              barGroups: _getBarGroups(),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 4.0,
                        child: Text(Importance.getI18nText('en', _thisMonthData[value.toInt()].importance)),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    return _thisMonthData.asMap().entries.map((entry) {
      final index = entry.key;
      final thisMonth = entry.value;
      final lastMonth = _lastMonthData.firstWhere(
          (element) => element.importance == thisMonth.importance,
          orElse: () => ImportanceSpending(
              importance: thisMonth.importance, spending: 0, color: Colors.transparent));
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: thisMonth.spending.toDouble(),
            color: thisMonth.color,
          ),
          BarChartRodData(
            toY: lastMonth.spending.toDouble(),
            color: thisMonth.color.withOpacity(0.5),
          ),
        ],
      );
    }).toList();
  }
}

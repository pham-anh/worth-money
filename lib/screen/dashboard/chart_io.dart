import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  BarChart(
                    BarChartData(
                      barGroups: _getBarGroups(io!),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
                      ),
                    ),
                  ),
                  LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
                      ),
                      lineBarsData: _getLineBarsData(io!),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  List<LineChartBarData> _getLineBarsData(MonthlyIO io) {
    final incomeData = io.income.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.amount.toDouble());
    }).toList();

    final spendingData = io.spending.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.amount.toDouble());
    }).toList();

    final theme = Theme.of(context);
    return [
      LineChartBarData(
        spots: incomeData,
        isCurved: true,
        color: theme.colorScheme.primary,
        barWidth: 4,
        isStrokeCapRound: true,
        belowBarData: BarAreaData(show: false),
      ),
      LineChartBarData(
        spots: spendingData,
        isCurved: true,
        color: theme.colorScheme.secondary,
        barWidth: 4,
        isStrokeCapRound: true,
        belowBarData: BarAreaData(show: false),
      ),
    ];
  }

  List<BarChartGroupData> _getBarGroups(MonthlyIO io) {
    return io.balance.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.amount.toDouble(),
            color: Theme.of(context).colorScheme.tertiary,
          )
        ],
      );
    }).toList();
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

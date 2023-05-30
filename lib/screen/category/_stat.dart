import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import '../../model/analytics.dart';
import '../../model/currency.dart';

// show stat from January to December of the current year
class Stat extends StatefulWidget {
  final bool animate;
  final List<MonthTotal> data;
  final String currency;

  const Stat(this.data,
      {required this.currency, this.animate = false, Key? key})
      : super(key: key);

  @override
  State<Stat> createState() => _StatState();
}

class _StatState extends State<Stat> {
  late List<Widget> _legend;
  late final num _avg;
  late final List<charts.Series<MonthTotal, DateTime>> _seriesList;
  @override
  void initState() {
    super.initState();
    _seriesList = [
      charts.Series<MonthTotal, DateTime>(
        id: 'stat',
        displayName: '',
        domainFn: (MonthTotal f, _) => f.month,
        measureFn: (MonthTotal f, _) => f.total,
        data: widget.data,
      ),
    ];
    _avg = widget.data.map((e) => e.total).toList().average;
    _legend = [];
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      ListTile(
        trailing: Text(
          "Avg: ${Currency.getIntlMoney(_avg, widget.currency)}",
        ),
        // dense: true,
        title: const Text(
          'This year figures',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        height: 100,
        child: charts.TimeSeriesChart(
          _seriesList,
          selectionModels: [
            charts.SelectionModelConfig(
                type: charts.SelectionModelType.info,
                updatedListener: (charts.SelectionModel model) {
                  final selectedDatum = model.selectedDatum;
                  late DateTime time;
                  final measures = <String, num>{};
                  if (selectedDatum.isNotEmpty) {
                    time = selectedDatum.first.datum.month;
                    for (var datumPair in selectedDatum) {
                      measures[datumPair.series.displayName!] =
                          datumPair.datum.total;
                    }
                    setState(() {
                      // reset data of the previous click
                      _legend = [];
                      measures.forEach((String series, num value) {
                        _legend.add(Text('${DateFormat('MMMM').format(time)}: ${Currency.getIntlMoney(value, widget.currency)}'));
                      });
                    });
                  }
                })
          ],
        ),
      ),
      const SizedBox(height: 8.0)
    ];
    for (var w in _legend) {
      children.add(w);
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        shape: BoxShape.rectangle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 4.0, 10.0),
      child: Column(children: children),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_financial/model/currency.dart';
import 'package:my_financial/model/expense.dart';
import 'package:my_financial/screen/expense/add.dart';
import 'dart:core';

class Expense2ListPage extends StatefulWidget {
  const Expense2ListPage({super.key});

  @override
  State<Expense2ListPage> createState() => _Expense2ListPageState();
}

class _Expense2ListPageState extends State<Expense2ListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expenses"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ExpenseAddPage(
                          start: DateTime.now(),
                          end: DateTime.now(),
                        )));
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: FutureBuilder(
          future: Future(() => ExpenseItem.list()),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              var list = snapshot.data as List<dynamic>;
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final item = list[i].data() as ExpenseItem;
                  return Card(
                    child: ListTile(
                      leading: Text(
                        DateFormat.d().format(item.date.toDate()),
                      ),
                      title: Text(item.detail ?? ""),
                      subtitle: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_month, size: 16),
                              const SizedBox(width: 5),
                              Text(DateFormat.yMMMEd()
                                  .format(item.date.toDate())),
                            ],
                          ),
                          item.store != null
                              ? Row(
                                  children: [
                                    const Icon(Icons.store, size: 16),
                                    const SizedBox(width: 5),
                                    Text(item.store ?? ""),
                                  ],
                                )
                              : const Text(""),
                          // item.category != null
                          //     ? Row(
                          //         children: [
                          //           const Icon(Icons.category, size: 16),
                          //           const SizedBox(width: 5),
                          //           Text(item.category ?? ""),
                          //         ],
                          //       )
                          //     : const Text("")
                        ],
                      ),
                      trailing: Text(
                        Currency.getIntlMoney(item.amount, "JPY"),
                      ),
                    ),
                  );
                },
              );
            }

            return const Center(
              child: Text("No data"),
            );
          }),
    );
  }
}

class ExpenseRow extends StatelessWidget {
  final ExpenseItem item;
  const ExpenseRow({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // onTap: () {
      //   Navigator.of(context).push(MaterialPageRoute(
      //       builder: (context) => ExpenseDetailPage(
      //             id: e.id!,
      //             ts: e.ts,
      //             amount: e.amount,
      //             categoryId: e.categoryId,
      //             description: e.description,
      //             importance: e.importance,
      //           )));
      // },
      // onDoubleTap: () {
      //   Navigator.of(context).push(MaterialPageRoute(
      //       builder: (context) => ExpenseAddPage(
      //             start: _startMonth,
      //             end: _endMonth,
      //             amount: e.amount,
      //             category: e.categoryId,
      //             detail: e.description,
      //             store: e.importance,
      //           )));
      // },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildTitle(item), _buildSubtitle(item)],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 20, bottom: 20, right: 10),
            child: Text(
              Currency.getIntlMoney(item.amount, "JPY"),
              style: TextStyle(
                color: item.amount == 0
                    ? Theme.of(context).colorScheme.error
                    : const Color(0xFF343434),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(ExpenseItem item) {
    return RichText(
      text: TextSpan(
        text: item.store,
        style: const TextStyle(
            color: Color(0xFF343434), overflow: TextOverflow.clip),
        children: [
          TextSpan(
            text: item.category ?? "",
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(ExpenseItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        DateFormat.MMMEd().format(item.date.toDate()),
        style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            overflow: TextOverflow.clip),
      ),
    );
  }
}

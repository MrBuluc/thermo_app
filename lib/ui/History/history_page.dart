import 'package:flutter/material.dart';
import 'package:thermo_app/models/history.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<History> historyList = [];
  List<DataRow> rows = [];

  bool readed = false;

  double fontSize = 15;

  late TextStyle colTextStyle;

  @override
  void initState() {
    super.initState();
    colTextStyle = TextStyle(fontSize: fontSize);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Geçmiş Verilerim"),
      ),
      body: FutureBuilder<void>(
        future: read(),
        builder: (context, _) {
          if (!readed) {
            return const CircularProgressIndicator();
          }
          return ListView(
            children: [
              DataTable(
                columns: [
                  DataColumn(
                      label: Text(
                    "Tarih",
                    style: colTextStyle,
                  )),
                  DataColumn(
                      label: Text(
                    "Sıcaklık",
                    style: colTextStyle,
                  )),
                  DataColumn(
                      label: Text(
                    "Işık Miktarı",
                    style: colTextStyle,
                  ))
                ],
                rows: getrowsList(),
              )
            ],
          );
        },
      ),
    );
  }

  Future read() async {
    historyList = [
      History("11:22 18.04.2022", 22, 15),
      History("10:00 18.04.2022", 20, 10),
      History("09:00 18.04.2022", 10, 5)
    ];
    readed = true;
  }

  List<DataRow> getrowsList() {
    rows.clear();
    for (History history in historyList) {
      DataRow dataRow = DataRow(cells: [
        DataCell(Text(
          history.tarih,
          style: const TextStyle(fontSize: 15),
        )),
        DataCell(Text(
          "${history.thermo} °C",
          style: const TextStyle(fontSize: 15),
        )),
        DataCell(Text(
          "${history.light} Lx",
          style: const TextStyle(fontSize: 15),
        ))
      ]);
      rows.add(dataRow);
    }
    return rows;
  }
}

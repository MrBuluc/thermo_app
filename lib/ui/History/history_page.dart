import 'package:cloud_firestore/cloud_firestore.dart';
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

  late CollectionReference historyRef;

  @override
  void initState() {
    super.initState();
    colTextStyle = TextStyle(fontSize: fontSize);
    historyRef = FirebaseFirestore.instance
        .collection("history")
        .withConverter<History>(
            fromFirestore: (snapshot, _) => History.fromJson(snapshot.data()!),
            toFirestore: (history, _) => history.toJson());
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
            return const Center(child: CircularProgressIndicator());
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
    historyList.clear();
    QuerySnapshot querySnapshot = await historyRef.get();
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      historyList.add(doc.data() as History);
    }
    historyList.sort();
    readed = true;
  }

  List<DataRow> getrowsList() {
    rows.clear();
    for (History history in historyList) {
      DataRow dataRow = DataRow(cells: [
        DataCell(Text(
          History.formatDateTime(history.tarih, "."),
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

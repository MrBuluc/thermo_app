import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:thermo_app/models/history.dart';
import 'package:thermo_app/ui/History/history_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum Kind { thermo, light }

class _MyHomePageState extends State<MyHomePage> {
  double thermo = 0, thermoFontSize = 14, lightFontSize = 15.5;

  int minA = -50,
      thermoMaxA = 50,
      newMinA = 0,
      newMaxA = 50,
      lightMaxA = 1023,
      light = 0;

  Timestamp now = Timestamp.now();

  late StreamSubscription<Event> streamSubscription;

  late CollectionReference historyRef;

  FirebaseDatabase firebaseDB = FirebaseDatabase.instance;
  late DatabaseReference reference;

  bool turnLight = false;

  @override
  void initState() {
    reference = firebaseDB.reference();
    getListener();
    historyRef = FirebaseFirestore.instance
        .collection("history")
        .withConverter<History>(
            fromFirestore: (snapshot, _) => History.fromJson(snapshot.data()!),
            toFirestore: (history, _) => history.toJson());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Thermo App'),
          actions: [
            Center(
                child: Row(
              children: [
                Text(History.formatDateTime(now, ".")),
                IconButton(
                  icon: const Icon(Icons.history),
                  iconSize: 28,
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HistoryPage())),
                )
              ],
            ))
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 400,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buildFaProgressBar(
                      normalization(thermo, minA, thermoMaxA, newMinA, newMaxA),
                      thermo.toString(),
                      Kind.thermo,
                    ),
                    buildFaProgressBar(light, light.toString(), Kind.light)
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: buildText(Kind.thermo),
                ),
                buildText(Kind.light)
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    child: Text(
                      getTurnLight(),
                      style: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      turnOnOffLight();
                    },
                  )
                ],
              ),
            )
          ],
        ));
  }

  Future getListener() async {
    try {
      streamSubscription = reference.onValue.listen((event) {
        Map value = event.snapshot.value;
        setState(() {
          thermo = toDouble(value["thermo"]);
          light = value["light"];
          turnLight = value["turnLight"];
          now = Timestamp.now();
        });
        writeToDb(value);
      });
    } catch (e) {
      print("hata: " + e.toString());
    }
  }

  double toDouble(dynamic value) {
    if (value.runtimeType == int) return (value as int).toDouble();
    return value as double;
  }

  Future writeToDb(Map<dynamic, dynamic> map) async {
    map["tarih"] = now;
    await historyRef.add(History.fromJson(map));
  }

  int normalization(double v, int minA, int maxA, int newMinA, int newMaxA) =>
      (((v - minA) / (maxA - minA) * (newMaxA - newMinA)) + newMinA).toInt();

  FAProgressBar buildFaProgressBar(
      int currentValue, String displayValue, Kind kind) {
    return FAProgressBar(
      currentValue: currentValue,
      size: 50,
      changeColorValue: 25,
      maxValue: kind == Kind.thermo ? thermoMaxA : lightMaxA,
      changeProgressColor: kind == Kind.thermo ? Colors.red : Colors.orange,
      progressColor: kind == Kind.thermo ? Colors.blue : Colors.yellow.shade600,
      backgroundColor: Colors.grey.shade300,
      direction: Axis.vertical,
      verticalDirection: VerticalDirection.up,
      displayText:
          kind == Kind.thermo ? "$displayValue °C" : "$displayValue Lx",
      displayTextStyle: TextStyle(
          color: Colors.black,
          fontSize: kind == Kind.thermo ? thermoFontSize : lightFontSize),
    );
  }

  Text buildText(Kind kind) {
    return Text(
      kind == Kind.thermo ? "Temperature" : "Amount of light",
      style: const TextStyle(fontSize: 20),
    );
  }

  String getTurnLight() {
    String turnLightStr = "Turn ";
    if (turnLight) {
      turnLightStr += "Off ";
    } else {
      turnLightStr += "On ";
    }
    turnLightStr += "Light";
    return turnLightStr;
  }

  Future turnOnOffLight() async {
    await reference.update({"turnLight": !turnLight});
  }
}

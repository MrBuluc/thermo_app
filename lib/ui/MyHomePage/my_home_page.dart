import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum Kind { thermo, light }

class _MyHomePageState extends State<MyHomePage> {
  double thermo = 0, light = 0;

  int minA = -50, maxA = 50, newMinA = 0, newMaxA = 50;

  DateTime now;

  StreamSubscription<Event> streamSubscription;

  @override
  void initState() {
    getListener();
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
                child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Text(now == null ? "" : formatDateTime(now, ".")),
            ))
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 500,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buildFaProgressBar(
                      normalization(thermo, minA, maxA, newMinA, newMaxA),
                      thermo.toString(),
                      Kind.thermo,
                    ),
                    buildFaProgressBar(
                        light.toInt(), light.toString(), Kind.light)
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
            )
          ],
        ));
  }

  Future getListener() async {
    try {
      FirebaseDatabase firebaseDB = FirebaseDatabase.instance;
      DatabaseReference reference = firebaseDB.reference();
      streamSubscription = reference.onValue.listen((event) {
        Map value = event.snapshot.value;
        setState(() {
          thermo = value["thermo"];
          light = value["light"];
          now = DateTime.now();
        });
      });
    } catch (e) {
      print("hata: " + e.toString());
    }
  }

  String formatDateTime(DateTime now, String separator) =>
      now.hour.toString() +
      ":" +
      now.toString().substring(14, 16) +
      " " +
      now.day.toString() +
      separator +
      now.toString().substring(5, 7) +
      separator +
      now.year.toString() +
      " ";

  int normalization(double v, int minA, int maxA, int newMinA, int newMaxA) =>
      (((v - minA) / (maxA - minA) * (newMaxA - newMinA)) + newMinA).toInt();

  FAProgressBar buildFaProgressBar(
      int currentValue, String displayValue, Kind kind) {
    return FAProgressBar(
      currentValue: currentValue,
      size: 50,
      changeColorValue: 25,
      maxValue: maxA,
      changeProgressColor: kind == Kind.thermo ? Colors.red : Colors.orange,
      progressColor: kind == Kind.thermo ? Colors.blue : Colors.yellow.shade600,
      backgroundColor: Colors.grey.shade300,
      direction: Axis.vertical,
      verticalDirection: VerticalDirection.up,
      displayText:
          kind == Kind.thermo ? "$displayValue °C" : "$displayValue Lx",
      displayTextStyle: const TextStyle(color: Colors.black),
    );
  }

  Text buildText(Kind kind) {
    return Text(
      kind == Kind.thermo ? "Temperature" : "Amount of light",
      style: const TextStyle(fontSize: 20),
    );
  }
}

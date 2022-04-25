import 'package:cloud_firestore/cloud_firestore.dart';

class History implements Comparable<History> {
  Timestamp tarih;
  double thermo;
  double light;

  History(this.tarih, this.thermo, this.light);

  History.fromJson(Map<dynamic, dynamic> json)
      : this(json["tarih"] as Timestamp, json["thermo"] as double,
            json["light"] as double);

  Map<String, Object> toJson() =>
      {"tarih": tarih, "thermo": thermo, "light": light};

  static String formatDateTime(Timestamp ts, String separator) {
    DateTime now = ts.toDate();
    return now.hour.toString() +
        ":" +
        now.toString().substring(14, 16) +
        " " +
        now.day.toString() +
        separator +
        now.toString().substring(5, 7) +
        separator +
        now.year.toString() +
        " ";
  }

  @override
  int compareTo(History other) {
    return tarih.compareTo(other.tarih);
  }
}

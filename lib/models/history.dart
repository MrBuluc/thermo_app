class History {
  String tarih;
  double thermo;
  double light;

  History(this.tarih, this.thermo, this.light);

  History.fromJson(Map<dynamic, dynamic> json)
      : this(json["tarih"] as String, json["thermo"] as double,
            json["light"] as double);

  Map<String, Object> toJson() =>
      {"tarih": tarih, "thermo": thermo, "light": light};
}

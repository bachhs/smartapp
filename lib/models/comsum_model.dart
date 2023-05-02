class ComsumModel {
  String id;
  String thu;
  String chi;
  DateTime date;
  String shop;
  String name;

  ComsumModel({this.id, this.thu, this.chi, this.date, this.shop, this.name});

  ComsumModel.withId(
      {this.id, this.thu, this.chi, this.date, this.shop, this.name});

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['thu'] = thu;
    map['chi'] = chi;
    map['date'] = date.toIso8601String();
    map['shop'] = shop;
    map['name'] = name;
    return map;
  }

  factory ComsumModel.fromMap(Map<String, dynamic> map) {
    return ComsumModel.withId(
      id: map['id'],
      thu: map['thu'],
      chi: map['chi'],
      date: DateTime.parse(map['date']),
      shop: map['shop'],
      name: map['name'],
    );
  }
}

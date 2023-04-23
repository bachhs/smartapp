class Device {
  String id;
  String name;
  String bprice;
  String nprice;
  List<String> number;
  DateTime date;
  String status;

  Device({
    this.name,
    this.id,
    this.bprice,
    this.nprice,
    this.number,
    this.date,
    this.status,
  });

  Device.withId({
    this.id,
    this.name,
    this.bprice,
    this.nprice,
    this.number,
    this.date,
    this.status,
  });

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['name'] = name;
    map['bprice'] = bprice;
    map['nprice'] = nprice;
    map['number'] = number;
    map['date'] = date.toIso8601String();
    map['status'] = status;
    return map;
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device.withId(
      id: map['id'],
      name: map['name'],
      bprice: map['bprice'],
      nprice: map['nprice'],
      date: DateTime.parse(map['date']),
      number: List<String>.from(map['number']),
    );
  }
}
